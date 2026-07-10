# #tiny-gifs market and feasibility research

**Research snapshot:** July 10, 2026 (United States App Store and current Apple developer documentation)

## Executive finding

The broad idea has been done, but the specific promise is not yet owned.

Several products already put GIFs or animated stickers behind an iPhone keyboard. The closest precedents are GIPHY's animated Sticker Extension, Stickerboard's offline keyboard that explicitly shrinks animated GIFs to sticker size, and AIKeyMoji's 728 bundled animated stickers. None of the products reviewed makes **"every reaction is deliberately large-emoji-sized, fast, and conversation-preserving"** its central format and brand.

The important product constraint is that a pure GIF-only custom keyboard is a poor fit for Apple's rules and APIs. Apple requires keyboard extensions to provide typed-character input, a next-keyboard control, and useful operation without Full Access. A custom keyboard directly inserts text, not arbitrary image attachments; existing GIF keyboards normally copy media to the pasteboard and ask the user to paste. The most seamless compliant product is therefore a bundle:

1. A **system/iMessage animated Sticker extension** as the default experience. It appears automatically after app installation and can insert a sticker or attachment into Messages without clipboard gymnastics.
2. An **optional custom keyboard** for cross-app discovery and sharing, with a small text/search surface, an offline starter library, a globe key, and a clearly explained Full Access request only when the user needs clipboard/network features.

This is a real positioning opportunity, but the key promise needs device testing: recipient apps control attachment layout, so a 48×48 or 96×96 GIF is not guaranteed to render at that physical size in every conversation.

## Competitive landscape

