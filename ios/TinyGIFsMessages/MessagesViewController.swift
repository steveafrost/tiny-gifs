import Messages
import UIKit

/// A #images-style Messages app drawer: selecting a GIF puts a media attachment
/// in the Messages compose field. It deliberately does not create MSSticker objects.
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
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        statusLabel.text = "Tap a GIF to add it to your message"
        statusLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        statusLabel.textColor = .secondaryLabel
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        attribution.text = "Powered By GIPHY"
        attribution.font = .systemFont(ofSize: 10, weight: .bold)
        attribution.textColor = .secondaryLabel
        attribution.textAlignment = .right
        attribution.translatesAutoresizingMaskIntoConstraints = false

        addChild(picker)
        picker.view.translatesAutoresizingMaskIntoConstraints = false
        picker.onSelect = { [weak self] item in self?.insert(item) }

        view.addSubview(searchBar)
        view.addSubview(statusLabel)
        view.addSubview(attribution)
        view.addSubview(picker.view)
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 3),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            statusLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: -3),
            attribution.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            attribution.centerYAnchor.constraint(equalTo: statusLabel.centerYAnchor),
            picker.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            picker.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            picker.view.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 4),
            picker.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        picker.didMove(toParent: self)
        picker.loadTrending()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        picker.search(searchBar.text ?? "")
    }

    private func insert(_ item: GIFPickerItem) {
        guard let conversation = activeConversation else {
            statusLabel.text = "Open a Messages conversation to add a GIF"
            return
        }
        statusLabel.text = "Adding GIF…"
        let filename = "tiny-gifs-\(item.id).gif"
        conversation.insertAttachment(item.url, withAlternateFilename: filename) { [weak self] error in
            DispatchQueue.main.async {
                self?.statusLabel.text = error == nil ? "Added — tap Send" : "Couldn’t add that GIF"
            }
        }
    }
}

private struct GIFPickerItem: Identifiable, Hashable {
    let id: String
    let title: String
    let url: URL
}

private final class TinyGIFPickerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var onSelect: ((GIFPickerItem) -> Void)?

    private let collectionView: UICollectionView
    private var items: [GIFPickerItem] = []

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 4, left: 10, bottom: 10, right: 10)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .clear
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
        loadBundledFallback()
    }

    func loadTrending() {
        guard GiphyService.isConfigured else { return }
        Task { [weak self] in
            guard let self, let gifs = try? await GiphyService.trending() else { return }
            await self.setGiphyGIFs(gifs)
        }
    }

    func search(_ query: String) {
        let cleaned = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { loadTrending(); return }
        guard GiphyService.isConfigured else { loadBundledFallback(); return }
        Task { [weak self] in
            guard let self, let gifs = try? await GiphyService.search(cleaned) else { return }
            await self.setGiphyGIFs(gifs)
        }
    }

    private func loadBundledFallback() {
        items = ReactionCatalog.all.compactMap { reaction in
            guard let url = ReactionCatalog.resourceURL(for: reaction, fileExtension: "gif") else { return nil }
            return GIFPickerItem(id: reaction.id, title: reaction.localizedDescription, url: url)
        }
        collectionView.reloadData()
    }

    @MainActor private func setGiphyGIFs(_ gifs: [GiphyGIF]) async {
        var loaded: [GIFPickerItem] = []
        for gif in gifs {
            if let url = try? await GiphyService.localGIFURL(for: gif) {
                loaded.append(GIFPickerItem(id: gif.id, title: gif.title, url: url))
            }
        }
        guard !loaded.isEmpty else { return }
        items = loaded
        collectionView.reloadData()
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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalInsets: CGFloat = 20
        let interitemSpacing: CGFloat = 16
        let width = floor((collectionView.bounds.width - horizontalInsets - interitemSpacing) / 3)
        return CGSize(width: max(80, width), height: max(92, width * 0.9))
    }
}

private final class GIFPickerCell: UICollectionViewCell {
    static let reuseIdentifier = "GIFPickerCell"

    private let imageView = UIImageView()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 10, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -3),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            titleLabel.heightAnchor.constraint(equalToConstant: 14)
        ])
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
    }

    func configure(with item: GIFPickerItem) {
        imageView.image = UIImage(contentsOfFile: item.url.path)
        titleLabel.text = item.title.isEmpty ? "GIF" : item.title
        accessibilityLabel = "Add \(item.title) GIF to message"
    }
}
