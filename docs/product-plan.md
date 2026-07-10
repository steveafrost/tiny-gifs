# #tiny-gifs product plan

Last updated: 2026-07-10

## Outcome

Ship a real iPhone product behind the existing website: an installable host app, a seamless Messages/system Stickers experience, and an optional cross-app custom keyboard. The product promise stays narrow: expressive animated reactions that occupy roughly the visual footprint of a large emoji instead of taking over the transcript.

## Product architecture

### 1. Host iPhone app

- SwiftUI app targeting iOS 17 or later.
- First-run onboarding explains the two sharing surfaces without implying that a website can install a keyboard.
- An interactive setup checklist deep-links to the Keyboard Settings page where Apple permits it.
- A reaction library searches and previews the full GIPHY catalog, while preserving a bundled fallback collection and favorites.
- Privacy is local-first for typing and the fallback catalog: no analytics SDK or account. Optional GIPHY search sends only the user-selected search term to GIPHY.
- A diagnostics screen reports whether Full Access is available and explains why the optional keyboard needs it for GIPHY search and animated-media copy.

### 2. Messages and system Stickers extension — primary path

- Ships inside the containing iOS app.
- Presents GIPHY search results in a native sticker browser, with bundled stickers as an offline fallback.
- Tap sends or inserts a sticker directly in Messages; users can also peel stickers onto bubbles.
- Uses Apple-supported animated sticker formats and the Small sticker size.
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
- Stay under Apple's 500 KB sticker limit.
- Be supplied at the Small sticker dimensions Apple recommends.
- Have transparent edges and remain legible at roughly large-emoji scale.
- Be tested in Messages and at least two third-party chat apps because rendering size varies by host.

## Website changes

- Preserve the accepted visual concept and exact core copy.
- Change installation messaging from keyboard-only to the honest bundled experience: fastest in Messages, optional keyboard everywhere else.
- Add a compact live product switcher demonstrating `Stickers` and `Keyboard` behavior.
- Keep `VITE_INSTALL_URL`; until a real App Store/TestFlight link exists, the CTA opens the accessible beta sheet.
- Add privacy and support routes/pages that explain the local fallback and optional GIPHY requests.

## Repository layout

```text
ios/
  TinyGIFs.xcodeproj/
  TinyGIFsApp/
  TinyGIFsKeyboard/
  TinyGIFsMessages/
  Shared/
  Tests/
src/
docs/
```

Shared catalog metadata lives in Swift source for the native targets and in a small TypeScript data module for the website. Binary sticker assets are checked into the repo with deterministic filenames and documented source prompts.

## Implementation phases

1. Scaffold the Xcode project and shared design/catalog layer.
2. Build the host app onboarding, library, setup state, privacy copy, and settings deep link.
3. Build the Messages extension and validate native sticker insertion.
4. Build the compliant keyboard extension, including fallback text keys, next-keyboard behavior, Full Access detection, copy feedback, and offline operation.
5. Integrate the two-path product story into the existing website without changing its accepted visual system.
6. Add unit tests for catalog integrity, asset limits, and copy-state logic; add web lint/build coverage.
7. Verify with Simulator plus browser screenshots, document known device-only limits, then commit and push scoped changes.

## Release gates

- All targets compile with Xcode 26.5.
- The containing app launches in an iPhone Simulator and onboarding/navigation work.
- Keyboard target includes typed input, delete, space, return, and `advanceToNextInputMode`.
- Keyboard does not require Full Access to launch or type.
- Every sticker asset is below 500 KB and has expected dimensions.
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
- [Adding sticker packs to Messages](https://developer.apple.com/documentation/messages/adding-your-sticker-packs-to-messages)
- [Apple Messages framework](https://developer.apple.com/documentation/messages/)
- [iMessage apps and stickers](https://developer.apple.com/imessage/)
- [GIPHY API documentation](https://developers.giphy.com/docs/api/)
