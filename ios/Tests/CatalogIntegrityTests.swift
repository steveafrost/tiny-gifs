import XCTest
import UIKit
import ImageIO
import Messages
import UniformTypeIdentifiers

final class CatalogIntegrityTests: XCTestCase {
    func testKlipyDecodesProviderPagingAndPreservesDeliveryURLs() throws {
        let data = Data(#"{"result":true,"data":{"has_next":true,"data":[{"id":6914457558367152,"slug":"hello","type":"gif","title":"Hello","file":{"sm":{"gif":{"url":"https://static.klipy.com/preview.gif?delivery=keep"}},"hd":{"gif":{"url":"https://static.klipy.com/full.gif?delivery=keep"}}}}]}}"#.utf8)
        let page = try JSONDecoder().decode(KlipyPage.self, from: data)
        XCTAssertTrue(page.hasNext)
        XCTAssertEqual(page.items.first?.id, "6914457558367152")
        XCTAssertEqual(page.items.first?.tinyPreviewURL.absoluteString, "https://static.klipy.com/preview.gif?delivery=keep")
        XCTAssertEqual(page.items.first?.tinyGIFURL.absoluteString, "https://static.klipy.com/full.gif?delivery=keep")
        XCTAssertThrowsError(try JSONDecoder().decode(KlipyPage.self, from: Data(#"{"result":false,"data":{"has_next":false,"data":[]}}"#.utf8)))
    }

    func testKlipyInternalTestingDoesNotRepresentProductionApproval() {
        XCTAssertFalse(KlipyService.mediaProcessingEnabled(approved: false, internalTesting: false))
        XCTAssertTrue(KlipyService.mediaProcessingEnabled(approved: false, internalTesting: true))
        XCTAssertTrue(KlipyService.mediaProcessingEnabled(approved: true, internalTesting: false))
    }

    func testKlipyDoesNotProcessMediaBeforeApproval() async throws {
        XCTAssertFalse(KlipyService.isMediaProcessingApproved)
        let data = Data(#"{"id":"1","slug":"hello","file":{"hd":{"gif":{"url":"https://static.klipy.com/full.gif"}}}}"#.utf8)
        let gif = try JSONDecoder().decode(KlipyGIF.self, from: data)
        do {
            _ = try await KlipyService.localGIFURL(for: gif)
            XCTFail("Unapproved media processing must not start a download")
        } catch KlipyServiceError.sharingUnavailable {
            // Expected: the approval gate rejects before making a network request.
        }
    }

    func testKlipyRequestPreservesSearchAndUsesProviderPageNumbers() throws {
        let url = KlipyService.requestURL(apiKey: "test-key", query: " hello & bye! ", limit: 24, page: 2)
        let query = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems)
        XCTAssertEqual(url.path, "/api/v1/test-key/gifs/search")
        XCTAssertEqual(query.first { $0.name == "q" }?.value, " hello & bye! ")
        XCTAssertEqual(query.first { $0.name == "page" }?.value, "2")
        XCTAssertEqual(query.first { $0.name == "content_filter" }?.value, "high")
    }

    func testStarterCatalogHasExactlyEightUniqueOwnedReactions() {
        XCTAssertEqual(ReactionCatalog.all.count, 8)
        XCTAssertEqual(Set(ReactionCatalog.all.map(\.id)).count, 8)
        XCTAssertEqual(ReactionCatalog.all.map(\.id), ["lol", "nope", "omg", "brb", "perfect", "yes", "yikes", "tiny-clap"])
    }

    func testStarterReactionDescriptionsAndFilenamesUseTheReactionName() {
        XCTAssertEqual(Reaction.tinyClap.localizedDescription, "#tiny-gifs tiny clap reaction")
        XCTAssertEqual(Reaction.tinyClap.pngFilename, "tiny-clap.png")
        XCTAssertEqual(Reaction.tinyClap.gifFilename, "tiny-clap.gif")
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

    func testKeyboardSearchGenerationRejectsAnOlderResponse() {
        var searches = KeyboardSearchGeneration()
        let firstSearch = searches.begin()
        let secondSearch = searches.begin()

        XCTAssertFalse(searches.isCurrent(firstSearch))
        XCTAssertTrue(searches.isCurrent(secondSearch))
    }

    func testMessagesDrawerRequestsExpandedPresentationWithoutAPartialRowLimit() {
        XCTAssertEqual(TinyGIFDrawerLayout.presentationStyle, .expanded)
    }

    func testMessagesDrawerDismissesToTheKeyboardAfterASuccessfulGIFSend() {
        XCTAssertTrue(TinyGIFDrawerLayout.shouldDismissToKeyboardAfterSend(succeeded: true))
        XCTAssertFalse(TinyGIFDrawerLayout.shouldDismissToKeyboardAfterSend(succeeded: false))
    }

    func testMessagesDrawerPreventsDuplicateSendsAndAllowsRetryAfterFailure() {
        var sendState = TinyGIFSendState()

        XCTAssertTrue(sendState.begin())
        XCTAssertFalse(sendState.begin())

        sendState.finish()
        XCTAssertTrue(sendState.begin())
    }

    func testMessagesRequestGenerationRejectsAnOlderPage() {
        var requests = TinyGIFRequestGeneration()
        let trendingPage = requests.begin()
        let searchPage = requests.begin()

        XCTAssertFalse(requests.isCurrent(trendingPage))
        XCTAssertTrue(requests.isCurrent(searchPage))
    }

    func testMessagesRendererUsesA288PixelStickerCanvasForAConsistentSmallFootprint() throws {
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
        XCTAssertEqual(TinyGIFAttachmentRenderer.canvasPixels, 288)
        XCTAssertEqual(properties[kCGImagePropertyPixelWidth] as? Int, 288)
        XCTAssertEqual(properties[kCGImagePropertyPixelHeight] as? Int, 288)
        XCTAssertEqual(CGImageSourceGetCount(source), CGImageSourceGetCount(original))
        XCTAssertLessThanOrEqual(try dataSize(renderedURL), TinyGIFAttachmentRenderer.maximumFileBytes)
        XCTAssertNoThrow(try MSSticker(contentsOfFileURL: renderedURL, localizedDescription: "Tiny GIF"))
    }

    func testMessagesRendererUsesANewCacheVersionForThe288PixelStickerCanvas() throws {
        let sourceURL = try animatedGIF(frameCount: 1)
        defer { try? FileManager.default.removeItem(at: sourceURL) }

        let renderedURL = try TinyGIFAttachmentRenderer.render(
            sourceURL: sourceURL,
            identifier: "unit-test-cache-version-\(UUID().uuidString)"
        )
        defer { try? FileManager.default.removeItem(at: renderedURL) }

        XCTAssertTrue(renderedURL.lastPathComponent.contains("sticker-v16.gif"))
    }

    func testMessagesRendererLetterboxesSquareWideAndTallGIFsInsideCompactStickerContainers() throws {
        let cases: [(source: CGSize, expected: CGSize)] = [
            (CGSize(width: 200, height: 200), CGSize(width: 288, height: 288)),
            (CGSize(width: 400, height: 200), CGSize(width: 288, height: 144)),
            (CGSize(width: 200, height: 400), CGSize(width: 144, height: 288))
        ]

        for testCase in cases {
            let sourceURL = try animatedGIF(frameCount: 1, size: testCase.source)
            defer { try? FileManager.default.removeItem(at: sourceURL) }
            let renderedURL = try TinyGIFAttachmentRenderer.render(
                sourceURL: sourceURL,
                identifier: "unit-test-aspect-\(UUID().uuidString)"
            )
            defer { try? FileManager.default.removeItem(at: renderedURL) }

            let rendered = try XCTUnwrap(CGImageSourceCreateWithURL(renderedURL as CFURL, nil))
            let properties = try XCTUnwrap(
                CGImageSourceCopyPropertiesAtIndex(rendered, 0, nil) as? [CFString: Any]
            )
            let content = TinyGIFAttachmentRenderer.normalizedContentRect(for: testCase.source)

            XCTAssertEqual(properties[kCGImagePropertyPixelWidth] as? Int, 288)
            XCTAssertEqual(properties[kCGImagePropertyPixelHeight] as? Int, 288)
            XCTAssertEqual(content.size, testCase.expected)
            XCTAssertEqual(content.width / content.height, testCase.source.width / testCase.source.height, accuracy: 0.001)
            XCTAssertEqual(content.midX, 144, accuracy: 0.5)
            XCTAssertEqual(content.midY, 144, accuracy: 0.5)
        }
    }

    func testMessagesRendererRepeatedCallsReturnTheSameNormalizedAttachment() throws {
        let sourceURL = try animatedGIF(frameCount: 1, size: CGSize(width: 400, height: 200))
        defer { try? FileManager.default.removeItem(at: sourceURL) }
        let identifier = "unit-test-repeat-\(UUID().uuidString)"

        let first = try TinyGIFAttachmentRenderer.render(sourceURL: sourceURL, identifier: identifier)
        defer { try? FileManager.default.removeItem(at: first) }
        let firstData = try Data(contentsOf: first)
        let second = try TinyGIFAttachmentRenderer.render(sourceURL: sourceURL, identifier: identifier)

        XCTAssertEqual(second, first)
        XCTAssertEqual(try Data(contentsOf: second), firstData)
    }

    func testMessagesRendererPreservesVariedPerFrameDelays() throws {
        let sourceURL = try animatedGIF(frameDelays: [0.01, 0.03, 0.08, 0.12] + (0..<26).map { Double($0 % 5 + 1) * 0.03 })
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

    func testMessagesRendererKeepsAllFramesOfAComplexGIFWhenCompressionFits() throws {
        let sourceURL = try complexAnimatedGIF(frameCount: 40)
        defer { try? FileManager.default.removeItem(at: sourceURL) }
        let renderedURL = try TinyGIFAttachmentRenderer.render(
            sourceURL: sourceURL, identifier: "unit-test-palette-\(UUID().uuidString)"
        )
        defer { try? FileManager.default.removeItem(at: renderedURL) }
        let output = try XCTUnwrap(CGImageSourceCreateWithURL(renderedURL as CFURL, nil))
        XCTAssertEqual(CGImageSourceGetCount(output), 40)
        XCTAssertLessThanOrEqual(try dataSize(renderedURL), TinyGIFAttachmentRenderer.maximumFileBytes)
    }

    func testMessagesFrameReductionIncludesTheEnding() {
        for frameCount in [3, 18, 100, 301] {
            for maximumFrames in [2, 4, 10, 30] {
                let indices = TinyGIFAttachmentRenderer.sampledFrameIndices(
                    frameCount: frameCount, maximumFrames: maximumFrames
                )
                XCTAssertEqual(indices.first, 0)
                XCTAssertEqual(indices.last, frameCount - 1)
                XCTAssertEqual(Set(indices).count, indices.count)
                XCTAssertEqual(indices, indices.sorted())
            }
        }
    }

    func testMessagesRendererPreservesTheFullTimelineWhenReducingFrames() throws {
        let sourceURL = try complexAnimatedGIF(frameCount: 120)
        defer { try? FileManager.default.removeItem(at: sourceURL) }
        let renderedURL = try TinyGIFAttachmentRenderer.render(
            sourceURL: sourceURL,
            identifier: "unit-test-long-\(UUID().uuidString)"
        )
        defer { try? FileManager.default.removeItem(at: renderedURL) }
        let originalDelays = try frameDelays(at: sourceURL)
        let outputDelays = try frameDelays(at: renderedURL)
        XCTAssertGreaterThan(outputDelays.count, 1)
        XCTAssertLessThan(outputDelays.count, originalDelays.count)
        XCTAssertEqual(outputDelays.reduce(0, +), originalDelays.reduce(0, +), accuracy: 0.001)
        XCTAssertEqual(try XCTUnwrap(outputDelays.last), try XCTUnwrap(originalDelays.last), accuracy: 0.001)
        let output = try XCTUnwrap(CGImageSourceCreateWithURL(renderedURL as CFURL, nil))
        let lastFrame = try XCTUnwrap(CGImageSourceCreateImageAtIndex(output, outputDelays.count - 1, nil))
        let center = try XCTUnwrap(lastFrame.cropping(to: CGRect(x: 144, y: 144, width: 1, height: 1)))
        let context = try XCTUnwrap(CGContext(data: nil, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue))
        context.draw(center, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        let pixel = try XCTUnwrap(context.data).assumingMemoryBound(to: UInt8.self)
        XCTAssertEqual(Array(UnsafeBufferPointer(start: pixel, count: 4)), [255, 255, 255, 255], "The distinctive final frame must survive fallback encoding")
        XCTAssertLessThanOrEqual(try dataSize(renderedURL), TinyGIFAttachmentRenderer.maximumFileBytes)
        XCTAssertNoThrow(try MSSticker(contentsOfFileURL: renderedURL, localizedDescription: "Long GIF"))
    }

    func testMessagesRendererKeepsAComplexGIFAnimatedWithinStickerBudget() throws {
        let sourceURL = try complexAnimatedGIF(frameCount: 18)
        defer { try? FileManager.default.removeItem(at: sourceURL) }
        let renderedURL = try TinyGIFAttachmentRenderer.render(
            sourceURL: sourceURL,
            identifier: "unit-test-complex-\(UUID().uuidString)"
        )
        defer { try? FileManager.default.removeItem(at: renderedURL) }

        let rendered = try XCTUnwrap(CGImageSourceCreateWithURL(renderedURL as CFURL, nil))
        let properties = try XCTUnwrap(
            CGImageSourceCopyPropertiesAtIndex(rendered, 0, nil) as? [CFString: Any]
        )

        XCTAssertEqual(properties[kCGImagePropertyPixelWidth] as? Int, 288)
        XCTAssertEqual(properties[kCGImagePropertyPixelHeight] as? Int, 288)
        XCTAssertGreaterThan(CGImageSourceGetCount(rendered), 1)
        XCTAssertLessThanOrEqual(try dataSize(renderedURL), TinyGIFAttachmentRenderer.maximumFileBytes)
        XCTAssertNoThrow(try MSSticker(contentsOfFileURL: renderedURL, localizedDescription: "Complex GIF"))
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
        XCTAssertGreaterThan(CGImageSourceGetCount(rendered), 1)
        XCTAssertLessThanOrEqual(CGImageSourceGetCount(rendered), 12)
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
    func testPreparedSelectionCallsSendBeforeReturningToTheRunLoop() throws {
        let stickerURL = try animatedGIF(frameCount: 1)
        defer { try? FileManager.default.removeItem(at: stickerURL) }
        let conversation = RecordingTinyGIFConversation()
        TinyGIFMessageSender.startSend(
            stickerURL: stickerURL, localizedDescription: "Prepared GIF", conversation: conversation,
            completionHandler: nil
        )
        XCTAssertEqual(conversation.sendCount, 1, "Sending must begin synchronously in the tap callback")
        XCTAssertEqual(conversation.sentSticker?.imageFileURL, stickerURL)
    }

    @MainActor
    func testMessagesSelectionSendsACompactStickerImmediately() async throws {
        let conversation = RecordingTinyGIFConversation()
        let stickerURL = try animatedGIF(frameCount: 1, size: CGSize(width: 288, height: 288))
        defer { try? FileManager.default.removeItem(at: stickerURL) }

        try await TinyGIFMessageSender.send(
            stickerURL: stickerURL,
            localizedDescription: "Example GIF",
            conversation: conversation
        )

        XCTAssertEqual(conversation.sentSticker?.imageFileURL, stickerURL)
        XCTAssertEqual(conversation.sentSticker?.localizedDescription, "Example GIF")
        XCTAssertEqual(conversation.sendCount, 1)
    }

    @MainActor
    func testMessagesSendPathSendsTheNormalizedStickerInsteadOfTheDrawerSource() async throws {
        let sourceURL = try animatedGIF(frameCount: 1, size: CGSize(width: 400, height: 200))
        defer { try? FileManager.default.removeItem(at: sourceURL) }
        let attachmentURL = try TinyGIFAttachmentRenderer.render(
            sourceURL: sourceURL,
            identifier: "unit-test-send-\(UUID().uuidString)"
        )
        defer { try? FileManager.default.removeItem(at: attachmentURL) }
        let conversation = RecordingTinyGIFConversation()

        try await TinyGIFMessageSender.send(
            stickerURL: attachmentURL,
            localizedDescription: "Example GIF",
            conversation: conversation
        )

        XCTAssertEqual(conversation.sentSticker?.imageFileURL, attachmentURL)
        XCTAssertNotEqual(conversation.sentSticker?.imageFileURL, sourceURL)
        let rendered = try XCTUnwrap(CGImageSourceCreateWithURL(attachmentURL as CFURL, nil))
        let properties = try XCTUnwrap(
            CGImageSourceCopyPropertiesAtIndex(rendered, 0, nil) as? [CFString: Any]
        )
        XCTAssertEqual(properties[kCGImagePropertyPixelWidth] as? Int, 288)
        XCTAssertEqual(properties[kCGImagePropertyPixelHeight] as? Int, 288)
        XCTAssertLessThanOrEqual(try dataSize(attachmentURL), TinyGIFAttachmentRenderer.maximumFileBytes)
    }

    private func animatedGIF(
        frameCount: Int,
        frameDelays: [TimeInterval]? = nil,
        size: CGSize = CGSize(width: 96, height: 64)
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
            let image = UIGraphicsImageRenderer(size: size).image { context in
                UIColor(
                    hue: CGFloat(index) / CGFloat(frameCount),
                    saturation: 0.9,
                    brightness: 0.9,
                    alpha: 1
                ).setFill()
                context.fill(CGRect(origin: .zero, size: size))
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

    private func complexAnimatedGIF(frameCount: Int) throws -> URL {
        let size = CGSize(width: 320, height: 320)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("tiny-gifs-complex-test-\(UUID().uuidString).gif")
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

        let gridCount = 20
        let cellSize = size.width / CGFloat(gridCount)
        for frameIndex in 0..<frameCount {
            let image = UIGraphicsImageRenderer(size: size).image { context in
                for row in 0..<gridCount {
                    for column in 0..<gridCount {
                        let seed = (row * 37 + column * 19 + frameIndex * 13) % 256
                        UIColor(
                            hue: CGFloat(seed) / 256,
                            saturation: 0.55 + CGFloat((row + frameIndex) % 4) * 0.1,
                            brightness: 0.55 + CGFloat((column + frameIndex) % 4) * 0.1,
                            alpha: 1
                        ).setFill()
                        context.fill(CGRect(
                            x: CGFloat(column) * cellSize,
                            y: CGFloat(row) * cellSize,
                            width: cellSize,
                            height: cellSize
                        ))
                    }
                }
                if frameIndex == frameCount - 1 {
                    UIColor.white.setFill()
                    context.fill(CGRect(origin: .zero, size: size))
                }
            }
            CGImageDestinationAddImage(destination, try XCTUnwrap(image.cgImage), [
                kCGImagePropertyGIFDictionary: [
                    kCGImagePropertyGIFDelayTime: 0.04,
                    kCGImagePropertyGIFUnclampedDelayTime: 0.04
                ]
            ] as CFDictionary)
        }
        XCTAssertTrue(CGImageDestinationFinalize(destination))
        return url
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
    private(set) var sentSticker: MSSticker?
    private(set) var sendCount = 0

    func send(
        _ sticker: MSSticker,
        completionHandler: (@Sendable (Error?) -> Void)?
    ) {
        sentSticker = sticker
        sendCount += 1
        completionHandler?(nil)
    }
}
