import ImageIO
import Messages
import UIKit
import UniformTypeIdentifiers

@MainActor
protocol TinyGIFConversationSending: AnyObject {
    func insert(
        _ sticker: MSSticker,
        completionHandler: (@Sendable (Error?) -> Void)?
    )
}

extension MSConversation: TinyGIFConversationSending {}

@MainActor
enum TinyGIFMessageSender {
    static func insert(
        stickerURL: URL,
        localizedDescription: String,
        conversation: TinyGIFConversationSending
    ) async throws {
        let sticker = try MSSticker(
            contentsOfFileURL: stickerURL,
            localizedDescription: localizedDescription
        )
        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Void, Error>) in
            conversation.insert(sticker) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}

/// Builds a compact animated sticker whose file dimensions control its Messages
/// transcript footprint. Regular attachments render as large media bubbles even
/// when their pixel dimensions are small, so outgoing GIFs must use `MSSticker`.
enum TinyGIFAttachmentRenderer {
    static let canvasPixels: CGFloat = 320
    static let maximumFileBytes = 490_000

    private struct RenderAttempt {
        let visiblePixels: CGFloat
        let maximumFrames: Int
    }

    static func render(sourceURL: URL, identifier: String) throws -> URL {
        let fileManager = FileManager.default
        let cacheDirectory = try fileManager
            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("TinyGIFAttachments", isDirectory: true)
        try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

        let safeIdentifier = identifier.replacingOccurrences(
            of: "[^A-Za-z0-9_-]",
            with: "-",
            options: .regularExpression
        )
        let destination = cacheDirectory.appendingPathComponent(
            "\(safeIdentifier)-sticker-v13.gif"
        )
        if let size = fileSize(at: destination), size <= maximumFileBytes {
            return destination
        }

        guard let source = CGImageSourceCreateWithURL(sourceURL as CFURL, nil),
              CGImageSourceGetCount(source) > 0 else {
            throw TinyGIFAttachmentRendererError.unreadableSource
        }

        let attempts = [
            RenderAttempt(visiblePixels: 320, maximumFrames: 10),
            RenderAttempt(visiblePixels: 320, maximumFrames: 8),
            RenderAttempt(visiblePixels: 320, maximumFrames: 6),
            RenderAttempt(visiblePixels: 320, maximumFrames: 4),
            RenderAttempt(visiblePixels: 320, maximumFrames: 2)
        ]

        for (attemptIndex, attempt) in attempts.enumerated() {
            let temporary = cacheDirectory.appendingPathComponent(
                "\(safeIdentifier)-sticker-v13-\(attemptIndex)-\(UUID().uuidString)-temporary.gif"
            )
            defer { try? fileManager.removeItem(at: temporary) }
            try writeGIF(
                source: source,
                destination: temporary,
                visiblePixels: attempt.visiblePixels,
                maximumFrames: attempt.maximumFrames
            )
            guard let size = fileSize(at: temporary), size <= maximumFileBytes else {
                continue
            }
            return try claimDestination(
                with: temporary,
                at: destination,
                fileManager: fileManager
            )
        }

        throw TinyGIFAttachmentRendererError.fileTooLarge
    }

    static func claimDestination(
        with temporary: URL,
        at destination: URL,
        fileManager: FileManager = .default
    ) throws -> URL {
        do {
            try fileManager.linkItem(at: temporary, to: destination)
        } catch {
            guard fileManager.fileExists(atPath: destination.path) else {
                throw error
            }
        }
        return destination
    }

    private static func writeGIF(
        source: CGImageSource,
        destination: URL,
        visiblePixels: CGFloat,
        maximumFrames: Int
    ) throws {
        let sourceFrameCount = CGImageSourceGetCount(source)
        let frameIndices = sampledFrameIndices(
            frameCount: sourceFrameCount,
            maximumFrames: maximumFrames
        )
        guard let output = CGImageDestinationCreateWithURL(
            destination as CFURL,
            UTType.gif.identifier as CFString,
            frameIndices.count,
            nil
        ) else {
            throw TinyGIFAttachmentRendererError.cannotCreateDestination
        }

        CGImageDestinationSetProperties(output, [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFLoopCount: 0
            ]
        ] as CFDictionary)

        for (outputIndex, sourceIndex) in frameIndices.enumerated() {
            guard let sourceFrame = CGImageSourceCreateImageAtIndex(source, sourceIndex, nil),
                  let renderedFrame = renderFrame(sourceFrame, visiblePixels: visiblePixels) else {
                throw TinyGIFAttachmentRendererError.unreadableFrame
            }
            let nextSourceIndex = outputIndex + 1 < frameIndices.count
                ? frameIndices[outputIndex + 1]
                : sourceFrameCount
            let duration = (sourceIndex..<nextSourceIndex).reduce(0.0) {
                $0 + frameDuration(source: source, at: $1)
            }
            CGImageDestinationAddImage(output, renderedFrame, [
                kCGImagePropertyGIFDictionary: [
                    kCGImagePropertyGIFDelayTime: duration,
                    kCGImagePropertyGIFUnclampedDelayTime: duration
                ]
            ] as CFDictionary)
        }

        guard CGImageDestinationFinalize(output) else {
            throw TinyGIFAttachmentRendererError.cannotFinalize
        }
    }

    static func normalizedContentRect(
        for sourceSize: CGSize,
        visiblePixels: CGFloat = canvasPixels
    ) -> CGRect {
        precondition(sourceSize.width > 0 && sourceSize.height > 0, "GIF frames must have a size")
        let scale = min(visiblePixels / sourceSize.width, visiblePixels / sourceSize.height)
        let drawSize = CGSize(
            width: max(1, floor(sourceSize.width * scale)),
            height: max(1, floor(sourceSize.height * scale))
        )
        return CGRect(
            x: floor((canvasPixels - drawSize.width) / 2),
            y: floor((canvasPixels - drawSize.height) / 2),
            width: drawSize.width,
            height: drawSize.height
        )
    }

    private static func renderFrame(_ frame: CGImage, visiblePixels: CGFloat) -> CGImage? {
        let contentRect = normalizedContentRect(
            for: CGSize(width: frame.width, height: frame.height),
            visiblePixels: visiblePixels
        )
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = 1
        return UIGraphicsImageRenderer(
            size: CGSize(width: canvasPixels, height: canvasPixels),
            format: format
        ).image { _ in
            UIImage(cgImage: frame).draw(in: contentRect)
        }.cgImage
    }

    private static func sampledFrameIndices(frameCount: Int, maximumFrames: Int) -> [Int] {
        guard frameCount > maximumFrames else { return Array(0..<frameCount) }
        return (0..<maximumFrames).map { index in
            Int(floor(Double(index * frameCount) / Double(maximumFrames)))
        }
    }

    private static func frameDuration(source: CGImageSource, at index: Int) -> TimeInterval {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(
            source,
            index,
            nil
        ) as? [CFString: Any],
        let gif = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any] else {
            return 0.1
        }
        let unclamped = gif[kCGImagePropertyGIFUnclampedDelayTime] as? Double
        let clamped = gif[kCGImagePropertyGIFDelayTime] as? Double
        if let unclamped, unclamped > 0 { return unclamped }
        if let clamped, clamped > 0 { return clamped }
        return 0.1
    }

    private static func fileSize(at url: URL) -> Int? {
        try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize
    }
}

enum TinyGIFAttachmentRendererError: Error {
    case unreadableSource
    case unreadableFrame
    case cannotCreateDestination
    case cannotFinalize
    case fileTooLarge
}
