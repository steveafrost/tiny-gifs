import Foundation

/// Pure decision logic kept separate from UIKit so the privacy boundary is testable.
enum KeyboardReactionAction: Equatable {
    case copyLocalGIF(Reaction)
    case explainFullAccess

    static func selecting(_ reaction: Reaction, hasFullAccess: Bool) -> KeyboardReactionAction {
        hasFullAccess ? .copyLocalGIF(reaction) : .explainFullAccess
    }
}

/// Monotonic tokens prevent a slower prior GIPHY search from replacing newer results.
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
