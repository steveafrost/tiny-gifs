# #tiny-gifs App Store launch package

**Status:** review-ready; do not submit or upload metadata until the owner signs off on the open gates below.

**Prepared from:** main baseline `4a91902` and the verified build 24 release candidate. The final source commit is recorded after the release review.

## What is ready

- The public production URLs configured in App Store Connect are live and render successfully:
  - https://tinygifs.app/
  - https://tinygifs.app/privacy
  - https://tinygifs.app/support
- `metadata-en-US.md` contains the current App Store Connect values plus reviewable ASO edits.
- `privacy-and-review.md` maps observed native behavior to App Privacy and App Review inputs without asserting unverified third-party retention.
- The screenshot package defines the required high-quality native captures; no screenshot is staged for App Store upload yet.

## Submission gates

1. **App Privacy:** confirm, with GIPHY’s current contractual/privacy documentation, whether it retains search terms or other request metadata beyond servicing each request. Then complete App Store Connect’s questionnaire using `privacy-and-review.md`.
2. **Screenshots:** capture the current expanded Messages drawer while real trending/search results are present. Do not substitute an old 1.5-row drawer capture or a web mockup. Add it as the lead screenshot before upload.
3. **App Review contact:** enter the owner-approved reviewer name, email, and phone. No demo account is required by the app.
4. **Age rating/content rights:** complete Apple’s current questionnaire and confirm the GIPHY distribution/attribution obligations are met for the intended territory.
5. **Metadata approval:** approve or revise the draft keyword set and promotional text before updating App Store Connect.

## Explicit non-actions

This package does not upload screenshots, alter App Store Connect metadata, submit the app for review, or release it. Those are separate publication actions after the gates above are resolved.
