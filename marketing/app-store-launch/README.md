# #tiny-gifs App Store launch package

**Status:** not ready to submit; build 52 is uploaded but its App Store Connect/TestFlight review state is unverified. Do not submit or upload metadata until the owner signs off on the open gates below.

**Prepared from:** the KLIPY review branch at `fd831b4` and archived build 52 (version 1.0, uploaded 2026-10-15). The final release commit must be recorded after verification.

## What is ready

- The public production URLs configured in App Store Connect are live and render successfully:
  - https://tinygifs.app/
  - https://tinygifs.app/privacy
  - https://tinygifs.app/support
- `metadata-en-US.md` contains the current App Store Connect values plus KLIPY-corrected ASO edits.
- `privacy-and-review.md` maps observed native behavior to App Privacy and App Review inputs, including the KLIPY terms/privacy findings. It does not assert a final data label while KLIPY retention remains unconfirmed.
- The screenshot package defines the required high-quality native captures; no current KLIPY screenshot is staged for App Store upload yet.

## Submission gates

1. **KLIPY approval:** obtain written approval for local media resizing/re-encoding and selected-GIF caching, or explicitly choose to hold the release. Build 52’s `KLIPY_REVIEW_PENDING=YES` is not provider approval.
2. **App Privacy:** complete the questionnaire from KLIPY’s current privacy policy and terms, including search terms, IP/request metadata, identifiers, usage data, and diagnostics. Do not infer a final label.
3. **Screenshots:** capture the current expanded Messages drawer with real KLIPY trending/search results. Add the current keyboard and host app captures. Do not substitute old GIPHY or 1.5-row drawer captures.
4. **App Review contact:** enter the owner-approved reviewer name, email, and phone. No demo account is required by the app.
5. **Age rating/content rights:** complete Apple’s current questionnaire and confirm KLIPY’s attribution, no-caching, independent-development, and content-distribution obligations for the intended territory.
6. **Metadata approval:** approve or revise the KLIPY keyword set, promotional text, description, and “What’s New” before updating App Store Connect.
7. **Physical-device QA:** verify the current keyboard layout/typing and the Messages send/staging behavior on a real iPhone.

## Explicit non-actions

This package does not upload screenshots, alter App Store Connect metadata, submit the app for review, or release it. Those are separate publication actions after the gates above are resolved.
