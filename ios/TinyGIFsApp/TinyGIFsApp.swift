import SwiftUI
import UIKit

@main
struct TinyGIFsApp: App {
    var body: some Scene {
        WindowGroup {
            TinyGIFsSetupView()
        }
    }
}

/// The containing app orients a new customer around the primary product loop.
/// Real GIPHY discovery and sending stay in the Messages extension, where they
/// belong, rather than competing with that experience in a second GIF browser.
private struct TinyGIFsSetupView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                primarySurface
                quickStart
                keyboardPath
                privacyNote
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 36)
        }
        .background(Color.canvas.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text("tiny gifs")
                    .font(.system(size: 17, weight: .semibold))
                Text("MESSAGES EXTENSION")
                    .font(.caption2.weight(.bold))
                    .tracking(0.7)
                    .foregroundStyle(Color.muted)
            }
            .foregroundStyle(Color.ink)

            Text("Use Tiny GIFs in Messages.")
                .font(.system(size: 36, weight: .bold))
                .tracking(-1.1)
                .foregroundStyle(Color.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text("The full GIPHY library lives beside the message field. Search, tap, and keep talking.")
                .font(.body)
                .foregroundStyle(Color.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private var primarySurface: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Ready when you are")
                        .font(.headline.weight(.semibold))
                    Text("No setup is required for the one-tap Messages path.")
                        .font(.subheadline)
                        .foregroundStyle(Color.mutedOnDark)
                }
                Spacer()
                Text("IN MESSAGES")
                    .font(.caption2.weight(.bold))
                    .tracking(0.6)
                    .foregroundStyle(Color.messageBlue)
            }
            .foregroundStyle(.white)

            MessagesPathPreview()

            Button("Open Messages") {
                openURL(URL(string: "sms:")!)
            }
            .buttonStyle(TinyPrimaryButton())
            .accessibilityHint("Opens Messages so you can use the Tiny GIFs app drawer.")
        }
        .padding(16)
        .background(Color.drawer, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .accessibilityElement(children: .contain)
    }

    private var quickStart: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("A short path, in the place you already message")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.ink)
                Spacer()
                Text("01—03")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color.muted)
            }
            .padding(.bottom, 8)

            SetupStep(number: "01", title: "Open a conversation", detail: "Tap the plus button, then choose tiny gifs from the app drawer.")
            SetupStep(number: "02", title: "Search GIPHY in the drawer", detail: "Browse trending GIFs or ask for the reaction you actually mean.")
            SetupStep(number: "03", title: "Tap once to send", detail: "Tiny GIFs prepares a compact animated attachment and puts it in the thread.")
        }
        .padding(16)
        .background(Color.cardSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.rule, lineWidth: 1))
    }

    private var keyboardPath: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Optional keyboard")
                        .font(.headline.weight(.semibold))
                    Text("For supported chat apps outside Messages")
                        .font(.subheadline)
                        .foregroundStyle(Color.muted)
                }
                Spacer()
                Image(systemName: "keyboard")
                    .foregroundStyle(Color.messageBlue)
            }

            Text("Add it only when you want to search GIPHY, copy a GIF, and paste it yourself. It is never needed for the one-tap Messages path.")
                .font(.footnote)
                .foregroundStyle(Color.muted)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .top, spacing: 9) {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundStyle(Color.messageBlue)
                Text("Full Access enables search and copying. Tiny GIFs does not record what you type.")
                    .font(.footnote)
                    .foregroundStyle(Color.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button("Open Settings") {
                openURL(URL(string: UIApplication.openSettingsURLString)!)
            }
            .buttonStyle(TinySecondaryButton())
            .accessibilityHint("Opens Tiny GIFs settings. Add the keyboard only when you need the copy-and-paste path.")
        }
        .padding(16)
        .background(Color.secondarySurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var privacyNote: some View {
        Text("Powered by GIPHY. No account, profile, analytics SDK, or advertising SDK.")
            .font(.footnote)
            .foregroundStyle(Color.tertiary)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 2)
    }
}

private struct SetupStep: View {
    let number: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color.messageBlue)
                .frame(width: 31, alignment: .leading)

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
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) { Divider().opacity(number == "03" ? 0 : 1) }
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
            .padding(.horizontal, 14)
            .frame(height: 40)
            .background(Color.previewMessageSurface)

            VStack(alignment: .leading, spacing: 12) {
                Text("Need a reaction for that.")
                    .font(.footnote)
                    .foregroundStyle(Color.ink)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color.incomingBubble, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                    Text("Search GIPHY")
                    Spacer()
                    Text("tiny gifs")
                        .fontWeight(.semibold)
                }
                .font(.caption)
                .foregroundStyle(Color.white.opacity(0.88))
                .padding(.horizontal, 11)
                .frame(height: 36)
                .background(Color.previewDrawer, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                Text("Real GIF results load in the drawer. Tap one to send.")
                    .font(.caption2)
                    .foregroundStyle(Color.white.opacity(0.62))
            }
            .padding(14)
            .background(Color.previewDrawer)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.white.opacity(0.16), lineWidth: 1))
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
            .background(Color.cardSurface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.rule, lineWidth: 1))
            .opacity(configuration.isPressed ? 0.72 : 1)
    }
}

private extension Color {
    static let canvas = Color(uiColor: .systemGroupedBackground)
    static let cardSurface = Color(uiColor: .secondarySystemGroupedBackground)
    static let secondarySurface = Color(uiColor: .tertiarySystemGroupedBackground)
    static let previewMessageSurface = Color(uiColor: .systemBackground)
    static let ink = Color(uiColor: .label)
    static let muted = Color(uiColor: .secondaryLabel)
    static let tertiary = Color(uiColor: .tertiaryLabel)
    static let mutedOnDark = Color(red: 0.70, green: 0.70, blue: 0.73)
    static let rule = Color(uiColor: .separator)
    static let messageBlue = Color(uiColor: .systemBlue)
    static let incomingBubble = Color(uiColor: .secondarySystemFill)
    static let drawer = Color(red: 0.11, green: 0.11, blue: 0.12)
    static let previewDrawer = Color(red: 0.17, green: 0.17, blue: 0.18)
}
