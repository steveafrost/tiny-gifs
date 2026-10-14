# GIPHY integration

`#tiny-gifs` uses GIPHY as its complete searchable GIF library. The app keeps eight small owned reactions bundled as an offline fallback; they are not intended to be the catalog.

## Configuration

1. Obtain an API key through the [GIPHY API dashboard](https://developers.giphy.com/dashboard/). New keys start with free beta access, limited to 100 API calls per hour. GIPHY confirmed beta access as an option for this app; use it for a low-traffic release and review usage before expanding distribution. Enterprise access is a separate paid upgrade.
2. Supply `GIPHY_API_KEY` when building the `TinyGIFs`, `messages`, and `TinyGIFsKeyboard` targets. It is deliberately empty in source control. For a release archive, pass it as an Xcode build setting (for example, `xcodebuild … GIPHY_API_KEY="$GIPHY_API_KEY" archive`) or set it only in your local Xcode build environment.
3. Set `VITE_GIPHY_API_KEY` in the website deployment environment to activate the public library explorer.

The keyboard’s GIPHY requests and GIF pasteboard copy require Full Access. The containing app is intentionally an installer only; the Messages extension can use GIPHY normally, while keyboard text input and owned fallback reactions stay available without Full Access.

## Product constraints

- The app requests only `g`-rated GIFs using GIPHY's `messaging_non_clips` bundle and compact image renditions. Results are fetched in pages as someone searches or scrolls, rather than trying to download GIPHY's catalog onto the device.
- Search results display the required `Powered By GIPHY` attribution in every surface.
- A keyboard search term is sent to GIPHY only after the user enables Full Access and explicitly submits a search. Typed text and conversation content are never sent.
- The Messages extension downloads the selected media file, normalizes it to a 192×192 animated `MSSticker`, and sends it after the user's tap. The keyboard normalizes the selected GIF before copying it to the system pasteboard.
- Encoding keeps all frames and their timing when they fit the 490 KB budget, trying reduced color palettes before reducing frame count. Oversized animations retain the first and final frames and full duration; the 192×192 footprint is unchanged. Cache version 15 regenerates previously simplified animations.

Review GIPHY’s current API documentation and branding/attribution requirements before a production submission.
