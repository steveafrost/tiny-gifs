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

/// iOS requires a containing app to distribute the Messages extension and the
/// optional keyboard. This screen explains the real sharing paths clearly.
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
            Text("Big feeling.\nTiny footprint.")
                .font(.system(size: 42, weight: .black, design: .rounded))
                .lineSpacing(-6)
                .foregroundStyle(.black)
            Text("Your fastest path is in Messages: search GIPHY, add a GIF to the message field, then send it without taking over the thread.")
                .font(.title3.weight(.medium))
                .foregroundStyle(Color.black.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var installSteps: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Start in Messages")
                .font(.title2.weight(.black))
                .foregroundStyle(.black)

            InstallStep(number: "1", title: "Open Messages", detail: "Start or open a conversation, then open the app drawer.")
            InstallStep(number: "2", title: "Choose #tiny-gifs", detail: "Browse trending GIFs or search GIPHY for the right reaction.")
            InstallStep(number: "3", title: "Add, then Send", detail: "Tap a GIF to add it to the message field, then tap Send normally.")

            Button("Open Settings for the optional keyboard") {
                openURL(URL(string: UIApplication.openSettingsURLString)!)
            }
            .buttonStyle(TinyPrimaryButton())
            .accessibilityHint("Opens iOS Settings. Continue to General, Keyboard, and Keyboards to add #tiny-gifs for supported apps outside Messages.")
        }
    }

    private var giphyExplainer: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Take Tiny GIFs beyond Messages", systemImage: "keyboard")
                .font(.headline.weight(.black))
                .foregroundStyle(.black)
            Text("The keyboard is optional for supported chat apps. It types without Full Access; turn on Full Access when you want to search GIPHY, copy a GIF, and paste it into a conversation.")
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
                Label("#tiny-gifs in Messages", systemImage: "message.fill")
                    .font(.headline.weight(.black))
                    .foregroundStyle(.black)
                Spacer()
                Text("GIPHY SEARCH")
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
            Text("In Messages, search GIPHY, tap a GIF, and it lands in the message field ready to send.")
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
