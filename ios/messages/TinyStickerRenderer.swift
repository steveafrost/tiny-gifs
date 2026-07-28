import ImageIO
import UIKit
import UniformTypeIdentifiers

/// Builds a compact animated sticker whose file dimensions match its intended
/// transcript size. `MSSticker` treats dynamically generated GIF pixels as
/// points, so a 300 px padded canvas renders as a large 300 pt message.
enum TinyStickerRenderer {
    static let canvasPixels: CGFloat = 128
    static let maximumVisiblePixels: CGFloat = 128
    static let maximumFileBytes = 490_000

    private struct RenderAttempt {
        let visiblePixels: CGFloat
        let maximumFrames: Int
    }

    static func render(sourceURL: URL, identifier: String) throws -> URL {
        let fileManager = FileManager.default
        let cacheDirectory = try fileManager
            .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("TinyStickerMedia", isDirectory: true)
        try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

        let safeIdentifier = identifier.replacingOccurrences(
            of: "[^A-Za-z0-9_-]",
            with: "-",
            options: .regularExpression
        )
        let destination = cacheDirectory.appendingPathComponent("\(safeIdentifier)-emoji-v4.gif")
        if let size = fileSize(at: destination), size <= maximumFileBytes {
            return destination
        }

        guard let source = CGImageSourceCreateWithURL(sourceURL as CFURL, nil),
              CGImageSourceGetCount(source) > 0 else {
            throw TinyStickerRendererError.unreadableSource
        }

        let attempts = [
            RenderAttempt(visiblePixels: maximumVisiblePixels, maximumFrames: 24),
            RenderAttempt(visiblePixels: 112, maximumFrames: 16),
            RenderAttempt(visiblePixels: 96, maximumFrames: 12),
            RenderAttempt(visiblePixels: 80, maximumFrames: 8)
        ]

        for (attemptIndex, attempt) in attempts.enumerated() {
            let temporary = cacheDirectory.appendingPathComponent(
                "\(safeIdentifier)-emoji-v4-\(attemptIndex).gif"
            )
            try? fileManager.removeItem(at: temporary)
            try writeGIF(
                source: source,
                destination: temporary,
                visiblePixels: attempt.visiblePixels,
                maximumFrames: attempt.maximumFrames
            )
            guard let size = fileSize(at: temporary), size <= maximumFileBytes else {
                try? fileManager.removeItem(at: temporary)
                continue
            }
            try? fileManager.removeItem(at: destination)
            try fileManager.moveItem(at: temporary, to: destination)
            return destination
        }

        throw TinyStickerRendererError.fileTooLarge
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
            throw TinyStickerRendererError.cannotCreateDestination
        }

        CGImageDestinationSetProperties(output, [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFLoopCount: 0
            ]
        ] as CFDictionary)

        for (outputIndex, sourceIndex) in frameIndices.enumerated() {
            guard let sourceFrame = CGImageSourceCreateImageAtIndex(source, sourceIndex, nil),
                  let renderedFrame = renderFrame(sourceFrame, visiblePixels: visiblePixels) else {
                throw TinyStickerRendererError.unreadableFrame
            }
            let nextSourceIndex = outputIndex + 1 < frameIndices.count
                ? frameIndices[outputIndex + 1]
                : sourceFrameCount
            let duration = (sourceIndex..<nextSourceIndex).reduce(0.0) {
                $0 + frameDuration(source: source, at: $1)
            }
            CGImageDestinationAddImage(output, renderedFrame, [
                kCGImagePropertyGIFDictionary: [
                    kCGImagePropertyGIFDelayTime: max(duration, 0.02),
                    kCGImagePropertyGIFUnclampedDelayTime: max(duration, 0.02)
                ]
            ] as CFDictionary)
        }

        guard CGImageDestinationFinalize(output) else {
            throw TinyStickerRendererError.cannotFinalize
        }
    }

    private static func renderFrame(_ frame: CGImage, visiblePixels: CGFloat) -> CGImage? {
        let sourceSize = CGSize(width: frame.width, height: frame.height)
        let scale = min(visiblePixels / sourceSize.width, visiblePixels / sourceSize.height)
        let drawSize = CGSize(
            width: max(1, floor(sourceSize.width * scale)),
            height: max(1, floor(sourceSize.height * scale))
        )
        let drawOrigin = CGPoint(
            x: floor((canvasPixels - drawSize.width) / 2),
            y: floor((canvasPixels - drawSize.height) / 2)
        )
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = 1
        return UIGraphicsImageRenderer(
            size: CGSize(width: canvasPixels, height: canvasPixels),
            format: format
        ).image { _ in
            UIImage(cgImage: frame).draw(in: CGRect(origin: drawOrigin, size: drawSize))
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
        return max(unclamped ?? clamped ?? 0.1, 0.02)
    }

    private static func fileSize(at url: URL) -> Int? {
        let values = try? url.resourceValues(forKeys: [.fileSizeKey])
        return values?.fileSize
    }
}

enum TinyStickerRendererError: Error {
    case unreadableSource
    case unreadableFrame
    case cannotCreateDestination
    case cannotFinalize
    case fileTooLarge
}
