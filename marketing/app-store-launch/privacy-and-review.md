# App Privacy and App Review preparation

This document is a source-backed preparation aid, not legal advice and not a substitute for the current App Store Connect privacy questionnaire.

## Observed behavior in the released source

| Behavior | Source evidence | App Store review implication |
| --- | --- | --- |
| GIPHY trending/search requests | `ios/messages/GiphyService.swift:56-62,76-88`; `ios/Shared/GiphyService.swift` mirrors it | Requests include a GIPHY API key, a `g` rating, and a user-entered `q` search term when searching. |
| Downloading selected GIPHY media | `ios/messages/GiphyService.swift:64-73`; `ios/Shared/GiphyService.swift` mirrors it | Selected media is cached locally before use. |
| Optional keyboard search and copy boundary | `ios/TinyGIFsKeyboard/KeyboardViewController.swift:86-113,133-145` | Keyboard GIPHY search and GIF copying are blocked until Full Access is enabled; typing and the bundled reaction grid remain available. |
| Selected GIF pasteboard copy | `ios/TinyGIFsKeyboard/KeyboardViewController.swift:86-94,133-145` | The keyboard writes the GIF selected by the user to the system pasteboard. |
| Typed text behavior | `KeyboardViewController.swift:62-75` inserts/deletes requested keys; no context-read API was found in the inspected source | Do not claim the keyboard sends typed text. Verify this remains true after future changes. |
| Accounts, analytics, advertising, device permissions | Native source scan found no account, analytics/advertising SDK, tracking, location, contacts, photos, health, or cloud-storage API use | Supports the narrow “no account, analytics SDK, or advertising SDK” statement in the privacy page. |

## Required owner decision: GIPHY retention and Apple data label

The app transmits search terms to GIPHY and requests GIPHY media. App Store Connect’s definition of “collected” depends on whether the receiving party retains the data beyond servicing the request. The GIPHY policy endpoint was not retrievable in this session, so **do not mark a final data label based on inference.**

Before completing the questionnaire, confirm from the current GIPHY terms/privacy documentation and the production account configuration:

1. Whether GIPHY retains search terms, IP/device/request metadata, or identifiers from this app’s requests.
2. Whether any retained data is linked to a user identity or used for tracking across apps/sites.
3. Which Apple data type GIPHY’s retained search term/request data maps to, if any.
4. Whether the API’s GIPHY attribution and content/distribution requirements are satisfied in every user-facing surface.

If GIPHY only processes a request transiently and does not retain it, document that evidence with the release record. If it does retain search terms, disclose the appropriate Apple data type and purpose exactly as the questionnaire directs.

## App Review notes draft

```text
#tiny-gifs provides two sharing paths:

1. Messages: Open a Messages conversation, open the app drawer, select #tiny-gifs, browse or search GIPHY, then tap a GIF to send it immediately.
2. Optional keyboard: Add #tiny-gifs under Settings > General > Keyboard > Keyboards. Typing and the bundled reaction grid work without Full Access. Full Access is required to search GIPHY or copy a GIF to the pasteboard for use in a supported chat field.

No account or demo credentials are required.
```

## Owner-supplied App Review fields

- Contact first and last name
- Contact email
- Contact phone
- Age rating questionnaire responses
- Content rights / GIPHY licensing confirmation
- Final App Privacy questionnaire answers after the GIPHY retention decision
