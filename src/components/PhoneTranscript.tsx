import { ReactionCharacter } from './ReactionCharacter'

export function PhoneTranscript() {
  return <div className="phone-demo" aria-label="Message transcript comparison">
    <div className="phone-demo__chrome"><span>‹</span><i /><span className="phone-demo__video">□</span></div>
    <div className="phone-demo__section phone-demo__section--big">
      <strong>Too big</strong>
      <div className="phone-demo__line"><div className="phone-demo__reaction"><ReactionCharacter decorative kind="omg" /></div><div className="bubble bubble--sent"><i /><i /><i /></div></div>
    </div>
    <div className="phone-demo__section">
      <strong>Just right</strong>
      <div className="phone-demo__line"><div className="phone-demo__reaction phone-demo__reaction--tiny"><ReactionCharacter decorative kind="omg" compact /></div><div className="bubble bubble--long bubble--sent"><i /><i /><i /></div></div>
    </div>
    <div className="phone-demo__input"><b>+</b><span /><em>◉</em><em>♙</em></div>
  </div>
}
