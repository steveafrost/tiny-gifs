import type { CSSProperties } from 'react'
import { FootprintComparison } from './components/FootprintComparison'
import { GiphyExplorer } from './components/GiphyExplorer'
import { InfoPage } from './components/InfoPages'
import { InstallCta } from './components/InstallCta'
import { MessagesExperience } from './components/MessagesExperience'
import { SharingPathDemo } from './components/SharingPathDemo'
import { ReactionCharacter, type ReactionName } from './components/ReactionCharacter'

const reactions: ReactionName[] = ['lol', 'nope', 'omg', 'brb', 'perfect']

function Arrow() { return <svg viewBox="0 0 28 20" aria-hidden="true"><path d="M1 10h23M16 2l8 8-8 8" fill="none" stroke="currentColor" strokeWidth="2.5" /></svg> }

function Header() {
  return <header className="site-header" id="top"><a className="brand" href="#top">#tiny-gifs</a><nav aria-label="Main navigation"><a href="#how-it-works">How it works</a><a href="#why-tiny">Why tiny</a></nav><InstallCta className="button button--lime button--header">Get Tiny GIFs</InstallCta></header>
}

function Hero() {
  return <section className="hero"><div className="hero__copy"><p className="eyebrow">A real iMessage app</p><h1>Find the GIF.<br />Send it<span>.</span></h1><p>Open #tiny-gifs from the Messages drawer, browse or search GIPHY, then tap once. Your compact animated reaction sends immediately.</p><div className="hero__actions"><InstallCta className="button button--lime">Get #tiny-gifs <Arrow /></InstallCta><a className="button button--outline" href="#messages-demo">Try the Messages demo <span className="play" aria-hidden="true" /></a></div><p className="hero__fine-print">The optional keyboard copies GIFs for supported chat apps. Messages is the fastest path.</p></div><MessagesExperience /></section>
}

function MessagesDemo() {
  return <section className="messages-demo section-rule" id="messages-demo" aria-labelledby="messages-demo-title"><div className="messages-demo__copy"><p className="eyebrow">How it works</p><h2 id="messages-demo-title">The real<br />Messages flow<span>.</span></h2><ol><li><b>1</b><span>Open #tiny-gifs from the Messages app drawer.</span></li><li><b>2</b><span>Browse trending GIFs or search GIPHY.</span></li><li><b>3</b><span>Tap once to send, then keep the conversation moving.</span></li></ol></div><MessagesExperience /></section>
}

function ReactionRail() {
  return <section className="reaction-rail section-rule" aria-label="Tiny reaction collection"><div className="reaction-rail__grid">{reactions.map((reaction, index) => <figure className="reaction-tile" key={reaction} style={{ '--delay': `${index * -0.35}s` } as CSSProperties}><div className="reaction-tile__frame"><ReactionCharacter kind={reaction} decorative /></div><figcaption>{reaction}</figcaption></figure>)}</div></section>
}

function Installation() {
  const steps = [['↓', 'Install', '#tiny-gifs'], ['✦', 'Open the', 'Messages drawer'], ['⌨', 'Add keyboard', '(optional)']]
  return <section className="installation section-rule" id="setup" aria-labelledby="install-title"><h2 id="install-title">Start in Messages.<br />Go further if you want<span>.</span></h2><ol className="installation__steps">{steps.map(([icon, lineOne, lineTwo], index) => <li key={lineOne}><b>{index + 1}</b><div className="step-icon" aria-hidden="true">{icon}</div><strong>{lineOne}<br />{lineTwo}</strong></li>)}</ol><p>In Messages, tap a GIF to send it immediately. The optional keyboard copies GIFs for supported apps; final display size varies by app.</p></section>
}

function ClosingBand() {
  return <section className="closing"><div className="closing__burst" aria-hidden="true"><span /><i /><b /><em /></div><div><h2>Keep the reaction<span>.</span><br />Lose the interruption<span>.</span></h2><InstallCta className="button button--lime">Get Tiny GIFs <Arrow /></InstallCta></div></section>
}

function Footer() { return <footer><a href="/privacy">Privacy</a><a href="/support">Support</a><p>Built tiny on purpose.</p></footer> }

export default function App() {
  if (window.location.pathname === '/privacy') return <InfoPage page="privacy" />
  if (window.location.pathname === '/support') return <InfoPage page="support" />
  return <><Header /><main><Hero /><MessagesDemo /><FootprintComparison /><ReactionRail /><GiphyExplorer /><SharingPathDemo /><Installation /><ClosingBand /></main><Footer /></>
}
