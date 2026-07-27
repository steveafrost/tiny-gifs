# #tiny-gifs

A complete iOS 17+ starter product for #tiny-gifs: a SwiftUI containing app, a Messages GIF picker as the primary sharing path, and an optional privacy-first custom keyboard for supported chat apps. It also includes the React + Vite product site. The approved visual references are [the website concept](docs/design/accepted-concept.png) and [the native product concept](docs/design/native-product-concept.png).

## Local development

```bash
npm install
npm run dev
```

Run `npm run lint` and `npm run build` before handing off a change.

The production build writes browser assets to `dist/client`, prepares the Sites worker entrypoint at `dist/server/index.js`, and copies `.openai/hosting.json` into the deployable output. The worker delegates static files to the platform asset binding and falls back to `index.html` for client-side routes.

## Install destination

The CTA intentionally does not contain a hard-coded App Store or TestFlight link. Configure a real destination at build time with:

```bash
VITE_INSTALL_URL="https://example.com/your-real-invite" npm run dev
```

When this value is absent or invalid, the CTA opens an accessible sheet that explains the genuine iPhone-app install flow: use the bundled Messages GIF picker first, then optionally add the keyboard for the cross-app copy-and-paste path.

## iOS product

Open [ios/TinyGIFs.xcodeproj](ios/TinyGIFs.xcodeproj) in Xcode 26.5. The `TinyGIFs` scheme includes these targets:

- `TinyGIFs` — iOS 17+ SwiftUI containing app that exists to install and explain the custom keyboard. It clearly distinguishes keyboard GIPHY search from the companion app and explains Full Access.
- `TinyGIFsMessages` — custom Messages app-drawer GIF picker. A tap uses `MSConversation.insertAttachment` to add a GIF to the Messages field; the user then taps Send. It searches GIPHY when configured and retains bundled GIFs as an offline fallback.
- `TinyGIFsKeyboard` — `UIInputViewController` with letter input, delete, space, return, next-keyboard/globe action, bundled fallback reactions, and Full Access GIPHY search + GIF pasteboard copying.
- `TinyGIFsTests` — catalog, media budget/dimension, and keyboard Full Access decision tests.

To compile without signing, select an installed iPhone Simulator destination in Xcode or run:

```bash
xcodebuild \
  -project ios/TinyGIFs.xcodeproj \
  -scheme TinyGIFs \
  -destination 'platform=iOS Simulator,name=<available iPhone>' \
  -derivedDataPath /tmp/tiny-gifs-derived \
  CODE_SIGNING_ALLOWED=NO \
  test
```

If no simulator runtime is installed, build the project in Xcode after installing an iOS 17-or-newer runtime; no external account is required for that local validation.

## Full GIF library and starter assets

GIPHY provides the full searchable GIF library in the Messages extension, keyboard, and website explorer. The companion app is intentionally an installer, not another GIF browser. Create an API key in the [GIPHY developer portal](https://developers.giphy.com/docs/api/), then configure it in Xcode's `GIPHY_API_KEY` build setting for every native target. For the website, set `VITE_GIPHY_API_KEY` in its deployment environment. The product visibly attributes search results as `Powered By GIPHY`.

The keyboard only performs GIPHY search or media download with Full Access. Without it, text input and bundled reactions are still available.

The eight owned starter reactions are `lol`, `nope`, `omg`, `brb`, `perfect`, `yes`, `yikes`, and `tiny clap`. Their deterministic vector sources live in `ios/Shared/ArtworkSources`; matching 300×300 PNG and GIF exports live in `ios/Shared/Resources/GIFs` and are included in the native targets. The test suite enforces the 500 KB per-file cap and PNG dimensions.

The checked-in GIFs are deliberately static fallback exports because this repository has no reproducible animation encoder. That limitation and the source asset provenance are documented in [docs/validation/gif-assets.md](docs/validation/gif-assets.md).

## Physical-device verification still required

The completed simulator evidence and remaining release checks are also recorded in [docs/validation/native-verification.md](docs/validation/native-verification.md).

- Open the #tiny-gifs Messages app-drawer extension and confirm each GIF is added to the compose field and can be sent normally.
- Add the keyboard from Settings and confirm typing, delete, space, return, and globe behavior in a normal text field.
- Configure a production GIPHY key and confirm that search returns results in the Messages extension, keyboard, and website; confirm the required GIPHY attribution is visible.
- Confirm that enabling Full Access allows GIPHY and local GIF pasteboard copy and that the copy feedback is clear; without Full Access, typing and bundled reactions must remain usable.
- Test actual GIF footprint in Messages and at least two supported third-party chat apps. Receiving apps control final attachment rendering, so emoji-scale is a target rather than a universal fixed-size claim.
- Verify custom-keyboard fallback behavior in secure fields and apps that reject third-party keyboards.

## Notes

The starter reaction artwork is original and repo-owned. GIPHY supplies the optional full-library search and media downloads; #tiny-gifs has no analytics SDK or user account system.
