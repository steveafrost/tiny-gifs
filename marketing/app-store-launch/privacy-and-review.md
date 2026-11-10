# App Privacy and App Review preparation

This document is a source-backed preparation aid, not legal advice and not a substitute for the current App Store Connect privacy questionnaire. It reflects the KLIPY implementation in build 52.

## Observed behavior in the current source

| Behavior | Source evidence | App Store review implication |
| --- | --- | --- |
| KLIPY trending/search requests | `ios/Shared/KlipyService.swift` | Requests include the KLIPY API key, `content_filter=high`, `locale=us`, `format_filter=gif`, pagination, and the user-entered search term when searching. |
| Downloading selected KLIPY media | `ios/Shared/KlipyService.swift`, `ios/messages/TinyGIFAttachmentRenderer.swift` | Only the selected GIF is downloaded to a temporary local file and normalized to a 288×288 animated sticker. KLIPY API terms restrict caching/storing content beyond search-result thumbnails; local resizing/re-encoding requires written approval. |
| Optional keyboard search and copy boundary | `ios/TinyGIFsKeyboard/KeyboardViewController.swift` | Keyboard KLIPY search and GIF copying are blocked until Full Access is enabled; typing and the bundled reaction strip remain available. |
| Selected GIF pasteboard copy | `ios/TinyGIFsKeyboard/KeyboardViewController.swift` | The keyboard writes the GIF selected by the user to the system pasteboard. |
| Typed text behavior | `KeyboardViewController.swift` inserts/deletes requested keys; no context-read API was found in the inspected source | Do not claim the keyboard sends typed text. Verify this remains true after future changes. |
| Accounts, analytics, advertising, device permissions | Native source scan found no account, analytics/advertising SDK, tracking, location, contacts, photos, health, or cloud-storage API use | The app itself has no account or analytics SDK. KLIPY still receives search terms, media requests, IP address, and request metadata as a third party. |

## KLIPY terms and privacy findings (source-backed)

- KLIPY API Terms (last updated 2026-06-23): the API license permits users to access, select, and post KLIPY content, but “You may not cache or store KLIPY Content [other than the search results thumbnails stored within a user’s copy of your Application.]” Local resizing/re-encoding therefore needs written approval; the current review-pending flag does not grant it.
- KLIPY API Terms require visible KLIPY brand attribution, prohibit using KLIPY marks in the app name/branding, and require the app to make clear it is independently developed and not a KLIPY product.
- KLIPY Privacy Policy (last updated 2026-06-23) says KLIPY may collect search-term history, content-viewed history, IP address, an app/device identifier, usage and diagnostic information, and may use that information for analytics and advertising. It retains information while an account is open or as otherwise necessary to provide services, and may retain depersonalized/aggregated data.
- #tiny-gifs does not create a KLIPY account, send the user’s typed text, or include an analytics/advertising SDK. That does not erase KLIPY’s own collection. Apple’s “collected” definition covers data sent to third-party partners, so the App Privacy answers must be based on KLIPY’s retention and use, not only on first-party code.

## Required owner/legal decision: App Privacy and KLIPY approval

Do **not** finalize the App Privacy questionnaire from inference. Confirm with KLIPY’s current written terms and the production account:

1. Whether KLIPY retains search terms, IP/request metadata, or identifiers from this app’s requests, and for how long.
2. Whether retained data is linked to a user identity or used for tracking across apps/sites.
3. Which Apple data types apply (at minimum, evaluate Search History, Identifiers, Usage Data, and Diagnostics).
4. Whether the KLIPY API’s attribution, no-caching, independent-development, and content-distribution requirements are satisfied in every user-facing surface.
5. Whether written approval covers the app’s local normalization (resize/re-encode) and selected-GIF caching path.

If approval is not in hand, the safe release position is to hold the build or disable the compact sharing path rather than rely on `KLIPY_REVIEW_PENDING=YES`. That is a product/licensing decision for Steve.

## App Review notes draft

```text
#tiny-gifs provides two sharing paths:

1. Messages: Open a Messages conversation, open the app drawer, select #tiny-gifs, browse or search KLIPY, choose a GIF, then tap the Messages Send button if it stages in the compose field.
2. Optional keyboard: Add #tiny-gifs under Settings > General > Keyboard > Keyboards. Typing, the bundled reaction strip, and basic punctuation work without Full Access. Full Access is required to search KLIPY or copy a GIF to the pasteboard for use in a supported chat field.

No account or demo credentials are required. KLIPY provides the searchable GIF library; #tiny-gifs is independently developed and is not a KLIPY product.
```

## Owner-supplied App Review fields

- Contact first and last name
- Contact email
- Contact phone
- Age rating questionnaire responses
- Content rights / KLIPY licensing confirmation
- Final App Privacy questionnaire answers after the KLIPY retention decision
- Confirmation of whether build 52 is in TestFlight, waiting for review, or rejected
