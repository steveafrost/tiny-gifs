# #tiny-gifs website implementation brief

## Product

`#tiny-gifs` is an iPhone custom keyboard concept built around one sharp idea: animated reactions should feel about as visually compact as a large emoji instead of taking over the message transcript.

The website is a polished product landing page and interactive demo. It does not claim that a keyboard extension can be installed directly from the web. iOS custom keyboards ship inside an iPhone app, so the implementation must support a configurable App Store or TestFlight URL while explaining the real setup steps.

## Accepted visual specification

The user approved [`docs/design/accepted-concept.png`](./design/accepted-concept.png). Treat it as the source of truth for layout, copy, palette, typography character, section rhythm, borders, color fields, and component geometry.

### Design tokens

- Canvas: warm near-white `#F7F4EE`
- Ink: `#111111`
- Electric lime: `#C8FF3D`
- Coral: `#FF6B57`
- Sky blue: `#71C9FF`
- Rules: crisp black, generally `2px`
- Display type: chunky, compressed, friendly grotesk
- UI/body type: clean neutral sans
- Corners: restrained, not pill-heavy
- Motion: subtle bobbing reaction shapes, comparison slider, responsive button feedback

Avoid glossy gradients, glassmorphism, generic SaaS card grids, fake testimonials, app-store badges, QR codes, pricing, hero eyebrows, badges, or decorative filler.

## Required page structure and locked copy

1. Quiet header
   - Brand: `#tiny-gifs`
   - Links: `How it works`, `Why tiny`
   - CTA: `Get the keyboard`
2. Split hero
   - H1: `Big reaction. Tiny footprint.`
   - Body: `A whole GIF keyboard built for the size of a large emoji. All the motion, none of the wall-of-GIF.`
   - CTAs: `Get #tiny-gifs`, `See it in action`
   - Generic message-transcript demo comparing a conventional oversized reaction with the compact version
3. Footprint comparison
   - Heading: `Same energy. 84% less chat.`
   - Interactive before/after slider or an equivalently clear accessible control
4. Reaction rail
   - Original abstract reaction shapes labeled `lol`, `nope`, `omg`, `brb`, `perfect`
5. Installation
   - Heading: `On your keyboard in under a minute.`
   - Steps: `Download the app`, `Add #tiny-gifs in Settings`, `Tap, copy, paste`
   - Note: `Display size can vary by messaging app.`
6. Closing band
   - Heading: `Keep the reaction. Lose the interruption.`
   - CTA: `Get the keyboard`
7. Minimal footer
   - `Privacy`, `Support`, `Built tiny on purpose.`

## Installation behavior

- Read an install destination from `VITE_INSTALL_URL`.
- If configured, the CTA may open that URL in a new tab with safe external-link attributes.
- If not configured, open an accessible install sheet/modal that says the beta invite is not live yet and clearly explains that the keyboard comes through an iPhone app.
- Do not invent or hard-code an App Store or TestFlight URL.
- Include setup instructions: install app, go to Settings, enable the keyboard, then select and paste a reaction.

## Functional requirements

- React + Vite + TypeScript.
- Responsive desktop and mobile layouts with no horizontal overflow.
- Semantic landmarks, keyboard navigation, visible focus states, and reduced-motion support.
- Working anchor navigation and buttons.
- The comparison control must update real local UI state.
- Reaction previews should animate subtly without relying on remote assets.
- Avoid copyrighted reaction GIFs; use original abstract geometric reaction characters.
- Keep the main composition component-focused rather than a monolithic `App`.
- Add lint/build scripts and a concise README with local setup and install-link configuration.

## Verification target

Match the accepted concept at its native portrait overview and verify practical browser viewports at desktop and mobile sizes. Pay particular attention to:

- First-viewport balance and exact hero copy
- Compressed display typography
- Black rule system and warm canvas color
- Message transcript proportions
- The `Same energy` comparison anatomy
- Reaction rail character and rhythm
- Installation step legibility
- Dark closing-band balance
- Mobile wrapping and overflow

