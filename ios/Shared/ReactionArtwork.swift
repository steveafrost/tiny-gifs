import SwiftUI
import UIKit

/// The containing app previews the exact owned asset bundled by the extensions.
struct ReactionArtwork: View {
    let reaction: Reaction

    var body: some View {
        Group {
            if let url = ReactionCatalog.resourceURL(for: reaction, fileExtension: "png"), let image = UIImage(contentsOfFile: url.path) {
                Image(uiImage: image).resizable().scaledToFit()
            } else {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title)
                    .foregroundStyle(.red)
                    .accessibilityLabel("Missing \(reaction.localizedDescription) asset")
            }
        }
        .accessibilityLabel(reaction.localizedDescription)
    }
}
