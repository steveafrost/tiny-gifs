import Messages
import UIKit
import ImageIO

/// A searchable Messages drawer that sends full-animation GIF attachments.
final class MessagesViewController: MSMessagesAppViewController, UISearchBarDelegate {
    private let searchBar = UISearchBar()
    private let statusLabel = UILabel()
    private let attribution = UILabel()
    private let picker = TinyGIFPickerViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        searchBar.placeholder = "Search GIFs"
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

        attribution.text = "Powered By GIPHY"
        attribution.font = .systemFont(ofSize: 10, weight: .bold)
        attribution.textColor = .secondaryLabel
        attribution.textAlignment = .right
        attribution.translatesAutoresizingMaskIntoConstraints = false

        addChild(picker)
        picker.view.translatesAutoresizingMaskIntoConstraints = false
        picker.onSelect = { [weak self] item in self?.send(item) }
        picker.onStatusChange = { [weak self] status in self?.statusLabel.text = status }

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

    private func send(_ item: GIFPickerItem) {
        guard let conversation = activeConversation else {
            statusLabel.text = "Open a Messages conversation to send a GIF"
            return
        }
        statusLabel.text = "Preparing GIF…"
        let sourceURL = item.url
        let itemID = item.id
        Task { [weak self, weak conversation] in
            do {
                let attachmentURL = try await Task.detached(priority: .userInitiated) {
                    try TinyGIFAttachmentRenderer.render(sourceURL: sourceURL, identifier: itemID)
                }.value
                guard let conversation else { return }
                try await TinyGIFMessageSender.send(
                    attachmentURL,
                    filename: "tiny-gifs-\(itemID).gif",
                    conversation: conversation
                )
                self?.statusLabel.text = "Sent"
            } catch {
                self?.statusLabel.text = "Couldn’t send that GIF"
            }
        }
    }
}

private struct GIFPickerItem: Identifiable, Hashable {
    let id: String
    let title: String
    let url: URL
}

@MainActor
private final class TinyGIFPickerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var onSelect: ((GIFPickerItem) -> Void)?
    var onStatusChange: ((String) -> Void)?

    private let collectionView: UICollectionView
    private var items: [GIFPickerItem] = []
    private let pageSize = 24
    private var activeQuery: String?
    private var nextOffset = 0
    private var isLoadingPage = false
    private var canLoadMore = true
    private var requestGeneration = TinyGIFRequestGeneration()
    private var pageTask: Task<Void, Never>?

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
        guard GiphyService.isConfigured else {
            beginUnavailable(message: "GIPHY needs a production API key")
            return
        }
        beginLoading(query: nil, status: "Loading trending GIFs…")
    }

    func search(_ query: String) {
        let cleaned = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { loadTrending(); return }
        guard GiphyService.isConfigured else {
            beginUnavailable(message: "GIPHY needs a production API key")
            return
        }
        beginLoading(query: cleaned, status: "Searching GIPHY…")
    }

    private func beginLoading(query: String?, status: String) {
        pageTask?.cancel()
        pageTask = nil
        _ = requestGeneration.begin()
        activeQuery = query
        nextOffset = 0
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
        nextOffset = 0
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
        guard !isLoadingPage, canLoadMore, GiphyService.isConfigured else { return }
        isLoadingPage = true
        let request = requestGeneration.current
        let query = activeQuery
        let offset = nextOffset
        pageTask = Task { [weak self] in
            guard let self else { return }
            do {
                let gifs: [GiphyGIF]
                if let query {
                    gifs = try await GiphyService.search(query, limit: self.pageSize, offset: offset)
                } else {
                    gifs = try await GiphyService.trending(limit: self.pageSize, offset: offset)
                }
                guard !Task.isCancelled,
                      self.requestGeneration.isCurrent(request) else { return }
                var loaded: [GIFPickerItem] = []
                for gif in gifs {
                    guard !Task.isCancelled,
                          self.requestGeneration.isCurrent(request) else { return }
                    if let url = try? await GiphyService.localGIFURL(for: gif) {
                        loaded.append(GIFPickerItem(id: gif.id, title: gif.title, url: url))
                    }
                }
                guard !Task.isCancelled,
                      self.requestGeneration.isCurrent(request) else { return }
                self.pageTask = nil
                self.isLoadingPage = false
                self.nextOffset += gifs.count
                self.canLoadMore = gifs.count == self.pageSize
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
                if self.items.isEmpty { self.showUnavailable(message: "GIPHY is unavailable — try again") }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { items.count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GIFPickerCell.reuseIdentifier, for: indexPath) as! GIFPickerCell
        cell.configure(with: items[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelect?(items[indexPath.item])
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    func configure(with item: GIFPickerItem) {
        imageView.image = AnimatedGIFImage.load(from: item.url)
        accessibilityIdentifier = "tiny-gifs.gif.\(item.id)"
        accessibilityLabel = "Send \(item.title) GIF"
    }
}

private enum AnimatedGIFImage {
    private static let cache = NSCache<NSURL, UIImage>()

    static func load(from url: URL) -> UIImage? {
        if let cached = cache.object(forKey: url as NSURL) { return cached }
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
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
        if let result { cache.setObject(result, forKey: url as NSURL) }
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
