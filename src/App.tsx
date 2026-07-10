import type { CSSProperties } from 'react'
import { FootprintComparison } from './components/FootprintComparison'
import { GiphyExplorer } from './components/GiphyExplorer'
import { InfoPage } from './components/InfoPages'
import { InstallCta } from './components/InstallCta'
import { PhoneTranscript } from './components/PhoneTranscript'
import { SharingPathDemo } from './components/SharingPathDemo'
import { ReactionCharacter, type ReactionName } from './components/ReactionCharacter'

const reactions: ReactionName[] = ['lol', 'nope', 'omg', 'brb', 'perfect']

function Arrow() { return <svg viewBox="0 0 28 20" aria-hidden="true"><path d="M1 10h23M16 2l8 8-8 8" fill="none" stroke="currentColor" strokeWidth="2.5" /></svg> }

function Header() {
  return <header className="site-header" id="top"><a className="brand" href="#top">#tiny-gifs</a><nav aria-label="Main navigation"><a href="#how-it-works">How it works</a><a href="#why-tiny">Why tiny</a></nav><InstallCta className="button button--lime button--header">Get the keyboard</InstallCta></header>
}

function Hero() {
  return <section className="hero"><div className="hero__copy"><h1>Big reaction<span>.</span><br />Tiny footprint<span>.</span></h1><p>A whole GIF keyboard built for the size of a large emoji. All the motion, none of the wall-of-GIF.</p><div className="hero__actions"><InstallCta className="button button--lime">Get #tiny-gifs <Arrow /></InstallCta><a className="button button--outline" href="#why-tiny">See it in action <span className="play" aria-hidden="true" /></a></div></div><PhoneTranscript /></section>
}

function ReactionRail() {
  return <section className="reaction-rail section-rule" aria-label="Tiny reaction collection"><div className="reaction-rail__grid">{reactions.map((reaction, index) => <figure className="reaction-tile" key={reaction} style={{ '--delay': `${index * -0.35}s` } as CSSProperties}><div className="reaction-tile__frame"><ReactionCharacter kind={reaction} decorative /></div><figcaption>{reaction}</figcaption></figure>)}</div></section>
}

function Installation() {
  const steps = [['↓', 'Download', 'the app'], ['✦', 'Send in', 'Messages'], ['⌨', 'Add keyboard', '(optional)']]
  return <section className="installation section-rule" id="setup" aria-labelledby="install-title"><h2 id="install-title">Start in Messages.<br />Go everywhere else<span>.</span></h2><ol className="installation__steps">{steps.map(([icon, lineOne, lineTwo], index) => <li key={lineOne}><b>{index + 1}</b><div className="step-icon" aria-hidden="true">{icon}</div><strong>{lineOne}<br />{lineTwo}</strong></li>)}</ol><p>Keyboard typing works without Full Access. Display size can vary by messaging app.</p></section>
}

function ClosingBand() {
  return <section className="closing"><div className="closing__burst" aria-hidden="true"><span /><i /><b /><em /></div><div><h2>Keep the reaction<span>.</span><br />Lose the interruption<span>.</span></h2><InstallCta className="button button--lime">Get the keyboard <Arrow /></InstallCta></div></section>
}

function Footer() { return <footer><a href="/privacy">Privacy</a><a href="/support">Support</a><p>Built tiny on purpose.</p></footer> }

export default function App() {
  if (window.location.pathname === '/privacy') return <InfoPage page="privacy" />
  if (window.location.pathname === '/support') return <InfoPage page="support" />
  return <><Header /><main><Hero /><FootprintComparison /><ReactionRail /><GiphyExplorer /><SharingPathDemo /><Installation /><ClosingBand /></main><Footer /></>
}
