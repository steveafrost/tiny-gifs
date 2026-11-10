# Native verification record

## Current automated verification

- The `TinyGIFs` scheme builds the containing app, the `messages` app-drawer extension, and `TinyGIFsKeyboard` for iOS 17 or later.
- `TinyGIFsTests` validates the eight-item fallback catalog, media budgets, keyboard Full Access decisions, keyboard layers and character output, drawer presentation behavior, send-helper invocation, and the normalized Messages/keyboard output. These tests do not prove automatic delivery inside the Messages app.
- Every outgoing GIF is normalized to a 288×288 animated canvas with a 490,000-byte maximum. Renderer cache filenames use the `sticker-v16` generation so older sizes cannot be reused.
- The Messages drawer requests expanded presentation while browsing and searching. After a deliberate GIF tap, it sends an `MSSticker`, dismisses only after the send completion succeeds, and remains open with an error if rendering or sending fails. On the owner's physical iPhone (iOS 27.0.1, build 52), the GIF staged in the compose field and required the Messages Send button; the simulator did not reproduce that interaction.
- Keyboard verification now covers three character layers (letters, numbers, symbols), shift, delete, space, return, globe, Full Access search/copy, and a responsive layout sized for the system keyboard height. On keyboards shorter than 260 pt, the search row and GIF strip collapse so typing remains usable; KLIPY search stays available in Messages. Physical-device layout and typing checks remain required.

## Historical simulator evidence

- Build 17 established that the custom three-column GIPHY drawer could load trending results, search for `happy`, send an animated sticker, and preserve animation in a simulator conversation.
- The original 300×300 output dominated the transcript. Follow-up simulator evidence validated substantially smaller output and proved the delivered GIF continued animating.
- Those captures are retained as historical evidence only: [delivered frame A](build17-messages-128-sent-frame-a.png) and [delivered frame B](build17-messages-128-sent-frame-b.png). They do not represent the current 288×288 renderer, the KLIPY library, or the current build number.

## Physical-device release checks

Before App Store submission, install the current TestFlight build on a physical iPhone and verify:

1. Messages remains expanded while browsing and searching KLIPY.
2. Tapping a bundled or KLIPY GIF sends exactly once, uses the expected compact footprint, continues animating for sender and recipient, and either sends immediately or clearly stages in the compose field with an honest prompt.
3. A failed send leaves the drawer open and displays a retryable error.
4. The keyboard fits without clipped rows and types lower/upper case letters, numbers, punctuation, spaces, and returns; delete and the next-keyboard globe work without Full Access.
5. With Full Access, tap the keyboard search field and type a KLIPY query using the keyboard’s own keys; search works and both bundled and remote GIFs copy to the pasteboard at the same normalized footprint.
6. Toggling Full Access in Settings updates the keyboard status and search behavior without requiring a reinstall.
7. At least two supported third-party chat apps accept pasted GIFs. Those apps control final rendering, so large-emoji scale remains a per-host target rather than a universal display guarantee.
8. Secure fields and apps that reject third-party keyboards fall back to the system keyboard.
