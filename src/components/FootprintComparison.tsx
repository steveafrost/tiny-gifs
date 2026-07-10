import { useState, type CSSProperties } from 'react'
import { ReactionCharacter } from './ReactionCharacter'

function ChatLines({ count = 2 }: { count?: number }) {
  return <span className="chat-lines">{Array.from({ length: count }, (_, index) => <i key={index} />)}</span>
}

export function FootprintComparison() {
  const [comparison, setComparison] = useState(50)
  return <section className="comparison section-rule" id="why-tiny" aria-labelledby="comparison-title">
    <div className="comparison__title"><h2 id="comparison-title">Same energy.<br />84% less chat<span>.</span></h2></div>
    <div className="comparison__demo">
      <div className="comparison__labels"><span>Before (big GIF)</span><span>After (#tiny-gifs)</span></div>
      <div className="comparison__panes">
        <article className="chat-card chat-card--before" style={{ opacity: 0.62 + ((100 - comparison) / 100) * 0.38, transform: `scale(${0.97 + ((100 - comparison) / 100) * 0.03})` }} aria-label="Before: a conventional large reaction fills the message">
          <div className="chat-card__message chat-card__message--incoming"><ChatLines /></div>
          <ReactionCharacter kind="omg" decorative className="chat-card__large-reaction" />
          <div className="chat-card__message chat-card__message--incoming chat-card__message--lower"><ChatLines /></div>
          <div className="chat-card__message chat-card__message--outgoing"><ChatLines /></div>
        </article>
        <div className="comparison__divider" aria-hidden="true"><i /></div>
        <article className="chat-card chat-card--after" style={{ opacity: 0.62 + (comparison / 100) * 0.38, transform: `scale(${0.97 + (comparison / 100) * 0.03})` }} aria-label="After: a tiny reaction leaves the message clear">
          <div className="chat-card__message chat-card__message--incoming"><ChatLines /></div>
          <div className="chat-card__tiny-reaction"><ReactionCharacter kind="omg" decorative compact /></div>
          <div className="chat-card__message chat-card__message--incoming chat-card__message--lower"><ChatLines /></div>
          <div className="chat-card__message chat-card__message--outgoing"><ChatLines /></div>
        </article>
        <label className="comparison__control" aria-label="Show more of the compact reaction comparison">
          <span className="visually-hidden">Compact reaction emphasis: {comparison}%</span>
          <input type="range" min="0" max="100" value={comparison} onChange={(event) => setComparison(Number(event.target.value))} style={{ '--progress': `${comparison}%` } as CSSProperties} />
          <b aria-hidden="true">‹›</b>
        </label>
      </div>
    </div>
  </section>
}
