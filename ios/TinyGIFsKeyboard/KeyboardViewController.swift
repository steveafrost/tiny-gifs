import UIKit

final class KeyboardViewController: UIInputViewController {
    private let statusLabel = UILabel()
    private let reactionGrid = UIStackView()
    private let giphyResults = UIStackView()
    private let keys = [["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"], ["a", "s", "d", "f", "g", "h", "j", "k", "l"], ["z", "x", "c", "v", "b", "n", "m"]]

    override func viewDidLoad() {
        super.viewDidLoad()
        buildKeyboard()
    }

    private func buildKeyboard() {
        view.backgroundColor = UIColor(red: 247 / 255, green: 244 / 255, blue: 238 / 255, alpha: 1)
        let root = UIStackView()
        root.axis = .vertical
        root.spacing = 7
        root.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(root)
        NSLayoutConstraint.activate([root.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8), root.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8), root.topAnchor.constraint(equalTo: view.topAnchor, constant: 7), root.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -7)])

        let header = UIStackView()
        header.axis = .horizontal
        header.spacing = 8
        let brand = UILabel(); brand.text = "#tiny-gifs"; brand.font = .systemFont(ofSize: 15, weight: .black); header.addArrangedSubview(brand)
        statusLabel.text = hasFullAccess ? "Search GIPHY or tap a starter" : "Typing stays on your iPhone"
        statusLabel.font = .systemFont(ofSize: 12, weight: .semibold); statusLabel.textAlignment = .right; statusLabel.numberOfLines = 2; header.addArrangedSubview(statusLabel)
        root.addArrangedSubview(header)

        let searchRow = UIStackView(); searchRow.axis = .horizontal; searchRow.spacing = 6
        let search = UITextField(); search.placeholder = "Search GIPHY"; search.borderStyle = .roundedRect; search.autocorrectionType = .no; search.returnKeyType = .search
        let searchButton = key("Search") { [weak self, weak search] in self?.searchGiphy(search?.text ?? "") }
        search.addTarget(self, action: #selector(searchReturn(_:)), for: .editingDidEndOnExit)
        searchRow.addArrangedSubview(search); searchRow.addArrangedSubview(searchButton)
        root.addArrangedSubview(searchRow)

        giphyResults.axis = .horizontal; giphyResults.distribution = .fillEqually; giphyResults.spacing = 5
        giphyResults.isHidden = true
        root.addArrangedSubview(giphyResults)

        reactionGrid.axis = .horizontal; reactionGrid.distribution = .fillEqually; reactionGrid.spacing = 5
        let first = Array(ReactionCatalog.all.prefix(4)); let second = Array(ReactionCatalog.all.suffix(4))
        root.addArrangedSubview(makeReactionRow(first)); root.addArrangedSubview(makeReactionRow(second))
        keys.forEach { root.addArrangedSubview(makeLetterRow($0)) }
        root.addArrangedSubview(makeCommandRow())
    }

    private func makeReactionRow(_ reactions: [Reaction]) -> UIStackView {
        let row = UIStackView(); row.axis = .horizontal; row.distribution = .fillEqually; row.spacing = 5
        reactions.forEach { reaction in
            let button = UIButton(type: .system)
            button.accessibilityLabel = reaction.localizedDescription
            button.layer.cornerRadius = 9; button.backgroundColor = .white
            if let url = ReactionCatalog.resourceURL(for: reaction, fileExtension: "png"), let image = UIImage(contentsOfFile: url.path) { button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal); button.imageView?.contentMode = .scaleAspectFit }
            button.addAction(UIAction { [weak self] _ in self?.select(reaction) }, for: .touchUpInside)
            row.addArrangedSubview(button); button.heightAnchor.constraint(equalToConstant: 47).isActive = true
        }
        return row
    }

    private func makeLetterRow(_ letters: [String]) -> UIStackView {
        let row = UIStackView(); row.axis = .horizontal; row.spacing = 5; row.distribution = .fillEqually
        letters.forEach { letter in row.addArrangedSubview(key(letter.uppercased()) { [weak self] in self?.textDocumentProxy.insertText(letter) }) }
        return row
    }

    private func makeCommandRow() -> UIStackView {
        let row = UIStackView(); row.axis = .horizontal; row.spacing = 5; row.distribution = .fillProportionally
        let globe = key("🌐") { [weak self] in self?.advanceToNextInputMode() }; globe.accessibilityLabel = "Next keyboard"
        let delete = key("⌫") { [weak self] in self?.textDocumentProxy.deleteBackward() }; delete.accessibilityLabel = "Delete"
        let space = key("space") { [weak self] in self?.textDocumentProxy.insertText(" ") }; space.accessibilityLabel = "Space"
        let `return` = key("return") { [weak self] in self?.textDocumentProxy.insertText("\n") }; `return`.accessibilityLabel = "Return"
        [globe, delete, space, `return`].forEach(row.addArrangedSubview)
        space.widthAnchor.constraint(equalTo: globe.widthAnchor, multiplier: 2.3).isActive = true
        return row
    }

    private func key(_ title: String, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.filled(); configuration.title = title; configuration.baseBackgroundColor = .white; configuration.baseForegroundColor = .black; configuration.cornerStyle = .medium
        button.configuration = configuration; button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium); button.heightAnchor.constraint(equalToConstant: 39).isActive = true
        button.addAction(UIAction { _ in action() }, for: .touchUpInside); return button
    }

    private func select(_ reaction: Reaction) {
        switch KeyboardReactionAction.selecting(reaction, hasFullAccess: hasFullAccess) {
        case .copyLocalGIF(let reaction):
            guard let url = ReactionCatalog.resourceURL(for: reaction, fileExtension: "gif"), let data = try? Data(contentsOf: url) else { statusLabel.text = "Local GIF unavailable"; return }
            UIPasteboard.general.setData(data, forPasteboardType: "com.compuserve.gif")
            statusLabel.text = "Copied — paste in the conversation ✓"
        case .explainFullAccess:
            statusLabel.text = "Turn on Full Access to copy. Typing stays local."
        }
    }

    @objc private func searchReturn(_ sender: UITextField) { searchGiphy(sender.text ?? "") }

    private func searchGiphy(_ query: String) {
        guard hasFullAccess else { statusLabel.text = "Full Access enables GIPHY search. Typing stays local."; return }
        guard GiphyService.isConfigured else { statusLabel.text = "Add GIPHY_API_KEY to activate search."; return }
        let cleanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanQuery.isEmpty else { return }
        statusLabel.text = "Searching GIPHY…"
        Task { [weak self] in
            guard let self else { return }
            do {
                let gifs = try await GiphyService.search(cleanQuery, limit: 4)
                await MainActor.run { self.showGiphy(gifs) }
            } catch {
                await MainActor.run { self.statusLabel.text = "GIPHY is unavailable. Try again." }
            }
        }
    }

    @MainActor private func showGiphy(_ gifs: [GiphyGIF]) {
        giphyResults.arrangedSubviews.forEach { $0.removeFromSuperview() }
        gifs.forEach { gif in
            let button = UIButton(type: .system)
            button.accessibilityLabel = gif.title
            button.layer.cornerRadius = 9; button.backgroundColor = .white
            Task { [weak button] in
                guard let button, let (data, _) = try? await URLSession.shared.data(from: gif.tinyPreviewURL), let image = UIImage(data: data) else { return }
                await MainActor.run { button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal); button.imageView?.contentMode = .scaleAspectFit }
            }
            button.addAction(UIAction { [weak self] _ in self?.copyGiphy(gif) }, for: .touchUpInside)
            giphyResults.addArrangedSubview(button); button.heightAnchor.constraint(equalToConstant: 47).isActive = true
        }
        giphyResults.isHidden = gifs.isEmpty
        statusLabel.text = gifs.isEmpty ? "No GIFs found" : "Powered By GIPHY — tap to copy"
    }

    private func copyGiphy(_ gif: GiphyGIF) {
        guard hasFullAccess else { return }
        statusLabel.text = "Preparing GIF…"
        Task { [weak self] in
            guard let self else { return }
            do {
                let url = try await GiphyService.localGIFURL(for: gif)
                let data = try Data(contentsOf: url)
                await MainActor.run { UIPasteboard.general.setData(data, forPasteboardType: "com.compuserve.gif"); self.statusLabel.text = "Copied — paste in the conversation ✓" }
            } catch {
                await MainActor.run { self.statusLabel.text = "Couldn’t copy that GIF" }
            }
        }
    }
}
