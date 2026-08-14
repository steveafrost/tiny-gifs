import { useEffect, useState } from 'react'
import { toGifItems } from '../lib/giphy.js'

type GiphyItem = { id: string; title: string; previewUrl: string; gifUrl: string; sourceUrl: string }
type GiphyResponse = { data: Array<{ id: string; title: string; url?: string; images?: { fixed_width_small?: { webp?: string; url?: string }; fixed_height?: { url?: string } } }> }
type SendState = 'browsing' | 'sending' | 'sent'

const apiKey = import.meta.env.VITE_GIPHY_API_KEY?.trim()

export function MessagesExperience() {
  const [query, setQuery] = useState('')
  const [gifs, setGifs] = useState<GiphyItem[]>([])
  const [selected, setSelected] = useState<GiphyItem | null>(null)
  const [state, setState] = useState<SendState>('browsing')

  useEffect(() => {
    if (!apiKey) return
    const controller = new AbortController()
    const timeout = window.setTimeout(async () => {
      try {
        const params = new URLSearchParams({ api_key: apiKey, limit: '6', rating: 'g', bundle: 'messaging_non_clips' })
        const term = query.trim()
        if (term) params.set('q', term)
        const response = await fetch(`https://api.giphy.com/v1/gifs/${term ? 'search' : 'trending'}?${params}`, { signal: controller.signal })
        if (!response.ok) throw new Error('GIPHY request failed')
        const payload = await response.json() as GiphyResponse
        setGifs(toGifItems(payload.data) as GiphyItem[])
      } catch (error) {
        if ((error as Error).name !== 'AbortError') setGifs([])
      }
    }, query ? 280 : 0)
    return () => { controller.abort(); window.clearTimeout(timeout) }
  }, [query])

  function sendGif(gif: GiphyItem) {
    if (state !== 'browsing') return
    setSelected(gif)
    setState('sending')
    window.setTimeout(() => setState('sent'), 350)
  }

  return <section className="messages-experience" aria-label="Interactive Messages drawer walkthrough">
    <div className="messages-experience__chrome"><span>‹</span><b>Messages</b><i /></div>
    <div className="messages-experience__thread">
      <div className="incoming-bubble">Need a reaction for that.</div>
      {state === 'sent' && selected && <div className="sent-gif"><img src={selected.previewUrl} alt={selected.title} /><span>Sent</span></div>}
    </div>
    <div className="messages-experience__composer"><b>+</b><span>iMessage</span><i>↑</i></div>
    {state === 'sent' ? <div className="messages-experience__complete" aria-live="polite"><div><strong>Sent with one tap.</strong><span>The drawer closes after a successful send.</span></div><button type="button" onClick={() => { setQuery(''); setState('browsing') }}>Try another</button></div> : <div className="messages-experience__drawer">
      <div className="messages-experience__handle" />
      <div className="messages-experience__drawer-header"><strong>tiny gifs</strong><span>Powered by GIPHY</span></div>
      <label className="messages-experience__search"><span className="visually-hidden">Search GIFs in the walkthrough</span><svg viewBox="0 0 20 20" aria-hidden="true"><circle cx="8.5" cy="8.5" r="4.8" fill="none" stroke="currentColor" strokeWidth="1.6" /><path d="m12 12 4.5 4.5" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" /></svg><input value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Search GIFs" /></label>
      <p>Tap a GIF once to send it.</p>
      <div className="messages-experience__grid">
        {apiKey && gifs.map((gif) => <button key={gif.id} type="button" onClick={() => sendGif(gif)} disabled={state !== 'browsing'} aria-label={`Send ${gif.title} GIF`}><img src={gif.previewUrl} alt="" /></button>)}
        {!apiKey && <div className="messages-experience__unconfigured"><strong>Real GIPHY GIFs load here.</strong><span>Production uses the configured GIPHY key.</span></div>}
      </div>
    </div>}
    <p className="messages-experience__caption">A faithful walkthrough of the native flow — search GIPHY in the drawer, tap one GIF, then return to the conversation.</p>
  </section>
}
