# KLIPY integration

The migration uses KLIPY GIF API v1 for native and website search and trending. Production build 48 still uses GIPHY and remains in Apple's review queue.

## Configuration

- Create/manage a key in the [KLIPY Partner Panel](https://partner.klipy.com/). Testing keys are limited to 100 requests per hour; request production access before expanding distribution.
- Native targets read `KLIPY_API_KEY` from their build configuration. Website builds read `KLIPY_API_KEY`. Never commit keys; client API keys are necessarily included in distributed client builds.
- The compact Messages/keyboard sharing path requires written KLIPY approval for local resizing and retained normalized media. Until that approval is obtained, `KLIPY_MEDIA_PROCESSING_APPROVED` defaults to `NO`; browsing works, provider media processing is gated, and the release script refuses an archive/upload.
- After approval, set `KLIPY_MEDIA_PROCESSING_APPROVED=YES` in the local build environment and implement any expiration/invalidation requirements supplied by KLIPY before distributing.

## Behavior

- Requests originate on the end-user client at `https://api.klipy.com/api/v1/{key}/gifs/{trending|search}`.
- Paging uses `page` and `has_next`. Native searches fetch 24 results; the keyboard fetches 8, respecting KLIPY's minimum page size.
- Search queries preserve submitted text. Requests use `content_filter=high`, `locale=us`, and `format_filter=gif`.
- Result order is preserved. Unsupported ads or incomplete records fail the page instead of silently removing results. Configure a GIF-only, non-ad integration in the Partner Panel; ad rendering is not implemented.
- The grid loads the provider's small GIF previews directly. Only the selected full GIF is downloaded into a temporary local file, which is removed after processing.
- Attribution is visible as “Powered by KLIPY”; search placeholders say “Search KLIPY”. No persistent customer identifier is introduced.
- The existing 288×288 encoder preserves all frames where possible, reduces palette detail before frames, and retains both endpoints and full duration when reduction is necessary.

## Release

Run `scripts/release-testflight.sh <number> --validate` to verify API access without accepting an unresolved media-processing approval. Archive/upload requires approval as described above. Review App Store privacy and metadata before a KLIPY release.

See [KLIPY API documentation](https://docs.klipy.com/), [API terms](https://klipy.com/support/api-terms), and [privacy policy](https://klipy.com/support/privacy-policy).

## Owner-requested internal testing

`KLIPY_INTERNAL_TESTING=YES` enables compact sharing solely for the requested internal TestFlight evaluation without asserting production approval. The release script sets Apple’s `testFlightInternalTestingOnly` export option, preventing App Store or external testing distribution. Defaults remain disabled. Public distribution still requires KLIPY approval and its caching requirements.

Cache version 16 regenerates attachments at the 50% larger dimensions. Build 50’s preloading and “Preparing…” tile treatment did not resolve the physical-device staging issue and have been removed. The app calls Apple’s direct-send API, but automatic sending remains unverified and reported not working on the owner’s phone.

The owner reproduced staging on iOS 27.0.1 in a blue iMessage conversation with an empty compose box. The simulator did not reproduce the interaction, and protocol-double tests verify API invocation only; they do not establish automatic sending in Messages.

## Owner-requested App Store review while approval is pending

`KLIPY_REVIEW_PENDING=YES` enables the tested sharing path for an App Store review build without asserting provider approval. `KLIPY_MEDIA_PROCESSING_APPROVED` remains `NO` and `KLIPY_INTERNAL_TESTING` remains `NO`. The owner explicitly selected automatic App Store release while KLIPY’s reply is pending. App Store approval may therefore publish this build before provider approval arrives. This mode does not grant provider approval.
