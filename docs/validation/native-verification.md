# Native verification record

## Current automated verification

- The `TinyGIFs` scheme builds the containing app, the `messages` app-drawer extension, and `TinyGIFsKeyboard` for iOS 17 or later.
- `TinyGIFsTests` validates the eight-item fallback catalog, media budgets, keyboard Full Access decisions, drawer presentation behavior, immediate sticker sending, and the normalized Messages/keyboard output.
- Every outgoing GIF is normalized to a 192×192 animated canvas with a 500 KB maximum. Renderer cache filenames use the `sticker-v14` generation so older sizes cannot be reused.
- The Messages drawer requests expanded presentation while browsing and searching. After a deliberate GIF tap, it sends an `MSSticker` immediately, dismisses only after the send completion succeeds, and remains open with an error if rendering or sending fails.

## Historical simulator evidence

- Build 17 established that the custom three-column GIPHY drawer could load trending results, search for `happy`, send an animated sticker, and preserve animation in a simulator conversation.
- The original 300×300 output dominated the transcript. Follow-up simulator evidence validated substantially smaller output and proved the delivered GIF continued animating.
- Those captures are retained as historical evidence only: [delivered frame A](build17-messages-128-sent-frame-a.png) and [delivered frame B](build17-messages-128-sent-frame-b.png). They do not represent the current 192×192 renderer or current build number.

## Physical-device release checks

Before App Store submission, install the current TestFlight build on a physical iPhone and verify:

1. Messages remains expanded while browsing and searching GIPHY.
2. Tapping a bundled or GIPHY GIF sends exactly once, uses the expected compact footprint, continues animating for sender and recipient, and collapses the drawer only after success.
3. A failed send leaves the drawer open and displays a retryable error.
4. The keyboard types, deletes, inserts spaces/returns, and advances to the next keyboard without Full Access.
5. With Full Access, GIPHY search works and both bundled and remote GIFs copy to the pasteboard at the same normalized footprint.
6. At least two supported third-party chat apps accept pasted GIFs. Those apps control final rendering, so large-emoji scale remains a per-host target rather than a universal display guarantee.
7. Secure fields and apps that reject third-party keyboards fall back to the system keyboard.
