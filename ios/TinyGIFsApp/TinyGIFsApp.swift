import SwiftUI
import UIKit

@main
struct TinyGIFsApp: App {
    var body: some Scene {
        WindowGroup { TinyGIFsRootView() }
    }
}

private struct TinyGIFsRootView: View {
    @AppStorage("didCompleteOnboarding") private var didCompleteOnboarding = false
    @AppStorage("favoriteReactionIDs") private var favoriteReactionIDs = ""

    var favorites: Set<String> {
        Set(favoriteReactionIDs.split(separator: ",").map(String.init))
    }

    var body: some View {
        TabView {
            NavigationStack { HomeView(favorites: favorites) }
                .tabItem { Label("Home", systemImage: "sparkles") }
            NavigationStack { LibraryView(favorites: favorites, setFavorites: saveFavorites) }
                .tabItem { Label("Library", systemImage: "square.grid.2x2") }
            NavigationStack { GiphyLibraryView() }
                .tabItem { Label("GIPHY", systemImage: "magnifyingglass") }
            NavigationStack { SetupView() }
                .tabItem { Label("Setup", systemImage: "checklist") }
        }
        .tint(.black)
        .fullScreenCover(isPresented: Binding(get: { !didCompleteOnboarding }, set: { _ in })) {
            OnboardingView { didCompleteOnboarding = true }
        }
    }

    private func saveFavorites(_ values: Set<String>) {
        favoriteReactionIDs = values.sorted().joined(separator: ",")
    }
}

private struct OnboardingView: View {
    let finish: () -> Void
    @State private var page = 0

    private let pages = [
        ("Big reaction. Tiny footprint.", "Search the full GIPHY library, with tiny reactions ready when you need them.", "sparkles"),
        ("Fastest in Messages.", "Use the #tiny-gifs sticker extension to drop a tiny reaction right into a Messages conversation.", "message.fill"),
        ("Keyboard everywhere else.", "The optional keyboard types normally offline. Full Access unlocks GIPHY search and copies a GIF to paste.", "keyboard")
    ]

    var body: some View {
        let item = pages[page]
        VStack(alignment: .leading, spacing: 24) {
            Spacer()
            Image(systemName: item.2).font(.system(size: 52, weight: .black)).foregroundStyle(.black).padding(20).background(Color.lime, in: RoundedRectangle(cornerRadius: 18))
            Text("#tiny-gifs").font(.system(size: 24, weight: .black, design: .rounded))
            Text(item.0).font(.system(size: 42, weight: .black, design: .rounded)).fixedSize(horizontal: false, vertical: true)
            Text(item.1).font(.title3).lineSpacing(4).foregroundStyle(.secondary)
            HStack(spacing: 7) { ForEach(pages.indices, id: \.self) { index in Capsule().fill(index == page ? Color.black : Color.black.opacity(0.15)).frame(width: index == page ? 32 : 10, height: 10) } }
            Spacer()
            Button(page == pages.count - 1 ? "Start tiny" : "Continue") { page == pages.count - 1 ? finish() : (page += 1) }
                .buttonStyle(TinyPrimaryButton())
        }
        .padding(28)
        .background(Color.canvas.ignoresSafeArea())
    }
}

private struct HomeView: View {
    let favorites: Set<String>

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("#tiny-gifs").font(.system(size: 22, weight: .black, design: .rounded))
                Text("Big reaction.\nTiny footprint.").font(.system(size: 38, weight: .black, design: .rounded)).lineSpacing(-5)
                SharingRouteCard(icon: "message.fill", title: "Fastest in Messages", detail: "Drop a tiny reaction right in the conversation.", tint: .lime)
                SharingRouteCard(icon: "keyboard", title: "Keyboard everywhere else", detail: "Copy a tiny reaction and paste anywhere.", tint: .sky)
                if !favorites.isEmpty { Text("Your favorites").font(.headline); ReactionGrid(reactions: ReactionCatalog.all.filter { favorites.contains($0.id) }) }
                Text("Your reactions").font(.headline)
                ReactionGrid(reactions: ReactionCatalog.all)
            }
            .padding(20)
        }
        .background(Color.canvas)
        .navigationTitle("")
        .toolbar { ToolbarItem(placement: .topBarTrailing) { NavigationLink { PrivacyDetailView() } label: { Image(systemName: "lock") } } }
    }
}

