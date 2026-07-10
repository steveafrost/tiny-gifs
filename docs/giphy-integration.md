# GIPHY integration

`#tiny-gifs` uses GIPHY as its complete searchable GIF library. The app keeps eight small owned reactions bundled as an offline fallback; they are not intended to be the catalog.

## Configuration

1. Create a production API key through the [GIPHY API dashboard](https://developers.giphy.com/docs/api/).
2. In Xcode, set `GIPHY_API_KEY` for the `TinyGIFs`, `TinyGIFsMessages`, and `TinyGIFsKeyboard` targets. It is deliberately empty in source control.
3. Set `VITE_GIPHY_API_KEY` in the website deployment environment to activate the public library explorer.

The keyboard’s GIPHY requests and GIF pasteboard copy require Full Access. The host app and Messages extension can use GIPHY normally, while text input and owned fallback reactions stay available without Full Access.

## Product constraints

- The app requests only `g`-rated GIFs using GIPHY's `messaging_non_clips` bundle and compact image renditions.
- Search results display the required `Powered By GIPHY` attribution in every surface.
- A keyboard search term is sent to GIPHY only after the user enables Full Access and explicitly submits a search. Typed text and conversation content are never sent.
- The messages extension downloads a selected media file to its cache before presenting it as a sticker. The keyboard does the same before copying its GIF to the system pasteboard.

Review GIPHY’s current API documentation and branding/attribution requirements before a production submission.
