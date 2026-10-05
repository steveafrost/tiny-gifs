# GIPHY release repair draft — October 5, 2026

This local patch is not included in uploaded1.0(45), source8536866. No replacement upload, submission, provider agreement, privacy answer, age rating or pricing change was made.

## Concrete source repairs

- Both native service copies decode available creator display name/username, then source host fallback. Messages displays a compact credit overlay; keyboard remote-result columns include a creator/source label. Existing conspicuous Powered by GIPHY branding remains.
- API/media requests use an ephemeral URLSession with no URLCache and reload-ignoring-local-cache policy. Media downloads receive fresh UUID-named temporary files, not reused `Caches/GiphyMedia` entries.
- Remote rendered attachments use fresh temporary output; the original persistent renderer path remains for owned bundled reactions. Keyboard deletes its own temporary source/output after copying; Messages cleans picker-owned temporary sources at picker destruction and normalized output after send completion. Existing historical cache directories are not purged.
- Added native regression: rendering the same remote identifier twice produces distinct temporary files that remain valid MSSticker input.

Generic simulator app/extension compilation passed. Standalone Foundation harness passed creator name, username, source fallback, absent credit and session-cache-policy checks. Native regression test execution and visual layout verification remain unrun pending a coordinated simulator slot. No physical behavior inferred.

## Existing approval evidence

Relevant checkout docs contain setup instructions and production-key references, but no actual production approval letter, paid-distribution agreement or caching exception. API key functioning/preflight is not proof of these permissions. Existing authorized user mailbox is not exposed in this resumed tool environment; AgentMail tools are a different inbox surface, not evidence of access to Steve's GIPHY correspondence. Parent can use its existing mailbox/browser worker for a narrow GIPHY approval/agreement lookup, or request owner proof.

## Minimum owner/provider decision packet

1. Does the existing production agreement allow a $0.99 paid app using GIPHY API content, with what limits/fees? Supply that existing approval/agreement or an applicable explicit license. API Terms license API applications but incorporate User Terms; User Terms §5 restricts commercial exploitation of content absent permission. This is not a categorical finding that every paid API app is prohibited.
2. Does approval expressly cover this app's temporary media processing for MSSticker/pasteboard, resized animated output and available creator/source credit? Public API Terms require branding and available content attribution. Public developer docs prohibit media caching without approval; this patch stops persistent reuse without deleting prior caches. Whether transient delivery files satisfy provider policy still requires integration-specific confirmation.
3. For Apple App Privacy, which fields are retained beyond serving this integration's query/API/CDN request, purposes, linkage and tracking? Recommended retained query category is Search History/App Functionality; analytics and other categories depend on actual provider handling. General GIPHY policy describes retained query/IP/device/cookie data and advertising-related practices; no account/no SDK does not prove unlinked/no tracking.
4. Review minimum audience against existing contract: incorporated User Terms state service minimum13, or16 in certain European jurisdictions. Do not preserve4+ or invent an Apple age override without the applicable integration terms/owner decision.

Sources checked October5:
- https://support.giphy.com/hc/en-us/articles/360028134111-GIPHY-API-Terms-of-Service
- https://support.giphy.com/hc/en-us/articles/360020027752-GIPHY-User-Terms-of-Service
- https://developers.giphy.com/docs/api/
- https://support.giphy.com/hc/en-us/articles/360032872931-GIPHY-Privacy-Policy

No outreach or terms acceptance authorized/performed by this repair.

## Coordinated runtime attempt

Focused native execution was attempted on owned simulator9F12FC56-772C-49BC-93C5-A851B16C8561 after Knight School released its slot. Simulator booted, but no test case began during the brief slot. Owned testmanagerd logged `listener failed to activate: xpc_error=[1: Operation not permitted]`. Stopped only owned xcodebuildPID35558 withSIGINT thenSIGTERM; process absence verified; no global resets or other services changed. Build-for-testing had passed. Native21-test execution remains UNRUN, not failed assertions. UI control tools are absent from this resumed environment; actual creator-label/send/copy visual checks remain pending in browser/UI worker environment. Slot released for next app.

