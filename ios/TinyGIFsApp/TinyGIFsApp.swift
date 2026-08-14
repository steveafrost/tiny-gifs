import SwiftUI
import UIKit

@main
struct TinyGIFsApp: App {
    var body: some Scene {
        WindowGroup {
            TinyGIFsSetupView()
                .preferredColorScheme(.light)
        }
    }
}

/// The containing app is a focused setup surface. The live GIPHY catalog and
/// one-tap send interaction live in the Messages extension, not in a second,
/// competing GIF browser here.
private struct TinyGIFsSetupView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                header
                MessagesPathPreview()
                primaryPath
                keyboardPath
                privacyNote
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)
            .padding(.bottom, 36)
        }
        .background(Color.canvas.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 11) {
            Text("tiny gifs")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.ink)

            Text("Messages first.")
                .font(.system(size: 40, weight: .bold))
                .tracking(-1.1)
                .foregroundStyle(Color.ink)

            Text("Tiny GIFs is already ready in the Messages app drawer. Search the real GIPHY library there, then tap once to send a compact animated GIF.")
                .font(.body)
                .foregroundStyle(Color.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private var primaryPath: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Use it in Messages")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.ink)
                Spacer()
                Text("PRIMARY")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color.messageBlue)
            }

            SetupStep(number: "1", title: "Open a conversation", detail: "Tap the plus button beside the message field, then choose tiny gifs from the app drawer.")
            SetupStep(number: "2", title: "Find the right GIF", detail: "Browse trending results or search GIPHY without leaving the conversation.")
            SetupStep(number: "3", title: "Tap once to send", detail: "Tiny GIFs prepares a consistent 192 × 192 animated attachment and sends it immediately.")

            Button("Open Messages") {
                openURL(URL(string: "sms:")!)
            }
            .buttonStyle(TinyPrimaryButton())
            .accessibilityHint("Opens Messages so you can use the Tiny GIFs app drawer.")
        }
        .padding(18)
        .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.rule, lineWidth: 1))
    }

    private var keyboardPath: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Optional: add the keyboard later")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.ink)
                Spacer()
                Image(systemName: "keyboard")
                    .foregroundStyle(Color.messageBlue)
            }

            Text("Use the keyboard only in supported chat apps when you want to search GIPHY, copy a GIF, and paste it yourself. It is not required for Messages.")
                .font(.subheadline)
                .foregroundStyle(Color.muted)
                .fixedSize(horizontal: false, vertical: true)

            Divider()

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "lock.fill")
                    .font(.footnote)
                    .foregroundStyle(Color.messageBlue)
                Text("Full Access enables GIPHY search and copying. Tiny GIFs does not record what you type.")
                    .font(.footnote)
                    .foregroundStyle(Color.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button("Open Settings") {
                openURL(URL(string: UIApplication.openSettingsURLString)!)
            }
            .buttonStyle(TinySecondaryButton())
            .accessibilityHint("Opens the Tiny GIFs settings page. Add the keyboard from Settings when you need the copy-and-paste path.")
        }
        .padding(18)
        .background(Color.secondarySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var privacyNote: some View {
        Text("Powered by GIPHY. No account, profile, analytics SDK, or advertising SDK.")
            .font(.footnote)
            .foregroundStyle(Color.tertiary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

private struct SetupStep: View {
    let number: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 13) {
            Text(number)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.messageBlue)
                .frame(width: 24, height: 24)
                .background(Color.messageBlue.opacity(0.1), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.ink)
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(Color.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 2)
    }
}

private struct MessagesPathPreview: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Messages")
                    .font(.caption.weight(.semibold))
                Spacer()
                Image(systemName: "ellipsis.circle.fill")
                    .foregroundStyle(Color.messageBlue)
            }
            .padding(.horizontal, 16)
            .frame(height: 44)
            .background(.white)

            VStack(alignment: .leading, spacing: 13) {
                Text("Need a reaction for that.")
                    .font(.footnote)
                    .foregroundStyle(Color.ink)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 8)
                    .background(Color.incomingBubble, in: RoundedRectangle(cornerRadius: 13, style: .continuous))

                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                    Text("Search GIPHY")
                    Spacer()
                    Text("tiny gifs")
                        .fontWeight(.semibold)
                }
                .font(.caption)
                .foregroundStyle(Color.white.opacity(0.88))
                .padding(.horizontal, 12)
                .frame(height: 38)
                .background(Color.drawer, in: RoundedRectangle(cornerRadius: 9, style: .continuous))

                Text("Real GIF results load in the drawer. Tap one to send.")
                    .font(.caption2)
                    .foregroundStyle(Color.white.opacity(0.66))
            }
            .padding(16)
            .background(Color.drawer)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.rule, lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Messages preview. Tiny GIFs searches real GIPHY GIFs in the app drawer and sends a selection with one tap.")
    }
}

private struct TinyPrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: 48)
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .background(Color.messageBlue.opacity(configuration.isPressed ? 0.82 : 1), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct TinySecondaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: 44)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color.messageBlue)
            .background(.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.rule, lineWidth: 1))
            .opacity(configuration.isPressed ? 0.72 : 1)
    }
}

private extension Color {
    static let canvas = Color(red: 0.96, green: 0.96, blue: 0.97)
    static let secondarySurface = Color(red: 0.92, green: 0.95, blue: 0.99)
    static let ink = Color(red: 0.11, green: 0.11, blue: 0.12)
    static let muted = Color(red: 0.33, green: 0.33, blue: 0.36)
    static let tertiary = Color(red: 0.45, green: 0.45, blue: 0.48)
    static let rule = Color.black.opacity(0.10)
    static let messageBlue = Color(red: 0.00, green: 0.48, blue: 1.00)
    static let incomingBubble = Color(red: 0.91, green: 0.91, blue: 0.92)
    static let drawer = Color(red: 0.14, green: 0.14, blue: 0.15)
}
