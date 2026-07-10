# Fidelity ledger

Accepted concept: [`accepted-concept.png`](./accepted-concept.png)

Verification date: July 10, 2026

Rendered with Vite at `http://127.0.0.1:4173` and inspected with local Playwright at 1440×1000 and 390×844. The in-app Browser plugin was selected first, but its required control runtime was not available in this session, so Playwright was used as the documented fallback.

| Comparison point | Concept evidence | Final render evidence | Resolution |
| --- | --- | --- | --- |
| Header and first viewport | Quiet three-part header, lime CTA, split hero | Same information hierarchy, border system, CTA and transcript balance | Fixed an unintended display-font logo overlap by giving the wordmark a dedicated bold sans stack |
| Hero copy and typography | Two locked display lines with coral punctuation | Exact H1 and body copy render in the same two-line hierarchy | Reduced desktop display size and locked deliberate line breaks; mobile remains responsive |
| Palette and rules | Warm near-white canvas, black 2px rules, lime/coral/blue accents | Matching token values are used across every section | No intentional deviation |
| Transcript comparison | Large reaction versus large-emoji-scale reaction | Code-native transcript uses original SVG reactions in both sizes | Generic code-native glyphs replace platform-specific icons to avoid copying iOS artwork |
| Footprint section | Two transcript panes with a lime center control | Same pane anatomy, labels, divider, and control; slider updates real state from 0–100 | Verified state change from 50% to 90% |
| Reaction rail | Five geometric reactions labeled lol/nope/omg/brb/perfect | Same five labels, colors, order, frames, and subtle bobbing motion | No intentional deviation |
| Installation section | Three numbered setup steps plus display-size caveat | Exact headings, steps, labels, and caveat; CTA opens an honest beta sheet when no URL is configured | Modal is functional rather than a static mockup |
| Closing band and footer | Dark band, abstract burst, lime CTA, three footer items | Same section order, contrast, artwork, CTA, and footer copy | No intentional deviation |
| Responsive behavior | Mobile-aware one-column continuation | 390×844 layout has no horizontal overflow and preserves all content | Header navigation wraps to a second row on small screens |

## Copy audit

The above-the-fold nav, H1, body, and CTA strings match the accepted concept exactly. No hero eyebrow, badge, testimonial, pricing claim, fake App Store link, or extra proof copy was added.

## Functional evidence

- Page title and meaningful DOM content render successfully.
- Console after favicon fix: 0 errors, 0 warnings.
- Comparison slider: 50% → 90%, with accessible state text updating.
- Install CTA: opens a modal explaining the real iPhone-app requirement and closes cleanly.
- Desktop document width: 1440 at a 1440 viewport; no horizontal overflow.
- Mobile document width: 390 at a 390 viewport; no horizontal overflow.

