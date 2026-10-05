# GIPHY follow-up — unsent draft

To: developers@giphy.com
Subject: #tiny-gifs production application: paid iOS release, integration and privacy requirements

Destination verified October5,2026: GIPHY's official API Quickstart lists developers@giphy.com for integration questions: https://developers.giphy.com/docs/api/ . Use a new message to this developer-support address; do not reply blindly to automated donotreply notices. No message has been sent.

## Draft body

Hello GIPHY Developer Support,

I'm following up on the #tiny-gifs production-key request received July11,2026. We have that receipt and beta-key creation notices, but haven't located a production approval or commercial agreement.

#tiny-gifs is an iOS Messages extension with an optional keyboard (bundle com.tinygifs.app; https://tinygifs.app). We plan worldwide distribution as a one-time paid download, with a US$0.99 base price and no subscriptions, in-app purchases or ads.

Could you confirm:

1. Our production application's status and the commercial permission, pricing, limits and platform/section key requirements for this release? Please identify any remaining approval steps; we will review any proposed agreement separately.
2. Whether our intended media handling is permitted: direct client trending/search and media requests, g-rated results, transient downloads for browsing and selected GIF normalization to compact animated192×192 MSSticker/pasteboard files. We are preparing a patch that stops persistent remote-media reuse and removes its own temporary files after use. No proxy or catalog database is used. Is transient processing/resizing allowed, and are additional caching/revalidation rules required?
3. The required attribution format: we display Powered by GIPHY branding and are adding available creator display name/username or source credit per result. Are source links or other placement/branding changes required? What integration recordings should accompany review?
4. For our direct API/media integration, which query, IP, device, cookie or other fields are retained beyond serving a request, for how long and for which purposes? Are they linked to identifiable users/devices or combined with other apps/sites' data for advertising/measurement or broker sharing? We need these specifics for Apple's App Privacy labels. Our code sends search terms but no conversation text, account IDs, IDFA/IDFV, customer_id, random_id or analytics pingbacks.
5. What minimum audience age and territorial restrictions apply to this integration?

We can provide authentic Messages and keyboard recordings once verification of the updated candidate is complete. Please let us know how to identify the existing application securely without emailing API secrets.

Thank you,
Steve Frost

## Review notes — excluded from send body

- Worldwide distribution is intended scope for the question, not a claim that Apple availability is configured.
- Patch is local and compiled/fixture-tested; native runtime and new UI recordings remain pending. Uploaded1.0(45) still has the older caching/credit behavior. Do not imply the patch is shipped or provider-approved.
- Mailbox dates/history are parent-reported findings from authorized worker01a10c76; no raw message contents independently inspected here.
- No keys, personal conversations, payment information or attachments included.
- Parent/Steve must approve exact recipient/body and sending. No outreach, new terms acceptance or publication performed.
