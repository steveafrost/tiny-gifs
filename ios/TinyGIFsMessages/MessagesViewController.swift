import Messages
import UIKit

final class MessagesViewController: MSMessagesAppViewController, UISearchBarDelegate {
    private let searchBar = UISearchBar()
    private let attribution = UILabel()
    private let browser = TinyStickerBrowserViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        searchBar.placeholder = "Search the full GIF library"
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        attribution.text = "Powered By GIPHY"
        attribution.font = .systemFont(ofSize: 10, weight: .bold)
        attribution.textColor = .secondaryLabel
        attribution.textAlignment = .right
        attribution.translatesAutoresizingMaskIntoConstraints = false
        addChild(browser)
        browser.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        view.addSubview(attribution)
        view.addSubview(browser.view)
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 3),
            attribution.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            attribution.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: -4),
            browser.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            browser.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            browser.view.topAnchor.constraint(equalTo: attribution.bottomAnchor, constant: 2),
            browser.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        browser.didMove(toParent: self)
        browser.loadTrending()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        browser.search(searchBar.text ?? "")
    }
}

private final class TinyStickerBrowserViewController: MSStickerBrowserViewController {
    private var stickers: [MSSticker] = []

    init() { super.init(stickerSize: .small) }
    required init?(coder: NSCoder) { super.init(coder: coder) }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadBundledFallback()
    }

    func loadTrending() {
        guard GiphyService.isConfigured else { return }
        Task { [weak self] in
            guard let self else { return }
            if let gifs = try? await GiphyService.trending() { await self.setGiphyStickers(gifs) }
        }
    }

    func search(_ query: String) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { loadTrending(); return }
        guard GiphyService.isConfigured else { loadBundledFallback(); return }
        Task { [weak self] in
            guard let self else { return }
            if let gifs = try? await GiphyService.search(query) { await self.setGiphyStickers(gifs) }
        }
    }

    private func loadBundledFallback() {
        stickers = ReactionCatalog.all.compactMap { reaction in
            guard let url = ReactionCatalog.resourceURL(for: reaction, fileExtension: "png") else { return nil }
            return try? MSSticker(contentsOfFileURL: url, localizedDescription: reaction.localizedDescription)
        }
        stickerBrowserView.reloadData()
    }

    @MainActor private func setGiphyStickers(_ gifs: [GiphyGIF]) async {
        var loaded: [MSSticker] = []
        for gif in gifs {
            if let url = try? await GiphyService.localGIFURL(for: gif), let sticker = try? MSSticker(contentsOfFileURL: url, localizedDescription: gif.title) { loaded.append(sticker) }
        }
        guard !loaded.isEmpty else { return }
        stickers = loaded
        stickerBrowserView.reloadData()
    }

    override func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int { stickers.count }
    override func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker { stickers[index] }
}
