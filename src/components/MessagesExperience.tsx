import { useEffect, useState, type ReactNode } from 'react'
import { websiteKlipyURL, toGifItems } from '../lib/klipy.js'

type KlipyItem = { id: string; title: string; previewUrl: string; gifUrl: string; slug: string }

type SendState = 'browsing' | 'selected' | 'sent'
type GifStatus = 'loading' | 'ready' | 'empty' | 'error'


export function MessagesExperience() {
  const [query, setQuery] = useState('')
  const [gifs, setGifs] = useState<KlipyItem[]>([])
  const [status, setStatus] = useState<GifStatus>('loading')
  const [requestVersion, setRequestVersion] = useState(0)
  const [selected, setSelected] = useState<KlipyItem | null>(null)
  const [state, setState] = useState<SendState>('browsing')

  useEffect(() => {
    const controller = new AbortController()
    const timeout = window.setTimeout(async () => {
      setStatus('loading')
      try {
        const response = await fetch(websiteKlipyURL({ query, limit: 8 }), { signal: controller.signal })
        if (!response.ok) throw new Error('KLIPY request failed')
        const payload = await response.json()
        const nextGifs = toGifItems(payload) as KlipyItem[]
        if (controller.signal.aborted) return
        setGifs(nextGifs)
        setStatus(nextGifs.length ? 'ready' : 'empty')
      } catch (error) {
        if (!controller.signal.aborted && (error as Error).name !== 'AbortError') {
          setGifs([])
          setStatus('error')
        }
      }
    }, query ? 280 : 0)
    return () => { controller.abort(); window.clearTimeout(timeout) }
  }, [query, requestVersion])

  function selectGif(gif: KlipyItem) {
    if (state !== 'browsing') return
    setSelected(gif)
    setState('selected')
  }

  const drawerHint = status === 'ready' ? 'Choose a GIF, then tap Send.' : status === 'loading' ? 'Loading GIFs…' : 'Search KLIPY for a reaction.'

  return <section className="messages-experience" aria-label="Interactive Messages drawer walkthrough">
    <div className="messages-experience__chrome"><span>‹</span><b>Messages</b><i /></div>
    <div className="messages-experience__thread">
      <div className="incoming-bubble">Need a reaction for that.</div>
      {state === 'sent' && selected && <div className="sent-gif"><img src={selected.previewUrl} alt={selected.title} /><span>Sent</span></div>}
    </div>
    <div className="messages-experience__composer"><b aria-hidden="true">+</b><span aria-live="polite">{state === 'selected' && selected ? <img className="messages-experience__attachment" src={selected.previewUrl} alt={`Selected: ${selected.title}`} /> : 'iMessage'}</span><button type="button" aria-label="Send selected GIF" disabled={state !== 'selected'} onClick={() => setState('sent')}>↑</button></div>
    {state !== 'browsing' ? <div className="messages-experience__complete" aria-live="polite"><div><strong>{state === 'sent' ? 'Reaction sent.' : 'Ready for your reply.'}</strong><span>{state === 'sent' ? 'A little GIF. A lot said.' : 'Tap the blue Send arrow above to share it.'}</span></div><button type="button" onClick={() => { setQuery(''); setState('browsing') }}>{state === 'sent' ? 'Try another' : 'Choose another'}</button></div> : <div className="messages-experience__drawer">
      <div className="messages-experience__handle" />
      <div className="messages-experience__drawer-header"><strong>tiny gifs</strong><span>Powered by KLIPY</span></div>
      <label className="messages-experience__search"><span className="visually-hidden">Search GIFs in the walkthrough</span><svg viewBox="0 0 20 20" aria-hidden="true"><circle cx="8.5" cy="8.5" r="4.8" fill="none" stroke="currentColor" strokeWidth="1.6" /><path d="m12 12 4.5 4.5" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" /></svg><input value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Search KLIPY" /></label>
      <p>{drawerHint}</p>
      <div className="messages-experience__grid" aria-live="polite">
        {status === 'loading' && <DrawerState>Loading GIFs…</DrawerState>}
        {status === 'ready' && gifs.map((gif) => <button key={gif.id} type="button" onClick={() => selectGif(gif)} disabled={state !== 'browsing'} aria-label={`Choose ${gif.title} GIF`}><img src={gif.previewUrl} alt="" /></button>)}
        {status === 'empty' && <DrawerState><strong>No GIFs found.</strong><span>Try another search.</span></DrawerState>}
        {status === 'error' && <DrawerState><strong>We couldn't load GIFs.</strong><button className="messages-experience__retry" type="button" onClick={() => setRequestVersion((value) => value + 1)}>Try again</button></DrawerState>}
      </div>
    </div>}
    <p className="messages-experience__caption">Try the Messages flow: search KLIPY, choose a GIF, then tap Send.</p>
  </section>
}

function DrawerState({ children }: { children: ReactNode }) {
  return <div className="messages-experience__unconfigured">{children}</div>
}
