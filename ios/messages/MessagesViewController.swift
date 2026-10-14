import Messages
import UIKit
import ImageIO

/// A searchable Messages drawer that sends normalized animated GIF stickers.
final class MessagesViewController: MSMessagesAppViewController, UISearchBarDelegate {
    private let searchBar = UISearchBar()
    private let statusLabel = UILabel()
    private let attribution = UILabel()
    private let picker = TinyGIFPickerViewController()
    private var sendState = TinyGIFSendState()

    private func setStatus(_ message: String) {
        statusLabel.text = message
        UIAccessibility.post(notification: .announcement, argument: message)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        searchBar.placeholder = "Search KLIPY"
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        searchBar.searchBarStyle = .minimal
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchBar.accessibilityIdentifier = "tiny-gifs.search"
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        statusLabel.text = "Tap a GIF to send it"
        statusLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        statusLabel.textColor = .secondaryLabel
        statusLabel.lineBreakMode = .byTruncatingTail
        statusLabel.accessibilityIdentifier = "tiny-gifs.status"
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        attribution.text = "Powered by KLIPY"
        attribution.font = .systemFont(ofSize: 10, weight: .semibold)
        attribution.textAlignment = .right
        attribution.accessibilityLabel = "Powered by KLIPY"
        attribution.isAccessibilityElement = true
        attribution.translatesAutoresizingMaskIntoConstraints = false

        addChild(picker)
        picker.view.translatesAutoresizingMaskIntoConstraints = false
        picker.onSelect = { [weak self] item, stickerURL in self?.send(item, stickerURL: stickerURL) }
        picker.onStatusChange = { [weak self] status in self?.setStatus(status) }

        // Remove the template storyboard label before installing the real drawer.
        view.subviews.forEach { $0.removeFromSuperview() }
        view.addSubview(searchBar)
        view.addSubview(statusLabel)
        view.addSubview(attribution)
        view.addSubview(picker.view)
        statusLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        attribution.setContentCompressionResistancePriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 2),
            searchBar.heightAnchor.constraint(equalToConstant: 48),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            statusLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            statusLabel.heightAnchor.constraint(equalToConstant: 18),
            statusLabel.trailingAnchor.constraint(lessThanOrEqualTo: attribution.leadingAnchor, constant: -8),
            attribution.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            attribution.widthAnchor.constraint(equalToConstant: 100),
            attribution.heightAnchor.constraint(equalToConstant: 13),
            attribution.centerYAnchor.constraint(equalTo: statusLabel.centerYAnchor),
            picker.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            picker.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            picker.view.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 2),
            picker.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        picker.didMove(toParent: self)
        picker.loadTrending()
    }

    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        requestPresentationStyle(TinyGIFDrawerLayout.presentationStyle)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        picker.search(searchBar.text ?? "")
    }

    private func send(_ item: GIFPickerItem, stickerURL: URL) {
        guard KlipyService.isMediaProcessingEnabled else {
            setStatus("GIF sharing is not available yet")
            return
        }
        guard sendState.begin() else { return }
        guard let conversation = activeConversation else {
            sendState.finish()
            setStatus("Open a Messages conversation to send a GIF")
            return
        }
        setStatus("Sending GIF…")
        // The file is ready before the tap. Do not download or encode here.
        TinyGIFMessageSender.startSend(
            stickerURL: stickerURL,
            localizedDescription: item.title.isEmpty ? "Tiny animated GIF" : item.title,
            conversation: conversation
        ) { [weak self] error in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if error != nil {
                    self.sendState.finish()
                    self.setStatus("Couldn’t send that GIF")
                    return
                }
                self.setStatus("Sent tiny GIF")
                // Apple's callback means sending has started; keep the extension
                // visible briefly while Messages commits the outgoing sticker.
                try? await Task.sleep(for: .milliseconds(500))
                self.sendState.finish()
                if TinyGIFDrawerLayout.shouldDismissToKeyboardAfterSend(succeeded: true) {
                    self.dismiss()
                }
            }
        }
    }

}

private struct GIFPickerItem: Identifiable, Hashable {
    let id: String
    let title: String
    let url: URL
    let gif: KlipyGIF
}

