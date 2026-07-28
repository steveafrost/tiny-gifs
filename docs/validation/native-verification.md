# Native verification record

## Completed locally

- Xcode 26.5 compiled the `TinyGIFs` scheme, including the containing app, `TinyGIFsMessages`, and `TinyGIFsKeyboard`, for the iOS Simulator SDK with code signing disabled.
- `TinyGIFsTests` passed on an iPhone 17 Pro simulator (iOS 26.5). The suite validates the exact eight-item catalog, PNG/GIF file budget, 300×300 PNG dimensions, and the Full Access copy decision.
- The containing app was installed and launched on that simulator. The first-run onboarding rendered successfully.

## Build 17 Messages extension verification

- Build 17 uses a custom three-column, searchable GIPHY drawer rather than a static sticker pack. It visibly attributes results to GIPHY and inserts a selected animation with `MSConversation.insert(_ sticker:)`.
- On an iPhone 17 Pro simulator running iOS 26.5, the drawer loaded animated trending results, the exact query `happy` returned animated matching results, and a selected GIF staged in the compose field with the expected `Added tiny GIF — tap Send` status.
- The earlier 300×300 animated sticker reached `Delivered` but appeared as a transcript-dominating square. The renderer was therefore reduced to 64×64 and then increased at the user's request to the final 128×128 size.
- The renderer now emits a 128×128 animated GIF—twice the previously tested 64×64 correction—without a padded 300-pixel canvas. The test suite verifies the output dimensions, preserved frame count, sub-500 KB size, and successful `MSSticker` construction.
- Final 128×128 live proof succeeded in the simulator-only `+1 (888) 555-1212` conversation. The selected `happy` result reached `Delivered`; its visible transcript footprint measured 113×126 framebuffer pixels, approximately 38×42 points at the simulator's reported 3× scale, within the 128×128-pixel (approximately 43-point) sticker canvas.
- Two direct framebuffer captures taken 1.2 seconds apart changed 7,160 pixels within the sent sticker region, proving the delivered GIF continued animating. Evidence: [delivered frame A](build17-messages-128-sent-frame-a.png) and [delivered frame B](build17-messages-128-sent-frame-b.png).
- The prior touch-input and PlugInKit-registration blockers were recovered by restarting the UDID-scoped simulator mirror and performing one non-destructive simulator reboot after reinstall. Build 17 has not been archived, uploaded, or released.

## Device-only release checks

Before release, repeat the build 17 Messages flow on a physical iPhone and confirm the sender and recipient footprint. Add the keyboard in Settings, verify ordinary typed-character input plus delete, space, return, and globe behavior, then verify that optional Full Access permits GIPHY search and selected GIF pasteboard copy. Confirm that the keyboard remains useful without Full Access.

Also test actual sender and recipient footprint in Messages and at least two supported third-party chat apps. Those apps choose their own attachment rendering, so the large-emoji-scale goal is not a universal display-size guarantee. Secure fields and apps that reject third-party keyboards must continue to fall back to the system keyboard.
