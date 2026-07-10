# Native verification record

## Completed locally

- Xcode 26.5 compiled the `TinyGIFs` scheme, including the containing app, `TinyGIFsMessages`, and `TinyGIFsKeyboard`, for the iOS Simulator SDK with code signing disabled.
- `TinyGIFsTests` passed on an iPhone 17 Pro simulator (iOS 26.5). The suite validates the exact eight-item catalog, PNG/GIF file budget, 300×300 PNG dimensions, and the Full Access copy decision.
- The containing app was installed and launched on that simulator. The first-run onboarding rendered successfully.

## Device-only release checks

Simulator tests cannot enable or fully exercise all extension surfaces. Before release, configure a production GIPHY API key and validate on a physical iPhone that the sticker extension appears in the Messages app drawer and system Stickers, searches GIPHY, inserts and peels correctly, and uses the final animated media files. Add the keyboard in Settings, verify ordinary typed-character input plus delete, space, return, and globe behavior, then verify that optional Full Access permits GIPHY search and selected GIF pasteboard copy. Confirm that the keyboard remains useful without Full Access.

Also test actual sender and recipient footprint in Messages and at least two supported third-party chat apps. Those apps choose their own attachment rendering, so the large-emoji-scale goal is not a universal display-size guarantee. Secure fields and apps that reject third-party keyboards must continue to fall back to the system keyboard.