private struct SharingRouteCard: View {
    let icon: String
    let title: String
    let detail: String
    let tint: Color
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon).font(.title2.bold()).frame(width: 48, height: 48).background(tint, in: RoundedRectangle(cornerRadius: 12)).foregroundStyle(.black)
            VStack(alignment: .leading, spacing: 4) { Text(title).font(.headline); Text(detail).font(.subheadline).foregroundStyle(.secondary) }
            Spacer()
        }
        .padding(16).background(.white, in: RoundedRectangle(cornerRadius: 16)).overlay(RoundedRectangle(cornerRadius: 16).stroke(.black, lineWidth: 1.5))
    }
}

private struct LibraryView: View {
    let favorites: Set<String>
    let setFavorites: (Set<String>) -> Void
    @State private var query = ""
    var filtered: [Reaction] { query.isEmpty ? ReactionCatalog.all : ReactionCatalog.all.filter { $0.displayName.localizedCaseInsensitiveContains(query) } }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Starter reactions.").font(.title.bold())
                Text("Your offline fallback. Search GIPHY for the full library.").foregroundStyle(.secondary)
                ReactionGrid(reactions: filtered, favorites: favorites) { reaction in
                    var updated = favorites
                    if !updated.insert(reaction.id).inserted { updated.remove(reaction.id) }
                    setFavorites(updated)
                }
            }.padding(20)
        }
        .background(Color.canvas)
        .navigationTitle("Library")
        .searchable(text: $query, prompt: "Search reactions")
    }
}

private struct GiphyLibraryView: View {
    @State private var query = ""
    @State private var gifs: [GiphyGIF] = []
    @State private var isLoading = false
    @State private var error: String?

    private let columns = [GridItem(.adaptive(minimum: 104), spacing: 12)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("The full GIF library.").font(.title.bold())
                Text("Search GIPHY, then tap a result to preview it at tiny size in Messages or your keyboard.").foregroundStyle(.secondary)
                if !GiphyService.isConfigured {
                    ContentUnavailableView("GIPHY is ready to connect", systemImage: "key", description: Text("Add GIPHY_API_KEY in the build settings to activate live search."))
                } else if isLoading {
                    ProgressView("Finding tiny reactions…").frame(maxWidth: .infinity, minHeight: 180)
                } else if let error {
                    ContentUnavailableView("Library unavailable", systemImage: "wifi.exclamationmark", description: Text(error))
                } else {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(gifs) { gif in GiphyGIFTile(gif: gif) }
                    }
                }
                Text("Powered By GIPHY").font(.caption2.bold()).foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(20)
        }
        .background(Color.canvas)
        .navigationTitle("GIPHY")
        .searchable(text: $query, prompt: "Search GIFs")
        .task { await loadTrending() }
        .task(id: query) {
            guard !query.isEmpty else { return }
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }
            await load(query: query)
        }
    }

    private func loadTrending() async {
        guard GiphyService.isConfigured else { return }
        isLoading = true; error = nil
        do { gifs = try await GiphyService.trending() } catch { self.error = error.localizedDescription }
        isLoading = false
    }

    private func load(query: String) async {
        guard GiphyService.isConfigured else { return }
        isLoading = true; error = nil
        do { gifs = try await GiphyService.search(query) } catch { self.error = error.localizedDescription }
        isLoading = false
    }
}

private struct GiphyGIFTile: View {
    let gif: GiphyGIF
    var body: some View {
        AsyncImage(url: gif.tinyPreviewURL) { image in image.resizable().scaledToFill() } placeholder: { Color.black.opacity(0.08) }
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(alignment: .bottomLeading) { Text(gif.title.isEmpty ? "GIF" : gif.title).font(.caption2.bold()).lineLimit(1).padding(5).foregroundStyle(.white).background(.black.opacity(0.65), in: Capsule()).padding(5) }
            .accessibilityLabel(gif.title)
    }
}

