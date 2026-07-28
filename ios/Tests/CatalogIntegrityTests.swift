import XCTest
import UIKit
import ImageIO
import Messages

final class CatalogIntegrityTests: XCTestCase {
    func testStarterCatalogHasExactlyEightUniqueOwnedReactions() {
        XCTAssertEqual(ReactionCatalog.all.count, 8)
        XCTAssertEqual(Set(ReactionCatalog.all.map(\.id)).count, 8)
        XCTAssertEqual(ReactionCatalog.all.map(\.id), ["lol", "nope", "omg", "brb", "perfect", "yes", "yikes", "tiny-clap"])
    }

    func testTinyGIFAssetsMeetCompactBudgetAndDimensions() throws {
        let bundle = Bundle(for: type(of: self))
        for reaction in ReactionCatalog.all {
            let png = try XCTUnwrap(bundle.url(forResource: reaction.rawValue, withExtension: "png"), "Missing PNG for \(reaction.id)")
            let gif = try XCTUnwrap(bundle.url(forResource: reaction.rawValue, withExtension: "gif"), "Missing GIF for \(reaction.id)")
            XCTAssertLessThan(try dataSize(png), 500_000, "\(reaction.id) PNG exceeds compact-media budget")
            XCTAssertLessThan(try dataSize(gif), 500_000, "\(reaction.id) GIF exceeds compact-media budget")
            let image = try XCTUnwrap(UIImage(contentsOfFile: png.path), "Unable to decode \(reaction.id)")
            XCTAssertEqual(image.size.width, 300, accuracy: 0.1)
            XCTAssertEqual(image.size.height, 300, accuracy: 0.1)
        }
    }

    func testKeyboardCopyDecisionKeepsTypingUsefulWithoutFullAccess() {
        XCTAssertEqual(KeyboardReactionAction.selecting(.lol, hasFullAccess: false), .explainFullAccess)
        XCTAssertEqual(KeyboardReactionAction.selecting(.tinyClap, hasFullAccess: true), .copyLocalGIF(.tinyClap))
    }

    func testMessagesRendererProducesAnimatedStickerAndPreservesFrames() throws {
        let bundle = Bundle(for: type(of: self))
        let sourceURL = try XCTUnwrap(
            bundle.url(forResource: Reaction.lol.rawValue, withExtension: "gif")
        )
        let original = try XCTUnwrap(CGImageSourceCreateWithURL(sourceURL as CFURL, nil))
        let renderedURL = try TinyStickerRenderer.render(
            sourceURL: sourceURL,
            identifier: "unit-test-\(UUID().uuidString)"
        )
        let source = try XCTUnwrap(CGImageSourceCreateWithURL(renderedURL as CFURL, nil))
        let properties = try XCTUnwrap(
            CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        )
        XCTAssertEqual(properties[kCGImagePropertyPixelWidth] as? Int, 128)
        XCTAssertEqual(properties[kCGImagePropertyPixelHeight] as? Int, 128)
        XCTAssertEqual(
            CGImageSourceGetCount(source),
            min(CGImageSourceGetCount(original), 24)
        )
        XCTAssertLessThan(try dataSize(renderedURL), TinyStickerRenderer.maximumFileBytes)

        let sticker = try MSSticker(
            contentsOfFileURL: renderedURL,
            localizedDescription: "Tiny animated GIF"
        )
        XCTAssertEqual(sticker.imageFileURL, renderedURL)
    }

    private func dataSize(_ url: URL) throws -> Int { try Data(contentsOf: url).count }
}
