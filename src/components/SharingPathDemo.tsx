import { useState } from 'react'
import { reactions } from '../data/reactions'
import { ReactionCharacter } from './ReactionCharacter'

type Path = 'messages' | 'keyboard'

const pathCopy: Record<Path, { title: string; description: string }> = {
  messages: {
    title: 'Fastest in Messages.',
    description: 'Tap a tiny sticker to drop it straight into the conversation. That is the seamless path.',
  },
  keyboard: {
    title: 'Keyboard everywhere else.',
    description: 'Type normally offline. With optional Full Access, search GIPHY, tap a tiny GIF to copy it, then paste.',
  },
}

export function SharingPathDemo() {
  const [path, setPath] = useState<Path>('messages')
  const [selected, setSelected] = useState('lol')
  const copy = pathCopy[path]

  return <section className="sharing-path section-rule" id="how-it-works" aria-labelledby="sharing-path-title">
    <div className="sharing-path__copy">
      <h2 id="sharing-path-title">{copy.title}</h2>
      <p>{copy.description}</p>
      <div className="path-tabs" role="tablist" aria-label="Sharing paths">
        <button className={path === 'messages' ? 'is-selected' : ''} role="tab" aria-selected={path === 'messages'} onClick={() => setPath('messages')}>Messages stickers</button>
        <button className={path === 'keyboard' ? 'is-selected' : ''} role="tab" aria-selected={path === 'keyboard'} onClick={() => setPath('keyboard')}>Keyboard</button>
      </div>
      <p className="sharing-path__privacy">No account. No tracking. Your typing stays on your iPhone.</p>
    </div>
    <div className={`path-demo path-demo--${path}`} aria-live="polite">
      <div className="path-demo__bar"><span>‹</span><b>{path === 'messages' ? 'Messages' : '#tiny-gifs keyboard'}</b><i /></div>
      {path === 'messages' ? <MessagesPanel selected={selected} /> : <KeyboardPanel selected={selected} />}
      <ReactionPicker selected={selected} onSelect={setSelected} />
    </div>
  </section>
}

function ReactionPicker({ selected, onSelect }: { selected: string; onSelect: (id: string) => void }) {
  return <div className="path-picker" aria-label="Choose a reaction">
    {reactions.map((reaction) => <button key={reaction.id} className={selected === reaction.id ? 'is-selected' : ''} onClick={() => onSelect(reaction.id)} aria-label={`Choose ${reaction.label}`}>
      <ReactionCharacter kind={reaction.id} decorative />
      <span>{reaction.label}</span>
    </button>)}
  </div>
}

function MessagesPanel({ selected }: { selected: string }) {
  return <div className="message-path">
    <div className="message-path__line"><span>Heading to lunch!</span></div>
    <div className="message-path__sent"><ReactionCharacter kind={selected as typeof reactions[number]['id']} decorative compact /><span>Ready to tap Send</span></div>
    <div className="message-path__input"><b>+</b><span>iMessage</span><i>↑</i></div>
  </div>
}

function KeyboardPanel({ selected }: { selected: string }) {
  return <div className="keyboard-path">
    <div className="keyboard-path__text">Heading to lunch! <ReactionCharacter kind={selected as typeof reactions[number]['id']} decorative compact /></div>
    <div className="keyboard-path__notice">Copied — paste in the conversation <b>✓</b></div>
    <div className="keyboard-path__keys"><span>Q</span><span>W</span><span>E</span><span>R</span><span>T</span><span>Y</span><span>⌫</span><span>🌐</span><span className="wide">space</span><span>return</span></div>
  </div>
}
