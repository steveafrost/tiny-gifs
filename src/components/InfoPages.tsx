import { InstallCta } from './InstallCta'

type Page = 'privacy' | 'support'

export function InfoPage({ page }: { page: Page }) {
  const isPrivacy = page === 'privacy'
  return <div className="info-page">
    <header className="site-header"><a className="brand" href="/">#tiny-gifs</a><nav aria-label="Main navigation"><a href="/#how-it-works">How it works</a><a href="/#why-tiny">Why tiny</a></nav><InstallCta className="button button--lime button--header">Get the keyboard</InstallCta></header>
    <main className="info-page__main">
      <p className="info-page__label">#tiny-gifs</p>
      <h1>{isPrivacy ? 'Private by\ndesign.' : 'Support for\ntiny reactions.'}</h1>
      {isPrivacy ? <PrivacyContent /> : <SupportContent />}
    </main>
    <footer><a href="/privacy">Privacy</a><a href="/support">Support</a><p>Built tiny on purpose.</p></footer>
  </div>
}

function PrivacyContent() {
  return <div className="info-page__content">
    <p>#tiny-gifs ships a small owned fallback catalog on your iPhone, plus optional GIPHY search for the full reaction library. The app has no account, analytics SDK, or advertising SDK.</p>
    <h2>Keyboard privacy</h2>
    <p>The keyboard never records, stores, or transmits what you type. It works without Full Access for typing and browsing bundled reactions. If you enable Full Access, a GIF search term is sent to GIPHY to find media and the selected GIF is downloaded to copy to the system pasteboard. Conversation text and typed characters are never sent.</p>
    <h2>Questions</h2>
    <p>GIPHY handles its service requests under its own privacy terms. #tiny-gifs does not create a user profile or retain a search history on a server.</p>
  </div>
}

function SupportContent() {
  return <div className="info-page__content">
    <h2>Start with Messages</h2>
    <ol><li>Install #tiny-gifs on your iPhone.</li><li>Open a Messages conversation and tap the app drawer.</li><li>Choose #tiny-gifs, tap a sticker, then tap Send.</li></ol>
    <h2>Use the optional keyboard</h2>
    <ol><li>Go to Settings → General → Keyboard → Keyboards → Add New Keyboard.</li><li>Add #tiny-gifs. It types and browses bundled reactions without Full Access.</li><li>Turn on Full Access to search the full GIPHY library, tap a GIF to copy it, then paste it into a supported chat field.</li></ol>
    <p>Messaging apps control final attachment rendering. The small sticker assets are designed for large-emoji scale, but exact display size varies by app.</p>
  </div>
}
