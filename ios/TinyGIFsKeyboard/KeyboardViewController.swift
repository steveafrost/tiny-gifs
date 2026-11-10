import UIKit

final class KeyboardViewController: UIInputViewController {
    private let statusLabel = UILabel()
    private let searchField = UITextField()
    private let searchRow = UIStackView()
    private let assetStrip = UIStackView()
    private let characterRows = UIStackView()
    private var characterButtons: [(key: String, button: UIButton)] = []
    private var layer: KeyboardLayer = .letters
    private var isShifted = false
    private var shiftButton: UIButton?
    private var layerButton: UIButton?
    private var searchGeneration = KeyboardSearchGeneration()
    private var searchTask: Task<Void, Never>?
    private var compactHeight = false

    override func viewDidLoad() {
        super.viewDidLoad()
        buildKeyboard()
        refreshFullAccessState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshFullAccessState()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let shouldCompact = view.bounds.height < 260
        guard shouldCompact != compactHeight else { return }
        compactHeight = shouldCompact
        searchRow.isHidden = shouldCompact
        assetStrip.isHidden = shouldCompact
        refreshFullAccessState()
    }

    private func setStatus(_ message: String) {
        statusLabel.text = message
        UIAccessibility.post(notification: .announcement, argument: message)
    }

    private func buildKeyboard() {
        view.backgroundColor = UIColor(red: 247 / 255, green: 244 / 255, blue: 238 / 255, alpha: 1)
        let root = UIStackView()
        root.axis = .vertical
        root.spacing = 5
        root.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(root)
        NSLayoutConstraint.activate([
            root.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            root.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            root.topAnchor.constraint(equalTo: view.topAnchor, constant: 6),
            root.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -6)
        ])

        let header = UIStackView()
        header.axis = .horizontal
        header.spacing = 6
        let brand = UILabel()
        brand.text = "#tiny-gifs"
        brand.font = .systemFont(ofSize: 14, weight: .black)
        brand.setContentHuggingPriority(.required, for: .horizontal)
        header.addArrangedSubview(brand)
        statusLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        statusLabel.textAlignment = .right
        statusLabel.numberOfLines = 1
        statusLabel.adjustsFontSizeToFitWidth = true
        statusLabel.minimumScaleFactor = 0.75
        statusLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        header.addArrangedSubview(statusLabel)
        let attribution = UILabel()
        attribution.text = "Powered by KLIPY"
        attribution.font = .systemFont(ofSize: 9, weight: .semibold)
        attribution.textAlignment = .right
        attribution.accessibilityLabel = "Powered by KLIPY"
        attribution.isAccessibilityElement = true
        attribution.setContentHuggingPriority(.required, for: .horizontal)
        header.addArrangedSubview(attribution)
        attribution.widthAnchor.constraint(equalToConstant: 72).isActive = true
        root.addArrangedSubview(header)

        searchRow.axis = .horizontal
        searchRow.spacing = 6
        searchField.placeholder = "Search KLIPY"
        searchField.borderStyle = .roundedRect
        searchField.autocorrectionType = .no
        searchField.autocapitalizationType = .none
        searchField.returnKeyType = .search
        searchField.accessibilityLabel = "Search KLIPY"
        searchField.accessibilityHint = "Requires Full Access to search KLIPY."
        searchField.addTarget(self, action: #selector(searchReturn(_:)), for: .editingDidEndOnExit)
        searchField.heightAnchor.constraint(equalToConstant: 32).isActive = true
        let searchButton = key("Search", height: 32) { [weak self, weak searchField] in
            self?.searchKlipy(searchField?.text ?? "")
        }
        searchButton.accessibilityHint = "Requires Full Access to search KLIPY."
        searchRow.addArrangedSubview(searchField)
        searchRow.addArrangedSubview(searchButton)
        root.addArrangedSubview(searchRow)

        assetStrip.axis = .horizontal
        assetStrip.distribution = .fillEqually
        assetStrip.spacing = 5
        assetStrip.heightAnchor.constraint(equalToConstant: 42).isActive = true
        root.addArrangedSubview(assetStrip)
        showStarterReactions()

        characterRows.axis = .vertical
        characterRows.spacing = 5
        characterRows.distribution = .fillEqually
        root.addArrangedSubview(characterRows)
        renderCharacterRows()

        root.addArrangedSubview(makeCommandRow())
        updateModifierAppearance()
    }

    private func refreshFullAccessState() {
        let granted = hasFullAccess
        if compactHeight {
            statusLabel.text = "Typing — use Messages for KLIPY"
        } else {
            statusLabel.text = granted ? "Search KLIPY or tap a starter" : "Typing stays local"
        }
        if !granted {
            showStarterReactions()
        }
    }

