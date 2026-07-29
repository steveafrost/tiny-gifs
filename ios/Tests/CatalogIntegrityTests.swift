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

    func testMessagesDrawerViewportShowsOneAndHalfRowsAtEveryWidth() {
        for width: CGFloat in [320, 393, 430] {
            let itemSize = TinyGIFDrawerLayout.itemSize(containerWidth: width)
            let viewportHeight = TinyGIFDrawerLayout.viewportHeight(containerWidth: width)
            let visibleRows = (
                viewportHeight
                    - TinyGIFDrawerLayout.sectionInsets.top
                    - TinyGIFDrawerLayout.lineSpacing
            ) / itemSize.height

            XCTAssertEqual(visibleRows, 1.5, accuracy: 0.001)
        }
    }

    func testMessagesRequestGenerationRejectsAnOlderPage() {
        var requests = TinyGIFRequestGeneration()
        let trendingPage = requests.begin()
        let searchPage = requests.begin()

        XCTAssertFalse(requests.isCurrent(trendingPage))
        XCTAssertTrue(requests.isCurrent(searchPage))
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
        XCTAssertEqual(properties[kCGImagePropertyPixelWidth] as? Int, 384)
        XCTAssertEqual(properties[kCGImagePropertyPixelHeight] as? Int, 384)
        XCTAssertEqual(CGImageSourceGetCount(source), CGImageSourceGetCount(original))
    }

    func testMessagesRendererPreservesVariedPerFrameDelays() throws {
        let sourceURL = try animatedGIF(frameDelays: [0.01, 0.03, 0.08, 0.12])
        defer { try? FileManager.default.removeItem(at: sourceURL) }
        let renderedURL = try TinyGIFAttachmentRenderer.render(
            sourceURL: sourceURL,
            identifier: "unit-test-delays-\(UUID().uuidString)"
        )
        defer { try? FileManager.default.removeItem(at: renderedURL) }

        let sourceDelays = try frameDelays(at: sourceURL)
        let renderedDelays = try frameDelays(at: renderedURL)

        XCTAssertLessThan(try XCTUnwrap(sourceDelays.first), 0.02)
        XCTAssertEqual(renderedDelays.count, sourceDelays.count)
        for (rendered, source) in zip(renderedDelays, sourceDelays) {
            XCTAssertEqual(rendered, source, accuracy: 0.000_001)
        }
    }

    func testMessagesRendererConcurrentCallsUseOneValidCachedWinner() async throws {
        let sourceURL = try animatedGIF(frameCount: 12)
        defer { try? FileManager.default.removeItem(at: sourceURL) }
        let identifier = "unit-test-race-\(UUID().uuidString)"

        let renderedURLs = try await withThrowingTaskGroup(
            of: URL.self,
            returning: [URL].self
        ) { group in
            for _ in 0..<12 {
                group.addTask {
                    try TinyGIFAttachmentRenderer.render(
                        sourceURL: sourceURL,
                        identifier: identifier
                    )
                }
            }

            var urls: [URL] = []
            for try await url in group {
                urls.append(url)
            }
            return urls
        }
        let renderedURL = try XCTUnwrap(renderedURLs.first)
        defer { try? FileManager.default.removeItem(at: renderedURL) }

        XCTAssertEqual(Set(renderedURLs).count, 1)
        let rendered = try XCTUnwrap(
            CGImageSourceCreateWithURL(renderedURL as CFURL, nil)
        )
        XCTAssertEqual(CGImageSourceGetCount(rendered), 12)
    }

    func testMessagesRendererAtomicClaimNeverDeletesAnExistingWinner() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("tiny-gifs-claim-\(UUID().uuidString)")
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        defer { try? FileManager.default.removeItem(at: directory) }
        let temporary = directory.appendingPathComponent("contender.gif")
        let destination = directory.appendingPathComponent("winner.gif")
        let winner = Data("valid winner".utf8)
        try Data("late contender".utf8).write(to: temporary)
        try winner.write(to: destination)

        let claimed = try TinyGIFAttachmentRenderer.claimDestination(
            with: temporary,
            at: destination
        )

        XCTAssertEqual(claimed, destination)
        XCTAssertEqual(try Data(contentsOf: destination), winner)
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

    private func animatedGIF(
        frameCount: Int,
        frameDelays: [TimeInterval]? = nil
    ) throws -> URL {
        if let frameDelays {
            XCTAssertEqual(frameDelays.count, frameCount)
        }
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
            let delay = frameDelays?[index] ?? 0.04
            CGImageDestinationAddImage(destination, frame, [
                kCGImagePropertyGIFDictionary: [
                    kCGImagePropertyGIFDelayTime: delay,
                    kCGImagePropertyGIFUnclampedDelayTime: delay
                ]
            ] as CFDictionary)
        }
        XCTAssertTrue(CGImageDestinationFinalize(destination))
        return url
    }

    private func animatedGIF(frameDelays: [TimeInterval]) throws -> URL {
        try animatedGIF(frameCount: frameDelays.count, frameDelays: frameDelays)
    }

    private func frameDelays(at url: URL) throws -> [TimeInterval] {
        let source = try XCTUnwrap(CGImageSourceCreateWithURL(url as CFURL, nil))
        return try (0..<CGImageSourceGetCount(source)).map { index in
            let properties = try XCTUnwrap(
                CGImageSourceCopyPropertiesAtIndex(source, index, nil)
                    as? [CFString: Any]
            )
            let gif = try XCTUnwrap(
                properties[kCGImagePropertyGIFDictionary] as? [CFString: Any]
            )
            let delay = (
                gif[kCGImagePropertyGIFUnclampedDelayTime]
                    ?? gif[kCGImagePropertyGIFDelayTime]
            ) as? NSNumber
            return try XCTUnwrap(delay).doubleValue
        }
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