## Exact test-launch evidence and recovery plan

Executed test-case count0 (no Test Case started records; test stdout empty). Logs: `/tmp/tg-provider-tests.log`. Partial bundle: `/Users/white-box/Documents/Codex/2026-10-02/task-8/provider-repair-tests.xcresult`; it contains Staging diagnostics but no Info.plist, so xcresulttool cannot summarize it. Session began11:39:36UTC; testmanager socket initially missing (POSIX2), available11:39:39; app-launch request11:40:45; canceled11:42:10 after155seconds. Final NSMachErrorDomain-308 server-died report at11:42:15 followed cancellation, so it does not independently establish the original cause. No completed/failed assertions.

Next exclusive slot: verify own simulator bootstatus and testmanager socket readiness; install compiled host and smoke-launch it without XCTest injection. If host launches, run only testRemoteRenderingDoesNotReuseAPersistentAttachment first with parallel testing disabled and a fresh result path. If injected launch still stalls, try one newly created dedicated device after parent coordination; do not reset global CoreSimulator or erase existing devices. Capture test-manager/session logs and stop only owned runner. Full suite and UI verification follow only after targeted launch works. No runtime action taken while Fluency owns slot.

Durable offline fixture script `scripts/test-giphy-provider-fixtures.sh` checks both native service copies without API requests or simulator.

## Existing mailbox evidence reported by parent

Parent's authorized mailbox worker01a10c76 found only:
- Production Key Request Received for #tiny-gifs, July11 2026 14:24UTC: receipt, not approval.
- API Beta Key Created, July11 2026 13:10UTC.
- SDK Beta Key Created, September30 2026 02:30UTC.

Reported sender: donotreply@outbound.developers.giphy.com to the existing developer account. Beta messages require a commercial-license/pricing discussion and integration/attribution recordings for production access. No production approval, paid-distribution permission, caching exception or privacy agreement found across the worker's authorized All Mailboxes search. This is parent-reported correspondence evidence; raw messages were not independently read in this environment. Public API functioning does not establish production permission. Publication remains HOLD. No provider outreach performed.

## Minimum technical recording package after runtime recovery

1. Actual iPhone Messages expanded trending and benign search with Powered by GIPHY and available creator/source credit visible. Capture one selection, successful immediate send and dismissal; show the animated result in the test conversation. Record exact candidate version/build/source and simulator versus physical device.
2. Actual optional keyboard search and credited results, selected GIF copy, paste into an unsent supported test composer. Enable Full Access only through explicitly authorized permitted UI; do not infer this from earlier permission denial. Show keyboard branding and available creator/source credit.
3. Supply concise technical note: direct client API/CDN requests, g-rated results, per-interaction transient download/normalization for MSSticker or pasteboard, no persistent remote reuse after patch, no proxy or user-conversation upload. Ask whether this temporary processing/resizing is approved and what source-credit format is required; do not represent the patch as provider-certified.

Provider follow-up needs only existing key identifiers through a supported private flow, $0.99 paid-app model, requested iOS Messages/keyboard production scope, recordings above, and precise questions about licensing/limits/fees, temporary processing, attribution and API-specific privacy retention/purposes/linkage/tracking. Do not include key secrets. Parent is handling owner authorization for any draft/send. Native test execution and actual UI recordings remain pending; no fabricated footage.

## Recovered runtime verification

Selected Xcode27.0 build27A266a on recovered macOS27.0.1. On dedicated iOS26.5 simulator9F12FC56-772C-49BC-93C5-A851B16C8561, targeted transient-media regression passed1test/0failures; full native suite passed21tests/0failures. Fresh result bundles at task root: `provider-targeted27.xcresult`, `provider-full27.xcresult`. No provider network requests or FullAccess changes were required. UI interaction tools remain unavailable in this task, so creator-credit visual layout and send/copy recordings need the existing UI worker. Runtime slot released immediately after fullsuite. Uploadedbuild45 unchanged.
