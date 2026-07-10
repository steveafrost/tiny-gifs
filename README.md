# #tiny-gifs

A responsive React + Vite landing page for the #tiny-gifs iPhone keyboard concept. The visual reference is [docs/design/accepted-concept.png](docs/design/accepted-concept.png).

## Local development

```bash
npm install
npm run dev
```

Run `npm run lint` and `npm run build` before handing off a change.

The production build writes browser assets to `dist/client`, prepares the Sites worker entrypoint at `dist/server/index.js`, and copies `.openai/hosting.json` into the deployable output. The worker delegates static files to the platform asset binding and falls back to `index.html` for client-side routes.

## Install destination

The CTA intentionally does not contain a hard-coded App Store or TestFlight link. Configure a real destination at build time with:

```bash
VITE_INSTALL_URL="https://example.com/your-real-invite" npm run dev
```

When this value is absent or invalid, the CTA opens an accessible sheet that explains that #tiny-gifs is installed through an iPhone app and enabled in iOS keyboard settings.

## Notes

All reaction artwork is original, code-native SVG and CSS animation. No remote images, fonts, reaction GIFs, or third-party visual assets are used.