private struct ReactionGrid: View {
    let reactions: [Reaction]
    var favorites: Set<String> = []
    var toggleFavorite: ((Reaction) -> Void)?
    private let columns = [GridItem(.adaptive(minimum: 82), spacing: 12)]
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            if reactions.contains(.lol) { tile(.lol) }
            if reactions.contains(.nope) { tile(.nope) }
            if reactions.contains(.omg) { tile(.omg) }
            if reactions.contains(.brb) { tile(.brb) }
            if reactions.contains(.perfect) { tile(.perfect) }
            if reactions.contains(.yes) { tile(.yes) }
            if reactions.contains(.yikes) { tile(.yikes) }
            if reactions.contains(.tinyClap) { tile(.tinyClap) }
        }
    }

    private func tile(_ reaction: Reaction) -> some View {
        Button { toggleFavorite?(reaction) } label: {
            VStack(spacing: 6) {
                ReactionArtwork(reaction: reaction).frame(width: 70, height: 70).padding(9).background(.white, in: RoundedRectangle(cornerRadius: 14)).overlay(RoundedRectangle(cornerRadius: 14).stroke(.black, lineWidth: 1.2))
                Text(reaction.displayName).font(.caption.bold()).lineLimit(1)
                if favorites.contains(reaction.id) { Image(systemName: "heart.fill").font(.caption2).foregroundStyle(Color.coral) }
            }
        }.buttonStyle(.plain).accessibilityLabel("\(reaction.displayName), \(favorites.contains(reaction.id) ? "favorite" : "not favorite")")
    }
}

private struct SetupView: View {
    var body: some View {
        List {
            Section("Start in Messages") {
                Label("#tiny-gifs Stickers are bundled with the app", systemImage: "checkmark.square.fill")
                Text("Open a Messages conversation, tap the app drawer, then choose #tiny-gifs. Tap a sticker to insert it and tap Send.")
            }
            Section("Use the keyboard elsewhere") {
                Label("Add #tiny-gifs in Keyboard Settings", systemImage: "keyboard")
                Text("The keyboard works offline for typing and starter reactions. Full Access enables GIPHY search plus copying the GIF you choose to the pasteboard.")
                Button("Open Settings") { if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) } }
            }
            Section("Diagnostics") {
                Label("No account", systemImage: "person.crop.circle.badge.xmark")
                Label("No analytics SDK", systemImage: "chart.line.downtrend.xyaxis")
                Label("GIPHY search uses the network", systemImage: "network")
            }
        }
        .navigationTitle("Setup")
    }
}

private struct PrivacyDetailView: View {
    var body: some View {
        ScrollView { VStack(alignment: .leading, spacing: 16) { Text("Private by design.").font(.largeTitle.bold()); Text("#tiny-gifs has no account or analytics SDK. Its starter reactions work offline. When you search the full GIPHY library, your search request goes to GIPHY under its terms and attribution requirements. The keyboard never records or transmits what you type. Full Access is optional; it enables GIPHY search and copying the GIF you choose to the system pasteboard.").font(.body).lineSpacing(4) }.padding(20) }
            .navigationTitle("Privacy").background(Color.canvas)
    }
}

private struct TinyPrimaryButton: ButtonStyle { func makeBody(configuration: Configuration) -> some View { configuration.label.frame(maxWidth: .infinity).padding(.vertical, 16).font(.headline).foregroundStyle(.black).background(Color.lime.opacity(configuration.isPressed ? 0.72 : 1), in: RoundedRectangle(cornerRadius: 14)).overlay(RoundedRectangle(cornerRadius: 14).stroke(.black, lineWidth: 2)) } }
private extension Color { static let canvas = Color(red: 247 / 255, green: 244 / 255, blue: 238 / 255); static let lime = Color(red: 200 / 255, green: 1, blue: 61 / 255); static let sky = Color(red: 113 / 255, green: 201 / 255, blue: 1); static let coral = Color(red: 1, green: 107 / 255, blue: 87 / 255) }
