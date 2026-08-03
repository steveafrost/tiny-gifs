# en-US App Store metadata — review copy

## Current App Store Connect values

| Field | Current value | Evidence |
| --- | --- | --- |
| Name | `#tiny-gifs` | App Info localization |
| Subtitle | `Tiny GIF reactions` | App Info localization |
| Description | See below | Version 1.0 localization |
| Keywords | `gif,reaction,emoji,stickers,messages,keyboard,imessage,chat,funny,animation` | Version 1.0 localization (75 characters) |
| Support URL | https://tinygifs.app/support | Version 1.0 localization; verified public 200 |
| Marketing URL | https://tinygifs.app | Version 1.0 localization; verified public 200 |
| Privacy policy | https://tinygifs.app/privacy | App Info localization; verified public 200 |

### Current description

> #tiny-gifs is a compact GIF reaction app built for the size of a large emoji. Start in Messages for the fastest sharing path: choose a tiny animated reaction, add it to your message, and send. Add the optional keyboard for supported chat apps: it types normally without Full Access, and with Full Access it can search GIPHY and copy a GIF for you to paste into a supported chat field. The keyboard never records, stores, or transmits what you type.

## Proposed metadata for owner approval

### Keep

- **Name:** `#tiny-gifs` (10 characters)
- **Subtitle:** `Tiny GIF reactions` (18 characters)

The subtitle is specific, fits within Apple’s 30-character subtitle limit, and does not make an unverified superiority claim.

### Replace keywords with

```text
reaction,emoji,sticker,messages,keyboard,imessage,chat,funny,animation,meme,reply,expression
```

**Length:** 92 characters (within Apple’s 100-character limit).

Rationale: removes `gif`, which is already represented in the app name, and uses the recovered space for product-relevant discovery terms. This is an ASO recommendation, not a measured ranking claim.

### Promotional text draft

> Compact GIF reactions for Messages, with an optional keyboard for supported chat apps.

Use only after confirming the optional-keyboard wording matches the final App Store positioning. Promotional text may be changed without a version release, subject to Apple’s current rules.

### Description recommendation

Keep the current description for build 1.0. It accurately distinguishes the Messages path from the optional keyboard path and states the Full Access boundary. Do not add claims such as “works everywhere,” “private,” “secure,” or a universal fixed display size; the source and support page only support the narrower behavior already described.

## Screenshot order

1. **Required new lead:** current expanded Messages drawer showing actual trending/search results and the full, untruncated grid.
2. **Ready native capture:** `../app-store-screenshots/01-keyboard-setup.png` — caption: **Tiny GIFs for chat.**
3. **Required new supporting capture:** optional keyboard in a supported chat field, showing the actual search/copy flow after Full Access has been intentionally enabled.

All final captures should be raw native iPhone screenshots at a consistent device class. Captions must describe only visible product behavior.