    private func showStarterReactions() {
        assetStrip.arrangedSubviews.forEach { $0.removeFromSuperview() }
        ReactionCatalog.all.forEach { reaction in
            let button = UIButton(type: .system)
            button.accessibilityLabel = reaction.localizedDescription
            button.layer.cornerRadius = 9
            button.backgroundColor = .white
            if let url = ReactionCatalog.resourceURL(for: reaction, fileExtension: "png"),
               let image = UIImage(contentsOfFile: url.path) {
                button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
                button.imageView?.contentMode = .scaleAspectFit
            }
            button.addAction(UIAction { [weak self] _ in self?.select(reaction) }, for: .touchUpInside)
            assetStrip.addArrangedSubview(button)
        }
    }

    private func renderCharacterRows() {
        characterRows.arrangedSubviews.forEach { $0.removeFromSuperview() }
        characterButtons.removeAll()
        for rowKeys in KeyboardLayout.rows(for: layer) {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 5
            row.distribution = .fillEqually
            for character in rowKeys {
                let button = key(
                    KeyboardLayout.character(for: character, layer: layer, shifted: isShifted),
                    height: 34
                ) { [weak self] in
                    self?.insert(character)
                }
                characterButtons.append((character, button))
                row.addArrangedSubview(button)
            }
            characterRows.addArrangedSubview(row)
        }
    }

    private func insert(_ character: String) {
        let text = KeyboardLayout.character(for: character, layer: layer, shifted: isShifted)
        if searchField.isFirstResponder {
            searchField.insertText(text)
        } else {
            textDocumentProxy.insertText(text)
        }
        if layer == .letters, isShifted {
            isShifted = false
            updateCharacterTitles()
            updateModifierAppearance()
        }
    }

    private func deleteBackward() {
        if searchField.isFirstResponder {
            searchField.deleteBackward()
        } else {
            textDocumentProxy.deleteBackward()
        }
    }

    private func insertSpace() {
        if searchField.isFirstResponder {
            searchField.insertText(" ")
        } else {
            textDocumentProxy.insertText(" ")
        }
    }

    private func insertReturn() {
        if searchField.isFirstResponder {
            searchKlipy(searchField.text ?? "")
            searchField.resignFirstResponder()
        } else {
            textDocumentProxy.insertText("\n")
        }
    }

    private func updateCharacterTitles() {
        for (key, button) in characterButtons {
            let title = KeyboardLayout.character(for: key, layer: layer, shifted: isShifted)
            var configuration = button.configuration
            configuration?.title = title
            button.configuration = configuration
            button.accessibilityLabel = title
        }
    }

    private func toggleShift() {
        guard layer == .letters else { return }
        isShifted.toggle()
        updateCharacterTitles()
        updateModifierAppearance()
    }

    private func toggleLayer() {
        layer = layer.next
        isShifted = false
        renderCharacterRows()
        updateModifierAppearance()
    }

    private func updateModifierAppearance() {
        guard let shiftButton else { return }
        shiftButton.isHidden = !layer.showsShift
        setColors(
            background: isShifted ? .systemBlue : .white,
            foreground: isShifted ? .white : .black,
            on: shiftButton
        )
        guard let layerButton else { return }
        var configuration = layerButton.configuration
        configuration?.title = layer.switchKeyTitle
        layerButton.configuration = configuration
        layerButton.accessibilityLabel = "Switch to \(layer.next == .numbers ? "numbers" : layer.next == .symbols ? "symbols" : "letters")"
    }

