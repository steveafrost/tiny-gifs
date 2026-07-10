import Foundation

/// The owned, offline starter catalog shared by the app, Messages extension, and keyboard.
public enum Reaction: String, CaseIterable, Identifiable {
    case lol
    case nope
    case omg
    case brb
    case perfect
    case yes
    case yikes
    case tinyClap = "tiny-clap"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .tinyClap: return "tiny clap"
        default: return rawValue
        }
    }

    public var localizedDescription: String {
        "#tiny-gifs (displayName) reaction"
    }

    public var pngFilename: String { "(rawValue).png" }
    public var gifFilename: String { "(rawValue).gif" }
}

public enum ReactionCatalog {
    public static let all = Reaction.allCases

    public static func resourceURL(for reaction: Reaction, fileExtension: String, bundle: Bundle = .main) -> URL? {
        bundle.url(forResource: reaction.rawValue, withExtension: fileExtension)
    }
}
