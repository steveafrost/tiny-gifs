import ImageIO
import Messages
import UIKit
import UniformTypeIdentifiers

@MainActor
protocol TinyGIFConversationSending: AnyObject {
    func sendAttachment(
        _ URL: URL,
        withAlternateFilename filename: String?,
        completionHandler: (@Sendable (Error?) -> Void)?
    )
}

extension MSConversation: TinyGIFConversationSending {}

@MainActor
enum TinyGIFMessageSender {
    static func send(
        _ attachmentURL: URL,
        filename: String,
        conversation: TinyGIFConversationSending
    ) async throws {
        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Void, Error>) in
            conversation.sendAttachment(
                attachmentURL,
                withAlternateFilename: filename
            ) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}

/// Resizes every frame of a selected GIF for delivery as a regular Messages attachment.
/// Regular attachments are not constrained by the 500 KB `MSSticker` file-size limit.
enum TinyGIFAttachmentRenderer {
    static let canvasPixels: CGFloat = 512

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
            "\(safeIdentifier)-attachment-v7.gif"
        )
        if fileManager.fileExists(atPath: destination.path) {
            return destination
        }

        guard let source = CGImageSourceCreateWithURL(sourceURL as CFURL, nil),
              CGImageSourceGetCount(source) > 0 else {
            throw TinyGIFAttachmentRendererError.unreadableSource
        }

        let temporary = cacheDirectory.appendingPathComponent(
            "\(safeIdentifier)-attachment-v7-temporary.gif"
        )
        try? fileManager.removeItem(at: temporary)
        try writeGIF(source: source, destination: temporary)
        try? fileManager.removeItem(at: destination)
        try fileManager.moveItem(at: temporary, to: destination)
        return destination
    }

    private static func writeGIF(source: CGImageSource, destination: URL) throws {
        let frameCount = CGImageSourceGetCount(source)
        guard let output = CGImageDestinationCreateWithURL(
            destination as CFURL,
            UTType.gif.identifier as CFString,
            frameCount,
            nil
        ) else {
            throw TinyGIFAttachmentRendererError.cannotCreateDestination
        }

        CGImageDestinationSetProperties(output, [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFLoopCount: 0
            ]
        ] as CFDictionary)

        for index in 0..<frameCount {
            guard let sourceFrame = CGImageSourceCreateImageAtIndex(source, index, nil),
                  let renderedFrame = renderFrame(sourceFrame) else {
                throw TinyGIFAttachmentRendererError.unreadableFrame
            }
            let duration = frameDuration(source: source, at: index)
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

    private static func renderFrame(_ frame: CGImage) -> CGImage? {
        let sourceSize = CGSize(width: frame.width, height: frame.height)
        let scale = min(canvasPixels / sourceSize.width, canvasPixels / sourceSize.height)
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
}

enum TinyGIFAttachmentRendererError: Error {
    case unreadableSource
    case unreadableFrame
    case cannotCreateDestination
    case cannotFinalize
}
