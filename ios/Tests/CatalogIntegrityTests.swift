import XCTest
import UIKit
import ImageIO
import Messages
import UniformTypeIdentifiers

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

    func testMessagesRendererPreservesEveryAnimationFrame() throws {
        let sourceURL = try animatedGIF(frameCount: 30)
        defer { try? FileManager.default.removeItem(at: sourceURL) }
        let original = try XCTUnwrap(CGImageSourceCreateWithURL(sourceURL as CFURL, nil))
        let renderedURL = try TinyGIFAttachmentRenderer.render(
            sourceURL: sourceURL,
            identifier: "unit-test-\(UUID().uuidString)"
        )
        let source = try XCTUnwrap(CGImageSourceCreateWithURL(renderedURL as CFURL, nil))
        let properties = try XCTUnwrap(
            CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        )
        XCTAssertEqual(properties[kCGImagePropertyPixelWidth] as? Int, 512)
        XCTAssertEqual(properties[kCGImagePropertyPixelHeight] as? Int, 512)
        XCTAssertEqual(CGImageSourceGetCount(source), CGImageSourceGetCount(original))
    }

    @MainActor
    func testMessagesSelectionSendsAttachmentWithoutStaging() async throws {
        let conversation = RecordingTinyGIFConversation()
        let attachmentURL = URL(fileURLWithPath: "/tmp/full-animation.gif")

        try await TinyGIFMessageSender.send(
            attachmentURL,
            filename: "tiny-gifs-example.gif",
            conversation: conversation
        )

        XCTAssertEqual(conversation.sentURL, attachmentURL)
        XCTAssertEqual(conversation.sentFilename, "tiny-gifs-example.gif")
        XCTAssertEqual(conversation.sendCount, 1)
    }

    private func animatedGIF(frameCount: Int) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("tiny-gifs-test-\(UUID().uuidString).gif")
        let destination = try XCTUnwrap(
            CGImageDestinationCreateWithURL(
                url as CFURL,
                UTType.gif.identifier as CFString,
                frameCount,
                nil
            )
        )
        CGImageDestinationSetProperties(destination, [
            kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0]
        ] as CFDictionary)
        for index in 0..<frameCount {
            let image = UIGraphicsImageRenderer(size: CGSize(width: 96, height: 64)).image { context in
                UIColor(
                    hue: CGFloat(index) / CGFloat(frameCount),
                    saturation: 0.9,
                    brightness: 0.9,
                    alpha: 1
                ).setFill()
                context.fill(CGRect(x: 0, y: 0, width: 96, height: 64))
            }
            let frame = try XCTUnwrap(image.cgImage)
            CGImageDestinationAddImage(destination, frame, [
                kCGImagePropertyGIFDictionary: [
                    kCGImagePropertyGIFDelayTime: 0.04,
                    kCGImagePropertyGIFUnclampedDelayTime: 0.04
                ]
            ] as CFDictionary)
        }
        XCTAssertTrue(CGImageDestinationFinalize(destination))
        return url
    }

    private func dataSize(_ url: URL) throws -> Int { try Data(contentsOf: url).count }
}

@MainActor
private final class RecordingTinyGIFConversation: TinyGIFConversationSending {
    private(set) var sentURL: URL?
    private(set) var sentFilename: String?
    private(set) var sendCount = 0

    func sendAttachment(
        _ URL: URL,
        withAlternateFilename filename: String?,
        completionHandler: (@Sendable (Error?) -> Void)?
    ) {
        sentURL = URL
        sentFilename = filename
        sendCount += 1
        completionHandler?(nil)
    }
}
