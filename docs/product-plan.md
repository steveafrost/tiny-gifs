# #tiny-gifs product plan

Last updated: 2026-08-11

## Outcome

Ship a real iPhone product behind the existing website: an installable host app, a seamless Messages GIF-picker experience, and an optional cross-app custom keyboard. The product promise stays narrow: expressive animated GIF reactions that occupy roughly the visual footprint of a large emoji instead of taking over the transcript.

## Product architecture

### 1. Host iPhone app

- SwiftUI app targeting iOS 17 or later.
- The containing app is a focused keyboard installer, not a second GIF browser. It explains the manual Settings path Apple requires for custom-keyboard installation.
- It clearly shows that live GIPHY search lives in the keyboard after Full Access, while the Messages extension remains the primary sharing path.
- Privacy is local-first for typing and the fallback catalog: no analytics SDK or account. Optional GIPHY search sends only the user-selected search term to GIPHY.

### 2. Messages GIF picker extension — primary path

- Ships inside the containing iOS app.
- Presents GIPHY search results in a custom #images-style GIF grid, with bundled GIFs as an offline fallback.
- A deliberate tap normalizes the selected GIF to a consistent 192×192 canvas, sends it immediately as an `MSSticker`, then collapses the drawer only after the send succeeds.
- A failed send leaves the drawer expanded and presents a retryable error. The extension does not expose a system Stickers surface or support peeling onto bubbles.
- This is the default website story because it minimizes setup and avoids keyboard paste friction.

### 3. `#tiny-gifs` custom keyboard — cross-app path

- `UIInputViewController` extension with a compact GIPHY search row and starter reaction grid.
- Includes basic typed-character input, delete, space, return, and the required next-keyboard control.
- Remains useful without Full Access: browsing, previews, and text input still work.
- With Full Access enabled, searching sends the search term to GIPHY and tapping a reaction copies its GIF to `UIPasteboard`; the UI then shows a clear `Copied — paste in the conversation` state.
- Never records keystrokes or transmits conversation content. GIPHY requests are limited to a selected search term and media download.

## MVP reaction catalog

Start with eight original, loopable reactions using the website's abstract visual language:

- `lol`
- `nope`
- `omg`
- `brb`
- `perfect`
- `yes`
- `yikes`
- `tiny clap`

Each asset must:

- Loop cleanly in under two seconds.
- Stay within a 500 KB compact-media budget.
- Use a consistent 300×300 fallback export size.
- Have transparent edges and remain legible at roughly large-emoji scale.
- Be tested in Messages and at least two third-party chat apps because rendering size varies by host.

## Website changes

- Preserve the accepted visual concept and exact core copy.
- Change installation messaging from keyboard-only to the honest bundled experience: fastest in Messages, optional keyboard everywhere else.
- Add a compact live product switcher demonstrating `Messages GIF picker` and `Keyboard` behavior.
- Keep `VITE_INSTALL_URL`; until a real App Store/TestFlight link exists, the CTA opens the accessible beta sheet.
- Add privacy and support routes/pages that explain the local fallback and optional GIPHY requests.

## Repository layout

```text
ios/
  TinyGIFs.xcodeproj/
  TinyGIFsApp/
  TinyGIFsKeyboard/
  messages/
  Shared/
  Tests/
src/
docs/
```

Shared catalog metadata lives in Swift source for the native targets and in a small TypeScript data module for the website. Binary GIF assets are checked into the repo with deterministic filenames and documented source prompts.

## Implementation phases

1. Scaffold the Xcode project and shared design/catalog layer.
2. Build the focused host-app installer, keyboard setup instructions, Full Access explanation, and privacy copy.
3. Build the Messages extension and validate immediate compact-sticker sending, success-only drawer dismissal, and failure recovery.
4. Build the compliant keyboard extension, including fallback text keys, next-keyboard behavior, Full Access detection, copy feedback, and offline operation.
5. Integrate the two-path product story into the existing website without changing its accepted visual system.
6. Add unit tests for catalog integrity, asset limits, and copy-state logic; add web lint/build coverage.
7. Verify with Simulator plus browser screenshots, document known device-only limits, then commit and push scoped changes.

## Release gates

- All targets compile with Xcode 26.5.
- The containing app launches in an iPhone Simulator and onboarding/navigation work.
- Keyboard target includes typed input, delete, space, return, and `advanceToNextInputMode`.
- Keyboard does not require Full Access to launch or type.
- Every bundled GIF asset is below 500 KB and has expected dimensions.
- Website passes lint/build, has no horizontal overflow, and accurately describes installation.
- Privacy copy explicitly states that typed content is neither stored nor transmitted, and precisely describes optional GIPHY requests.
- Physical-device QA verifies GIF paste behavior and transcript footprint before any App Store size claim is treated as guaranteed.

## Known platform constraints

- A custom keyboard can directly insert text, not arbitrary animated media; GIF sharing uses the pasteboard and a user paste action.
- Pasteboard access requires Full Access for the keyboard extension.
- Apple requires keyboard extensions to provide typed-character input, a next-keyboard control, and useful operation without Full Access.
- Messaging apps control final rendering size, so `large emoji size` is a product target validated per host rather than an absolute pixel guarantee.

## Source references

- [Apple App Review Guidelines, section 4.4.1](https://developer.apple.com/app-store/review/guidelines/)
- [Apple Custom Keyboard Programming Guide](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html)
- [Sending stickers in Messages](https://developer.apple.com/documentation/messages/msconversation/send(_:completionhandler:)-3vje4)
- [Apple Messages framework](https://developer.apple.com/documentation/messages/)
- [iMessage apps](https://developer.apple.com/imessage/)
- [GIPHY API documentation](https://developers.giphy.com/docs/api/)
