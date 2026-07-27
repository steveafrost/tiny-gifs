import SwiftUI
import UIKit

@main
struct TinyGIFsApp: App {
    var body: some Scene {
        WindowGroup {
            KeyboardInstallerView()
                // The product's light canvas is intentional. Without this, system Dark
                // Mode makes SwiftUI's primary labels white against the light canvas.
                .preferredColorScheme(.light)
        }
    }
}

/// iOS requires a containing app to distribute a custom keyboard. This screen
/// deliberately stays focused on installing and understanding that keyboard.
private struct KeyboardInstallerView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                KeyboardPreview()
                installSteps
                giphyExplainer
                privacyNote
            }
            .padding(24)
            .padding(.bottom, 28)
        }
        .background(Color.canvas.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("#tiny-gifs")
                .font(.system(size: 23, weight: .black, design: .rounded))
            Text("GIFs wherever\nyou type.")
                .font(.system(size: 42, weight: .black, design: .rounded))
                .lineSpacing(-6)
                .foregroundStyle(.black)
            Text("Install the keyboard once. Then search and paste tiny GIPHY GIFs from any app.")
                .font(.title3.weight(.medium))
                .foregroundStyle(Color.black.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var installSteps: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Install the keyboard")
                .font(.title2.weight(.black))
                .foregroundStyle(.black)

            InstallStep(number: "1", title: "Open Settings", detail: "Then go to General → Keyboard → Keyboards.")
            InstallStep(number: "2", title: "Add #tiny-gifs", detail: "Choose Add New Keyboard… and select #tiny-gifs.")
            InstallStep(number: "3", title: "Turn on Full Access", detail: "This unlocks GIPHY search and copies the GIF you choose. Typing always stays private.")

            Button("Open Settings") {
                openURL(URL(string: UIApplication.openSettingsURLString)!)
            }
            .buttonStyle(TinyPrimaryButton())
            .accessibilityHint("Opens iOS Settings. Continue to General, Keyboard, and Keyboards to add #tiny-gifs.")
        }
    }

    private var giphyExplainer: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("GIPHY is in the keyboard", systemImage: "magnifyingglass")
                .font(.headline.weight(.black))
                .foregroundStyle(.black)
            Text("Tap the #tiny-gifs keyboard’s search button, find a GIF, then paste it into the app you’re using. The companion app does not need to stay open.")
                .foregroundStyle(Color.black.opacity(0.76))
                .fixedSize(horizontal: false, vertical: true)
            Text("Powered By GIPHY")
                .font(.caption.weight(.black))
                .foregroundStyle(Color.black.opacity(0.58))
        }
        .padding(18)
        .background(Color.sky.opacity(0.2), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black, lineWidth: 1.5))
    }

    private var privacyNote: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lock.fill")
                .foregroundStyle(.black)
            Text("#tiny-gifs never records or sends what you type. Full Access is used only for GIPHY search and copying the GIF you select to the pasteboard.")
                .font(.footnote.weight(.medium))
                .foregroundStyle(Color.black.opacity(0.7))
        }
        .padding(.horizontal, 4)
    }
}

private struct InstallStep: View {
    let number: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 13) {
            Text(number)
                .font(.headline.weight(.black))
                .foregroundStyle(.black)
                .frame(width: 30, height: 30)
                .background(Color.lime, in: Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.headline.weight(.black)).foregroundStyle(.black)
                Text(detail).font(.subheadline.weight(.medium)).foregroundStyle(Color.black.opacity(0.68))
            }
            Spacer(minLength: 0)
        }
        .padding(15)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.black, lineWidth: 1.5))
    }
}

private struct KeyboardPreview: View {
    private let keys = ["GIF", "lol", "omg", "nope", "brb", "yes", "yikes", "clap"]

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack {
                Label("#tiny-gifs Keyboard", systemImage: "keyboard.fill")
                    .font(.headline.weight(.black))
                    .foregroundStyle(.black)
                Spacer()
                Text("LIVE GIPHY SEARCH")
                    .font(.caption2.weight(.black))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color.lime, in: Capsule())
            }
            HStack(spacing: 7) {
                ForEach(keys, id: \.self) { key in
                    Text(key)
                        .font(.caption.weight(.black))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, minHeight: 31)
                        .background(key == "GIF" ? Color.lime : .white, in: RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black.opacity(0.72), lineWidth: 1))
                }
            }
            Text("Search GIPHY from the GIF key after enabling Full Access.")
                .font(.footnote.weight(.medium))
                .foregroundStyle(Color.black.opacity(0.72))
        }
        .padding(18)
        .background(Color.black.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black, lineWidth: 1.5))
    }
}

private struct TinyPrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .font(.headline.weight(.black))
            .foregroundStyle(.black)
            .background(Color.lime.opacity(configuration.isPressed ? 0.72 : 1), in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(.black, lineWidth: 2))
    }
}

private extension Color {
    static let canvas = Color(red: 247 / 255, green: 244 / 255, blue: 238 / 255)
    static let lime = Color(red: 200 / 255, green: 1, blue: 61 / 255)
    static let sky = Color(red: 113 / 255, green: 201 / 255, blue: 1)
}