    private func makeCommandRow() -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 5
        row.distribution = .fillProportionally
        let globe = key("🌐", height: 34) { [weak self] in self?.advanceToNextInputMode() }
        globe.accessibilityLabel = "Next keyboard"
        let shift = key("⇧", height: 34) { [weak self] in self?.toggleShift() }
        shift.accessibilityLabel = "Shift"
        shiftButton = shift
        let layerKey = key(layer.switchKeyTitle, height: 34) { [weak self] in self?.toggleLayer() }
        layerButton = layerKey
        let delete = key("⌫", height: 34) { [weak self] in self?.deleteBackward() }
        delete.accessibilityLabel = "Delete"
        let space = key("space", height: 34) { [weak self] in self?.insertSpace() }
        space.accessibilityLabel = "Space"
        space.setContentHuggingPriority(.defaultLow, for: .horizontal)
        let `return` = key("return", height: 34) { [weak self] in self?.insertReturn() }
        `return`.accessibilityLabel = "Return"
        [globe, shift, layerKey, delete, space, `return`].forEach(row.addArrangedSubview)
        return row
    }

    private func key(_ title: String, height: CGFloat, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.baseBackgroundColor = .white
        configuration.baseForegroundColor = .black
        configuration.cornerStyle = .medium
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 15, weight: .medium)
            return outgoing
        }
        button.configuration = configuration
        button.accessibilityLabel = title
        button.heightAnchor.constraint(equalToConstant: height).isActive = true
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return button
    }

    private func setColors(background: UIColor, foreground: UIColor, on button: UIButton) {
        var configuration = button.configuration
        configuration?.baseBackgroundColor = background
        configuration?.baseForegroundColor = foreground
        button.configuration = configuration
    }

    private func select(_ reaction: Reaction) {
        switch KeyboardReactionAction.selecting(reaction, hasFullAccess: hasFullAccess) {
        case .copyLocalGIF(let reaction):
            guard let url = ReactionCatalog.resourceURL(for: reaction, fileExtension: "gif") else {
                setStatus("Local GIF unavailable")
                return
            }
            copyNormalizedGIF(sourceURL: url, identifier: reaction.id)
        case .explainFullAccess:
            setStatus("Turn on Full Access to copy. Typing stays local.")
        }
    }

    @objc private func searchReturn(_ sender: UITextField) { searchKlipy(sender.text ?? "") }

    private func searchKlipy(_ query: String) {
        guard hasFullAccess else {
            setStatus("Full Access enables KLIPY search. Typing stays local.")
            return
        }
        guard KlipyService.isConfigured else {
            setStatus("GIF search is not available yet.")
            return
        }
        let cleanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanQuery.isEmpty else { return }
        searchTask?.cancel()
        let search = searchGeneration.begin()
        setStatus("Searching KLIPY…")
        searchTask = Task { [weak self] in
            do {
                let page = try await KlipyService.search(query, limit: 8)
                await MainActor.run {
                    guard let self, !Task.isCancelled, self.searchGeneration.isCurrent(search) else { return }
                    self.searchTask = nil
                    self.showKlipy(page.items)
                }
            } catch {
                await MainActor.run {
                    guard let self, !Task.isCancelled, self.searchGeneration.isCurrent(search) else { return }
                    self.searchTask = nil
                    self.showStarterReactions()
                    self.setStatus("KLIPY is unavailable. Try again.")
                }
            }
        }
    }

    @MainActor private func showKlipy(_ gifs: [KlipyGIF]) {
        guard !gifs.isEmpty else {
            showStarterReactions()
            setStatus("No GIFs found — try another search")
            return
        }
        assetStrip.arrangedSubviews.forEach { $0.removeFromSuperview() }
        gifs.forEach { gif in
            let button = UIButton(type: .system)
            button.accessibilityLabel = gif.title.isEmpty ? "KLIPY GIF" : gif.title
            button.layer.cornerRadius = 9
            button.backgroundColor = .white
            Task { [weak button] in
                guard let button,
                      let (data, _) = try? await URLSession.shared.data(from: gif.tinyPreviewURL),
                      let image = UIImage(data: data) else { return }
                await MainActor.run {
                    button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
                    button.imageView?.contentMode = .scaleAspectFit
                }
            }
            button.addAction(UIAction { [weak self] _ in self?.copyKlipy(gif) }, for: .touchUpInside)
            assetStrip.addArrangedSubview(button)
        }
        setStatus("Powered By KLIPY — tap to copy")
    }

    private func copyKlipy(_ gif: KlipyGIF) {
        guard hasFullAccess else { return }
        guard KlipyService.isMediaProcessingEnabled else {
            setStatus("GIF sharing is not available yet")
            return
        }
        setStatus("Preparing GIF…")
        Task { [weak self] in
            do {
                let sourceURL = try await KlipyService.localGIFURL(for: gif)
                self?.copyNormalizedGIF(
                    sourceURL: sourceURL,
                    identifier: "klipy-" + gif.id,
                    alreadyPreparing: true
                )
            } catch {
                await MainActor.run { self?.setStatus("Couldn’t copy that GIF") }
            }
        }
    }

    private func copyNormalizedGIF(
        sourceURL: URL,
        identifier: String,
        alreadyPreparing: Bool = false
    ) {
        if !alreadyPreparing { setStatus("Preparing GIF…") }
        Task { [weak self] in
            defer { if alreadyPreparing { try? FileManager.default.removeItem(at: sourceURL) } }
            do {
                let normalizedURL = try await Task.detached(priority: .userInitiated) {
                    try TinyGIFAttachmentRenderer.render(sourceURL: sourceURL, identifier: identifier)
                }.value
                let data = try Data(contentsOf: normalizedURL)
                await MainActor.run {
                    UIPasteboard.general.setData(data, forPasteboardType: "com.compuserve.gif")
                    self?.setStatus("Copied — paste in the conversation ✓")
                }
            } catch {
                await MainActor.run { self?.setStatus("Couldn’t copy that GIF") }
            }
        }
    }
}
