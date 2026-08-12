import { useMemo, useState } from 'react'
import { reactions, type ReactionName } from '../data/reactions'
import { ReactionCharacter } from './ReactionCharacter'

type SendState = 'browsing' | 'sending' | 'sent'

const drawerReactions: ReactionName[] = ['lol', 'nope', 'omg', 'brb', 'perfect', 'yes']

export function MessagesExperience() {
  const [query, setQuery] = useState('')
  const [selected, setSelected] = useState<ReactionName>('omg')
  const [sendState, setSendState] = useState<SendState>('browsing')

  const visibleReactions = useMemo(() => {
    const normalizedQuery = query.trim().toLowerCase()
    if (!normalizedQuery) return drawerReactions
    const matches = reactions
      .filter((reaction) => reaction.label.includes(normalizedQuery))
      .map((reaction) => reaction.id)
    return matches.length > 0 ? matches : drawerReactions
  }, [query])

  function sendReaction(reaction: ReactionName) {
    if (sendState !== 'browsing') return
    setSelected(reaction)
    setSendState('sending')
    window.setTimeout(() => setSendState('sent'), 380)
  }

  function tryAnother() {
    setQuery('')
    setSendState('browsing')
  }

  return <section className="messages-experience" aria-label="Interactive Messages drawer walkthrough">
    <div className="messages-experience__chrome"><span>‹</span><b>Messages</b><i /></div>
    <div className="messages-experience__thread">
      <div className="messages-experience__incoming">On my way!</div>
      {sendState === 'sent' && <div className="messages-experience__sent"><ReactionCharacter kind={selected} decorative compact /><span>Sent</span></div>}
    </div>
    <div className="messages-experience__composer"><b>+</b><span>iMessage</span><i>↑</i></div>
    {sendState === 'sent' ? <div className="messages-experience__complete" aria-live="polite">
      <div><strong>Sent with one tap.</strong><span>The drawer closes after a successful send.</span></div>
      <button type="button" onClick={tryAnother}>Try another GIF</button>
    </div> : <div className="messages-experience__drawer" aria-live="polite">
      <div className="messages-experience__handle" />
      <div className="messages-experience__drawer-heading"><strong>#tiny-gifs</strong><span>Powered by GIPHY</span></div>
      <label className="messages-experience__search">
        <span className="visually-hidden">Filter the Messages GIF walkthrough</span>
        <b>⌕</b>
        <input value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Search GIFs" />
      </label>
      <p>{sendState === 'sending' ? 'Sending your tiny GIF…' : 'Tap a GIF once to send it.'}</p>
      <div className="messages-experience__grid">
        {visibleReactions.map((reaction) => <button key={reaction} type="button" onClick={() => sendReaction(reaction)} disabled={sendState !== 'browsing'} aria-label={`Send ${reaction} GIF`}>
          <ReactionCharacter kind={reaction} decorative />
          <span>{reaction === 'tiny-clap' ? 'clap' : reaction}</span>
        </button>)}
      </div>
    </div>}
    <p className="messages-experience__caption">Interactive walkthrough of the real flow: browse or search in the Messages drawer, tap once, then get back to the thread.</p>
  </section>
}
