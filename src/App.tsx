import { GiphyExplorer } from './components/GiphyExplorer'
import { InfoPage } from './components/InfoPages'
import { InstallCta } from './components/InstallCta'
import { MessagesExperience } from './components/MessagesExperience'

function Arrow() {
  return <svg viewBox="0 0 20 20" aria-hidden="true"><path d="M3 10h13M11 4l6 6-6 6" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round" /></svg>
}

function Header() {
  return <header className="site-header" id="top">
    <a className="brand" href="#top">tiny gifs</a>
    <nav aria-label="Main navigation"><a href="#library">Library</a><a href="#how-it-works">How it works</a></nav>
    <InstallCta className="button button--header">Get the app <Arrow /></InstallCta>
  </header>
}

function Hero() {
  return <section className="hero" aria-labelledby="hero-title">
    <div className="hero__copy">
      <p className="eyebrow">A GIPHY-powered Messages extension</p>
      <h1 id="hero-title">The GIF you mean.<br />Without the detour.</h1>
      <p className="hero__lede">Browse the real GIPHY library in Messages. Tap once and Tiny GIFs sends a compact animated attachment straight into the conversation.</p>
      <div className="hero__actions"><InstallCta className="button button--primary">Get Tiny GIFs <Arrow /></InstallCta><a className="text-link" href="#library">Browse the library <Arrow /></a></div>
      <p className="hero__note">Messages is native and one-tap. The optional keyboard is for copy-and-paste in supported chats.</p>
    </div>
    <MessagesExperience />
  </section>
}

function HowItWorks() {
  return <section className="how-it-works" id="how-it-works" aria-labelledby="how-title">
    <div><p className="eyebrow">Built around the conversation</p><h2 id="how-title">Native in Messages.<br />Useful everywhere else.</h2></div>
    <ol>
      <li><span>01</span><div><strong>Open the drawer</strong><p>Tiny GIFs lives alongside the apps you already use in Messages.</p></div></li>
      <li><span>02</span><div><strong>Search the real library</strong><p>Find trending GIFs or search GIPHY for the exact reaction.</p></div></li>
      <li><span>03</span><div><strong>Send, then keep talking</strong><p>The selected GIF is normalized to a consistent 192 × 192 attachment canvas before it sends.</p></div></li>
    </ol>
  </section>
}

function ProductNotes() {
  return <section className="product-notes" aria-label="Product details">
    <div><p className="product-notes__label">Small on purpose</p><p>Real GIFs stay readable without taking over the conversation.</p></div>
    <div><p className="product-notes__label">No account</p><p>No profile, analytics SDK, or advertising SDK inside the app.</p></div>
    <div><p className="product-notes__label">Optional keyboard</p><p>Use it only when you need GIPHY search and copy-paste outside Messages.</p></div>
  </section>
}

function Footer() {
  return <footer><a href="/privacy">Privacy</a><a href="/support">Support</a><p>Made for the message, not the feed.</p></footer>
}

export default function App() {
  if (window.location.pathname === '/privacy') return <InfoPage page="privacy" />
  if (window.location.pathname === '/support') return <InfoPage page="support" />
  return <><Header /><main><Hero /><GiphyExplorer /><HowItWorks /><ProductNotes /></main><Footer /></>
}