| Product | Current signal | What overlaps | Friction / gap that #tiny-gifs can exploit |
| --- | --- | --- | --- |
| [Apple #images](https://support.apple.com/en-euro/118278) | Built into Messages; hundreds of trending GIFs; available in 13 listed countries | Native search-and-send reference experience | Messages-only, geographically limited, conventional full-size GIFs, and reached through the Messages add menu rather than a universally available tiny-reaction collection |
| [Tenor GIF Keyboard](https://apps.apple.com/us/app/gif-keyboard/id917932200) | 4.7/5 from 1.4M ratings; 251.5 MB | Search, categories, favorites, uploads, keyboard, and iMessage app | Requires Full Access; keyboard flow is tap to copy, tap the message field, then paste; huge catalog is optimized for finding any GIF, not protecting conversation space |
| [GIPHY](https://apps.apple.com/us/app/giphy-the-gif-search-engine/id974748812) | 4.8/5 from 704K ratings; 92.4 MB | GIF/sticker search, creation, keyboard, and iMessage extension | Broad media platform rather than a constrained tiny format; significant privacy disclosures and catalog complexity |
| [GIPHY Sticker Extension](https://apps.apple.com/us/app/giphy-sticker-extension/id6469542593) | 4.6/5 from 304 ratings; 23.3 MB | The closest native-feeling precedent: animated sticker reactions, tap to send, or peel and layer in Messages | Sticker-only GIPHY catalog; no cross-app keyboard, no tiny-size guarantee, no distinctive reaction-character system |
| [GIFFF](https://apps.apple.com/us/app/gif-keyboard-search-gifff/id1550051979) | 4.5/5 from 901 ratings; 23 MB | Keyboard + iMessage app, search, categories, synced favorites, recent GIFs | General GIF/sticker aggregator; installation instructions still send users through Settings; no deliberate tiny format |
| [Stickerboard](https://apps.apple.com/us/app/stickerboard-image-keyboard/id1541097926) | 5.0/5 from 4 ratings; 967.7 KB; open source/offline | Explicitly shrinks imported PNG, JPEG, and animated GIF media to sticker size | User must source/import every asset; keyboard can only copy to clipboard, followed by manual paste; almost no discovery/content layer |
| [AIKeyMoji](https://apps.apple.com/us/app/aikeymoji-ai-sticker-keyboard/id6767867186) | New/no rating summary; 440.5 MB; requires iOS 26.4 | 728 bundled animated stickers, on-device search/creation, no account or analytics | Very large download and new-OS requirement; tap-paste flow; broad AI sticker maker rather than quick, culturally legible reaction GIFs |
| [Gboard](https://apps.apple.com/us/app/gboard-the-google-keyboard/id1091700242) | 4.0/5 from 58K ratings; 86.8 MB | GIF and sticker search within a full typing keyboard | General-purpose keyboard, Google search/privacy tradeoff, and no tiny-only constraint |

### Verdict on originality

- **Already done:** third-party GIF keyboards, animated sticker keyboards, offline animated sticker libraries, automatic resizing to sticker size, GIF search, favorites/recents, and iMessage sticker extensions.
- **Not clearly owned by a reviewed competitor:** a hard, visible format rule that every result behaves like a moving large emoji; a small, high-hit-rate reaction library instead of an infinite feed; and an install experience that leads with the automatic system sticker path rather than forcing Full Access before the first successful send.
- **Defensible wedge:** “motion with emoji manners” — short loops that communicate one reaction, load instantly, and do not visually take over the transcript.

## iOS constraints that shape the product

### 1. A GIF-only custom keyboard is at App Review risk

[App Review Guideline 4.4.1](https://developer.apple.com/app-store/review/guidelines/) says keyboard extensions must provide keyboard input functionality such as typed characters, follow Sticker rules when they include images, provide a way to progress to the next keyboard, and remain functional without network access or Full Access. It also limits activity collection to improving the on-device keyboard.

Implication: do not submit a grid that only emits images. Include real character input (at minimum, a focused search/text mode), a globe/next-keyboard button, and a useful bundled offline experience. Keep ads, purchases, and marketing out of the extension UI; Apple says extensions may not contain them.

### 2. A custom keyboard cannot directly insert a GIF like text

Apple's [Custom Keyboard programming guide](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html) defines the keyboard's core output as an unattributed string sent through `textDocumentProxy`. The same guide lists `UIPasteboard` as an Open Access capability. Tenor and Stickerboard's own App Store instructions expose the practical result: tap a GIF to copy, then tap the destination field and paste.

Implication: “one tap sends anywhere” is not a credible custom-keyboard promise. Use copy confirmation with an unmissable, one-line “Now tap Paste” affordance, and make Messages the truly low-friction path through a Messages/Sticker extension.

### 3. Full Access creates both install friction and a trust problem

Apple's current [Open Access documentation](https://developer.apple.com/documentation/uikit/configuring-open-access-for-a-custom-keyboard) says a keyboard is network-isolated by default. Users must explicitly enable Allow Full Access for networking and expanded shared-container capabilities, and Apple warns that this means typed input is available to the keyboard developer. Apple's [keyboard setup guide](https://support.apple.com/en-gb/guide/iphone/iph73b71eb/ios) still requires a trip through Settings to add a third-party keyboard.

Implication: lead with “works offline, no account, no keystroke collection.” Ship a meaningful local pack and defer Full Access until a user asks for online search or cross-app clipboard sharing. The containing app can open its own Settings page through Apple's documented [`openSettingsURLString`](https://developer.apple.com/documentation/uikit/uiapplication/opensettingsurlstring), but the user still makes the security decision.

### 4. The sticker route is materially more seamless

Apple says a bundled Sticker Pack is [automatically visible in iMessage after the iOS app is downloaded](https://developer.apple.com/imessage/). Sticker packs and eligible iMessage extensions can also appear in the [system Stickers experience throughout iOS and through the emoji keyboard](https://developer.apple.com/documentation/messages/adding-sticker-packs-and-imessage-apps-to-the-system-stickers-app-messages-camera-and-facetime). In Messages, an extension can [insert an attachment into the input field](https://developer.apple.com/documentation/messages/msconversation/insertattachment%28_%3Awithalternatefilename%3Acompletionhandler%3A%29); the user still taps Send.

Implication: the website's primary CTA and onboarding should say “Install, open Stickers, send your first tiny” before explaining the optional keyboard. This produces value without asking for keyboard trust on screen one.

### 5. Sticker media has strict packaging limits

Apple's [iMessage sticker specifications](https://developer.apple.com/design/human-interface-guidelines/imessage-apps-and-stickers) define small stickers as 300×300 px at @3x (100×100 points), permit animated GIF/APNG, and cap each sticker file at 500 KB. Apple recommends consistent size selection within a pack and localized alternative descriptions for VoiceOver.

Implication: create a deterministic asset pipeline and reject anything over budget. Treat 500 KB as a ceiling, not a target. A useful house standard to prototype is a 1–2.5 second seamless loop, transparent background where possible, one readable action, and substantially less than 500 KB.

### 6. Cross-app rendering is not under the keyboard's control

Apple specifies browser-grid sticker sizes, not a universal physical footprint for pasted GIF attachments in every destination app. Messages, WhatsApp, Instagram, Discord, Telegram, RCS/MMS recipients, and email can each resize or convert the media.

Implication: the “large emoji size” promise is an **unverified product hypothesis**, not merely an export setting. Before finalizing copy, test a matrix of raw GIF attachments and sticker sends on current devices and record sender/recipient appearance. Maintain per-destination fallbacks if needed (for example, sticker in Messages and tiny GIF attachment elsewhere).

### 7. Custom keyboards are not truly universal

Apple's [Custom Keyboard guide](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html) says the system replaces custom keyboards in secure text fields and phone-pad fields, and individual apps may reject custom keyboards entirely.

Implication: market this as “in supported chat apps,” not literally everywhere.

### 8. Catalog sourcing is a business constraint

As of January 2026, Google's [Tenor quickstart](https://developers.google.com/tenor/guides/quickstart) says Tenor is no longer accepting new API clients. Existing Tenor integrations require attribution, and the API supports optimized `tinygif` renditions, but that rendition name describes bandwidth—not guaranteed conversation footprint. [GIPHY's developer documentation](https://developers.giphy.com/docs/) also requires attribution and production/API compliance. Apple additionally forbids third-party keyboards and sticker packs from containing Apple emoji under [Guideline 5.2.5](https://developer.apple.com/app-store/review/guidelines/).

Implication: do not make an unapproved Tenor integration the launch dependency. Start with an owned or explicitly licensed collection, preserve creator attribution/rights records per asset, and add user uploads only with the filtering, reporting, blocking, and contact mechanisms required by Apple's [user-generated content rule](https://developer.apple.com/app-store/review/guidelines/).

## How to make it materially better

### Seamless installation and first success

1. **Bundle three surfaces in one install:** containing app for onboarding/library, system/iMessage Sticker extension for the default send path, and optional custom keyboard for cross-app reach.
2. **First-run goal: one sent tiny in under 30 seconds.** Show an interactive Messages demo, then a button that opens a precomposed handoff or explains exactly where the sticker icon appears.
3. **Defer keyboard setup.** Present it after the first successful sticker send as “Use tiny GIFs in more apps.” Explain the add-keyboard and Full Access steps one screen at a time, with a visible privacy promise beside the Full Access request.
4. **Make offline useful.** Bundle the best 50–100 reactions, search tags, recents, and favorites. Online packs and fresh trends are additive, not required for the keyboard to open or feel complete.
5. **Always provide an escape hatch.** Globe key in the keyboard, share sheet from the app, and standard Sticker access in Messages.

### A more fun product, not merely a smaller file

- Build around **reaction verbs** (“yes,” “no,” “wait,” “yikes,” “proud,” “love,” “dead,” “brb”) rather than content-provider categories.
- Give each loop a tiny personality and name; randomize a “surprise me” slot within the selected emotion.
- Let favorites become a personal “top row,” and keep recents instant and offline.
- Offer coordinated micro-packs by artist, mood, friend-group ritual, season, or fandom—without turning the keyboard into a store.
- Use press-and-hold preview with the creator credit and alt text; tap performs the expected send/copy action.
- Make the format visibly consistent: no captions that are unreadable at emoji scale, no long narrative clips, no rectangular TV excerpts masquerading as tiny reactions.

### Product rules worth enforcing

- One emotion or action per loop.
- Readable at a glance without opening a viewer.
- Loop starts meaningfully on frame one and resolves within roughly 2.5 seconds.
- Small download and memory footprint; never block the keyboard on a network request.
- Transparent background or a deliberately compact silhouette when licensing/source media permits.
- Every asset has search tags, localized alt text, creator/source, license status, and a moderation rating.

## Recommended MVP and decision gates

### MVP

- 60–100 owned/licensed animated reactions.
- System/iMessage Sticker extension with small sticker assets and search/categories if the chosen extension architecture supports the needed dynamic catalog.
- Optional custom keyboard with character search, offline grid, favorites/recents, globe key, and explicit copy/paste coaching.
- Containing app with 30-second onboarding, privacy explanation, asset credits, keyboard setup, and a “test send” path.
- Website examples that show the actual recipient-side conversation footprint captured from device tests.

### Gate 1 — prove the core visual promise

Before expanding the library, send representative square, portrait, landscape, transparent, and opaque loops through:

- iMessage as an `MSSticker`
- iMessage as a GIF attachment
- WhatsApp
- Telegram
- Instagram DMs
- Discord
- RCS to Android and MMS fallback where available

Record displayed footprint, animation preservation, file conversion, number of taps, and recipient appearance. If most destinations upscale the GIF to a normal attachment, position the product as animated tiny stickers in Messages first rather than claiming universal emoji-sized GIFs.

### Gate 2 — App Review preflight

Verify that the keyboard provides genuine character input, next-keyboard behavior, offline usefulness, accurate Full Access disclosures, no marketing/IAP inside the extension, and content rights evidence. Submit a review note that explains why Full Access is optional and exactly what is collected (ideally nothing beyond explicit searches).

### Gate 3 — retention signal

The strongest early metric is not downloads or searches; it is **distinct days with a successful send**, split by Sticker extension versus custom keyboard. A tiny library wins only if users can repeatedly find the right reaction faster than opening #images, GIPHY, or Tenor.

## Bottom line

Proceed, but build the product as **an animated tiny-sticker system with an optional keyboard**, not as a GIF-only keyboard. The category is crowded, and multiple apps already cover the mechanics. The opportunity is to own the constraint—small, instant, legible, and socially expressive—while making the first-use path dramatically more trustworthy and successful than the Settings → Full Access → copy → paste pattern.
