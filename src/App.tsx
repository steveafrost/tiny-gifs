import { GiphyExplorer } from './components/GiphyExplorer'
import { InfoPage } from './components/InfoPages'
import { InstallCta } from './components/InstallCta'
import { MessagesExperience } from './components/MessagesExperience'

function Arrow() {
  return <svg viewBox="0 0 20 20" aria-hidden="true"><path d="M3 10h13M11 4l6 6-6 6" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round" /></svg>
}

function SignalMark() {
  return <span className="signal-mark" aria-hidden="true"><i /><i /><i /></span>
}

function Wordmark() {
  return <span className="wordmark"><SignalMark /><span>tiny</span><b>gifs</b></span>
}

function Header() {
  return <header className="site-header" id="top">
    <a className="brand" href="#top" aria-label="Tiny GIFs home"><Wordmark /></a>
    <nav aria-label="Main navigation"><a href="#library">Library</a><a href="#how-it-works">How it works</a><a href="#the-app">The app</a></nav>
    <InstallCta className="button button--header">Get the app <Arrow /></InstallCta>
  </header>
}

function Hero() {
  return <section className="hero" aria-labelledby="hero-title">
    <div className="hero__copy">
      <p className="eyebrow"><SignalMark /> SMALL SIGNALS. BIG TIMING.</p>
      <h1 id="hero-title">The smallest thing<br /><em>that says a lot.</em></h1>
      <p className="hero__lede">Tiny GIFs brings the real GIPHY library into Messages, so the feeling lands before you have to find the words.</p>
      <div className="hero__actions"><InstallCta className="button button--primary">Get Tiny GIFs <Arrow /></InstallCta><a className="text-link" href="#library">Find your signal <Arrow /></a></div>
      <p className="hero__note">Made for Messages. One tap sends; the optional keyboard is only for supported copy-and-paste chats.</p>
    </div>
    <div className="hero__product"><div className="hero__cue">a better reply is one tap away</div><MessagesExperience /></div>
  </section>
}

function HowItWorks() {
  return <section className="how-it-works" id="how-it-works" aria-labelledby="how-title">
    <div><p className="eyebrow">The tiny gifs rhythm</p><h2 id="how-title">Less explaining.<br />More <em>exactly.</em></h2></div>
    <ol>
      <li><span>01</span><div><strong>Catch the moment</strong><p>Open Tiny GIFs beside the message field—right where the conversation is happening.</p></div></li>
      <li><span>02</span><div><strong>Find the feeling</strong><p>Search GIPHY or browse what is moving now. The full library is already in the drawer.</p></div></li>
      <li><span>03</span><div><strong>Keep the beat</strong><p>Tap once to send a compact animated attachment, then carry on talking.</p></div></li>
    </ol>
  </section>
}

function CompanionApp() {
  return <section className="app-guide" id="the-app" aria-labelledby="app-title">
    <div className="app-guide__copy"><p className="eyebrow"><SignalMark /> The downloaded app</p><h2 id="app-title">Open once.<br />Make it <em>yours.</em></h2><p>The downloaded app gives the Tiny GIFs signal its home: a quick orientation to the one-tap Messages path, with the keyboard kept clearly secondary.</p><InstallCta className="button button--light">Get Tiny GIFs <Arrow /></InstallCta></div>
    <div className="app-guide__screen" aria-label="A preview of the Tiny GIFs first-launch app">
      <div className="app-guide__status"><span>9:41</span><span>◒ ◔ ◼</span></div>
      <div className="app-guide__content"><p><span className="app-guide__mini-mark" aria-hidden="true">•••</span> tiny gifs <b>SMALL SIGNALS</b></p><h3>A little more you,<br />in Messages.</h3><span>The real GIPHY library is right beside the message field.</span><div className="app-guide__message-preview"><div>Need a reaction for that.</div><p><span>⌕</span> Search GIPHY <b>tiny gifs</b></p><small>Open the drawer. Find the feeling. Send it.</small></div><div className="app-guide__action">Open Messages</div><div className="app-guide__optional"><strong>Optional keyboard</strong><span>Only for copy-and-paste in supported chats.</span></div></div>
    </div>
  </section>
}

function ProductNotes() {
  return <section className="product-notes" aria-label="Tiny GIFs principles">
    <div><p className="product-notes__label"><span>01</span> Keep it tiny</p><p>Real GIFs stay readable—enough feeling, no takeover.</p></div>
    <div><p className="product-notes__label"><span>02</span> Keep it yours</p><p>No account, profile, analytics SDK, or advertising SDK inside the app.</p></div>
    <div><p className="product-notes__label"><span>03</span> Keep it moving</p><p>The optional keyboard is there only when copy-and-paste is the better move.</p></div>
  </section>
}

function Footer() {
  return <footer><a href="/privacy">Privacy</a><a href="/support">Support</a><p>Made for the moment between the words.</p></footer>
}

export default function App() {
  if (window.location.pathname === '/privacy') return <InfoPage page="privacy" />
  if (window.location.pathname === '/support') return <InfoPage page="support" />
  return <><Header /><main><Hero /><GiphyExplorer /><HowItWorks /><CompanionApp /><ProductNotes /></main><Footer /></>
}
