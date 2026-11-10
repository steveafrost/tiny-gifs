import Foundation

/// Pure decision logic kept separate from UIKit so the privacy boundary is testable.
enum KeyboardReactionAction: Equatable {
    case copyLocalGIF(Reaction)
    case explainFullAccess

    static func selecting(_ reaction: Reaction, hasFullAccess: Bool) -> KeyboardReactionAction {
        hasFullAccess ? .copyLocalGIF(reaction) : .explainFullAccess
    }
}

/// Monotonic tokens prevent a slower prior KLIPY search from replacing newer results.
struct KeyboardSearchGeneration {
    private(set) var current: UInt = 0

    mutating func begin() -> UInt {
        current &+= 1
        return current
    }

    func isCurrent(_ search: UInt) -> Bool {
        search == current
    }
}

enum KeyboardLayer: Equatable {
    case letters
    case numbers
    case symbols

    var next: KeyboardLayer {
        switch self {
        case .letters: return .numbers
        case .numbers: return .symbols
        case .symbols: return .letters
        }
    }

    var switchKeyTitle: String {
        switch self {
        case .letters: return "123"
        case .numbers: return "#+="
        case .symbols: return "ABC"
        }
    }

    var showsShift: Bool { self == .letters }
}

/// The keyboard is rendered in the system keyboard's limited height. Keep the
/// character data here so the three layers stay testable without UIKit.
enum KeyboardLayout {
    static let letters: [[String]] = [
        ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
        ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
        ["z", "x", "c", "v", "b", "n", "m"]
    ]

    static let numbers: [[String]] = [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
        ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""],
        [".", ",", "?", "!", "'", "#", "%", "*", "+", "="]
    ]

    static let symbols: [[String]] = [
        ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="],
        ["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "•"],
        [".", ",", "?", "!", "'", "\"", "-", ":", ";", "/"]
    ]

    static func rows(for layer: KeyboardLayer) -> [[String]] {
        switch layer {
        case .letters: return letters
        case .numbers: return numbers
        case .symbols: return symbols
        }
    }

    static func character(for key: String, layer: KeyboardLayer, shifted: Bool) -> String {
        guard layer == .letters, shifted else { return key }
        return key.uppercased()
    }
}