@MainActor
private final class TinyGIFPickerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var onSelect: ((GIFPickerItem, URL) -> Void)?
    var onStatusChange: ((String) -> Void)?

    private let collectionView: UICollectionView
    private var items: [GIFPickerItem] = []
    private let pageSize = 24
    private var activeQuery: String?
    private var nextPage = 1
    private var isLoadingPage = false
    private var canLoadMore = true
    private var requestGeneration = TinyGIFRequestGeneration()
    private var pageTask: Task<Void, Never>?
    private var preparedAttachments: [String: URL] = [:]
    private var preparationFailures: Set<String> = []
    private var preparationQueue: [GIFPickerItem] = []
    private var queuedIDs: Set<String> = []
    private var preparationTasks: [String: Task<Void, Never>] = [:]

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = TinyGIFDrawerLayout.lineSpacing
        layout.minimumInteritemSpacing = TinyGIFDrawerLayout.interitemSpacing
        layout.sectionInset = TinyGIFDrawerLayout.sectionInsets
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.accessibilityIdentifier = "tiny-gifs.grid"
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(GIFPickerCell.self, forCellWithReuseIdentifier: GIFPickerCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func loadTrending() {
        guard KlipyService.isConfigured else {
            beginUnavailable(message: "GIF browsing is not available yet")
            return
        }
        beginLoading(query: nil, status: "Loading trending GIFs…")
    }

    func search(_ query: String) {
        let cleaned = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { loadTrending(); return }
        guard KlipyService.isConfigured else {
            beginUnavailable(message: "GIF browsing is not available yet")
            return
        }
        beginLoading(query: query, status: "Searching KLIPY…")
    }

    private func beginLoading(query: String?, status: String) {
        pageTask?.cancel()
        pageTask = nil
        _ = requestGeneration.begin()
        resetPreparation()
        activeQuery = query
        nextPage = 0
        canLoadMore = true
        isLoadingPage = false
        showLoading(message: status)
        loadNextPage()
    }

    private func beginUnavailable(message: String) {
        pageTask?.cancel()
        pageTask = nil
        _ = requestGeneration.begin()
        isLoadingPage = false
        nextPage = 0
        canLoadMore = false
        showUnavailable(message: message)
    }

    private func showLoading(message: String) {
        onStatusChange?(message)
        items = []
        collectionView.reloadData()
    }

    private func showUnavailable(message: String) {
        onStatusChange?(message)
        items = []
        collectionView.reloadData()
    }

    private func loadNextPage() {
        guard !isLoadingPage, canLoadMore, KlipyService.isConfigured else { return }
        isLoadingPage = true
        let request = requestGeneration.current
        let query = activeQuery
        let pageNumber = nextPage
        pageTask = Task { [weak self] in
            guard let self else { return }
            do {
                let page: KlipyPage
                if let query {
                    page = try await KlipyService.search(query, limit: self.pageSize, page: pageNumber)
                } else {
                    page = try await KlipyService.trending(limit: self.pageSize, page: pageNumber)
                }
                guard !Task.isCancelled,
                      self.requestGeneration.isCurrent(request) else { return }
                let loaded = page.items.map {
                    GIFPickerItem(id: $0.id, title: $0.title, url: $0.tinyPreviewURL, gif: $0)
                }
                self.pageTask = nil
                self.isLoadingPage = false
                self.nextPage += 1
                self.canLoadMore = page.hasNext
                guard !loaded.isEmpty else {
                    if self.items.isEmpty { self.showUnavailable(message: "No GIFs found — try another search") }
                    return
                }
                self.items.append(contentsOf: loaded)
                self.onStatusChange?("Tap a tiny GIF to send it")
                self.collectionView.reloadData()
            } catch {
                guard !Task.isCancelled,
                      self.requestGeneration.isCurrent(request) else { return }
                self.pageTask = nil
                self.isLoadingPage = false
                if self.items.isEmpty { self.showUnavailable(message: "KLIPY is unavailable — try again") }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { items.count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GIFPickerCell.reuseIdentifier, for: indexPath) as! GIFPickerCell
        let item = items[indexPath.item]
        cell.configure(with: item, ready: preparedAttachments[item.id] != nil, failed: preparationFailures.contains(item.id) || !KlipyService.isMediaProcessingEnabled)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        guard let stickerURL = preparedAttachments[item.id] else { return }
        onSelect?(item, stickerURL)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        guard KlipyService.isMediaProcessingEnabled,
              preparedAttachments[item.id] == nil,
              !preparationFailures.contains(item.id),
              queuedIDs.insert(item.id).inserted else { return }
        preparationQueue.append(item)
        // Start after willDisplay returns so the visible index paths are current.
        Task { @MainActor [weak self] in self?.startNextPreparation() }
    }

    private func resetPreparation() {
        preparationTasks.values.forEach { $0.cancel() }
        preparationTasks = [:]
        preparationQueue = []
        queuedIDs = []
        preparedAttachments = [:]
        preparationFailures = []
    }

    private func startNextPreparation() {
        // Bound full-media downloads and encoders to avoid overwhelming the extension.
        while preparationTasks.count < 1, !preparationQueue.isEmpty {
            let item = preparationQueue.removeFirst()
            let visible = collectionView.indexPathsForVisibleItems.contains {
                items.indices.contains($0.item) && items[$0.item].id == item.id
            }
            guard visible else {
                queuedIDs.remove(item.id)
                continue
            }
            let generation = requestGeneration.current
            preparationTasks[item.id] = Task { [weak self] in
                guard let self else { return }
                do {
                    let sourceURL = try await KlipyService.localGIFURL(for: item.gif)
                    defer { try? FileManager.default.removeItem(at: sourceURL) }
                    try Task.checkCancellation()
                    let encoder = Task.detached(priority: .userInitiated) {
                        try TinyGIFAttachmentRenderer.render(sourceURL: sourceURL, identifier: "klipy-" + item.id)
                    }
                    let url = try await withTaskCancellationHandler {
                        try await encoder.value
                    } onCancel: {
                        encoder.cancel()
                    }
                    guard !Task.isCancelled, self.requestGeneration.isCurrent(generation) else { return }
                    self.preparedAttachments[item.id] = url
                } catch {
                    guard !Task.isCancelled, self.requestGeneration.isCurrent(generation) else { return }
                    self.preparationFailures.insert(item.id)
                }
                self.preparationTasks[item.id] = nil
                if let index = self.items.firstIndex(where: { $0.id == item.id }),
                   let cell = self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? GIFPickerCell {
                    cell.setPreparationState(ready: self.preparedAttachments[item.id] != nil, failed: self.preparationFailures.contains(item.id))
                }
                self.startNextPreparation()
            }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let remaining = scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.bounds.height
        if remaining < 180 { loadNextPage() }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        TinyGIFDrawerLayout.itemSize(containerWidth: collectionView.bounds.width)
    }
}

private final class GIFPickerCell: UICollectionViewCell {
    static let reuseIdentifier = "GIFPickerCell"

    private let imageView = UIImageView()
    private var previewTask: Task<Void, Never>?
    private let preparationSpinner = UIActivityIndicatorView(style: .medium)
    private let preparationLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        preparationSpinner.translatesAutoresizingMaskIntoConstraints = false
        preparationSpinner.hidesWhenStopped = true
        contentView.addSubview(preparationSpinner)
        preparationLabel.translatesAutoresizingMaskIntoConstraints = false
        preparationLabel.font = .systemFont(ofSize: 10, weight: .semibold)
        preparationLabel.textColor = .white
        preparationLabel.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        preparationLabel.textAlignment = .center
        contentView.addSubview(preparationLabel)
        NSLayoutConstraint.activate([
            preparationSpinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            preparationSpinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            preparationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            preparationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            preparationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            preparationLabel.heightAnchor.constraint(equalToConstant: 18),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        previewTask?.cancel()
        previewTask = nil
        imageView.image = nil
    }

    func setPreparationState(ready: Bool, failed: Bool) {
        isUserInteractionEnabled = ready
        preparationLabel.isHidden = ready
        preparationLabel.text = failed ? "Unavailable" : "Preparing…"
        if ready || failed { preparationSpinner.stopAnimating() }
        else { preparationSpinner.startAnimating() }
        accessibilityTraits = ready ? [.button] : [.button, .notEnabled]
    }

    func configure(with item: GIFPickerItem, ready: Bool, failed: Bool) {
        setPreparationState(ready: ready, failed: failed)
        previewTask?.cancel()
        imageView.image = nil
        previewTask = Task { [weak self] in
            guard let (data, response) = try? await URLSession.shared.data(from: item.url),
                  let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode),
                  !Task.isCancelled else { return }
            let image = AnimatedGIFImage.load(data: data)
            guard !Task.isCancelled else { return }
            self?.imageView.image = image
        }
        accessibilityIdentifier = "tiny-gifs.gif.\(item.id)"
        accessibilityLabel = "Send \(item.title) GIF"
    }
}

private enum AnimatedGIFImage {
    static func load(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let frameCount = CGImageSourceGetCount(source)
        guard frameCount > 0 else { return nil }

        var frames: [UIImage] = []
        var duration: TimeInterval = 0
        for index in 0..<frameCount {
            guard let image = CGImageSourceCreateImageAtIndex(source, index, nil) else { continue }
            frames.append(UIImage(cgImage: image))
            duration += frameDuration(source: source, at: index)
        }
        let result = frames.count == 1 ? frames.first : UIImage.animatedImage(with: frames, duration: max(duration, 0.1))
        return result
    }

    private static func frameDuration(source: CGImageSource, at index: Int) -> TimeInterval {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
              let gif = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any] else { return 0.1 }
        let unclamped = gif[kCGImagePropertyGIFUnclampedDelayTime] as? Double
        let clamped = gif[kCGImagePropertyGIFDelayTime] as? Double
        return max(unclamped ?? clamped ?? 0.1, 0.02)
    }
}
