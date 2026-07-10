import Foundation

/// Pure decision logic kept separate from UIKit so the privacy boundary is testable.
enum KeyboardReactionAction: Equatable {
    case copyLocalGIF(Reaction)
    case explainFullAccess

    static func selecting(_ reaction: Reaction, hasFullAccess: Bool) -> KeyboardReactionAction {
        hasFullAccess ? .copyLocalGIF(reaction) : .explainFullAccess
    }
}
