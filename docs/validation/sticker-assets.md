# Sticker asset validation

The starter catalog is owned by this repository. `ios/Shared/ArtworkSources/` contains deterministic SVG source artwork; `ios/Shared/Resources/Stickers/` contains the checked-in 300×300 PNG and GIF exports used by the extensions.

The current source artwork is a deliberate static fallback. The environment has no checked-in, reproducible animation encoder, so each reaction is exported as a compact static GIF for the keyboard pasteboard path and a matching PNG for the Messages sticker browser. This is intentionally documented rather than being presented as animation. The designs remain original, transparent-edged, and scaled to Apple's Small sticker recommendation.

`CatalogIntegrityTests.testStickerAssetsMeetSmallStickerBudgetAndDimensions` rejects missing media, media at or above 500 KB, and PNGs that are not 300×300 pixels. Before release, replace the static GIFs with short seamless animated GIF or APNG exports and retain the same names, dimensions, and budget test.
