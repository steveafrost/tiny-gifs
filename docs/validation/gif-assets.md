# GIF asset validation

The starter catalog is owned by this repository. `ios/Shared/ArtworkSources/` contains deterministic SVG source artwork; `ios/Shared/Resources/GIFs/` contains the checked-in 300×300 PNG and GIF exports used by the app and extensions.

The current source artwork is a deliberate static fallback. The environment has no checked-in, reproducible animation encoder, so each reaction is exported as a compact static GIF for the Messages attachment and keyboard pasteboard paths, plus a matching PNG for in-app previews. This is intentionally documented rather than being presented as animation. The designs remain original and transparent-edged.

`CatalogIntegrityTests.testTinyGIFAssetsMeetCompactBudgetAndDimensions` rejects missing media, media at or above 500 KB, and PNGs that are not 300×300 pixels. Before release, replace the static GIFs with short seamless animated GIF exports and retain the same names, dimensions, and budget test.
