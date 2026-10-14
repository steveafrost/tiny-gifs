import { useEffect, useState } from 'react'
import { klipyRequestURL, toGifItems } from '../lib/klipy.js'

type KlipyItem = { id: string; title: string; previewUrl: string; gifUrl: string; slug: string }


const apiKey = import.meta.env.VITE_KLIPY_API_KEY?.trim()

export function KlipyExplorer() {
  const [query, setQuery] = useState('')
  const [gifs, setGifs] = useState<KlipyItem[]>([])
  const [status, setStatus] = useState<'idle' | 'loading' | 'error'>('idle')
  const [selected, setSelected] = useState<string | null>(null)

  useEffect(() => {
    if (!apiKey) return
    const controller = new AbortController()
    const timeout = window.setTimeout(async () => {
      setStatus('loading')
      try {
        const response = await fetch(klipyRequestURL(apiKey, { query, limit: 12 }), { signal: controller.signal })
        if (!response.ok) throw new Error('KLIPY request failed')
        const payload = await response.json()
        const items = toGifItems(payload) as KlipyItem[]
        if (controller.signal.aborted) return
        setGifs(items)
        setSelected(null)
        setStatus('idle')
      } catch (error) {
        if (!controller.signal.aborted && (error as Error).name !== 'AbortError') setStatus('error')
      }
    }, query ? 280 : 0)
    return () => { controller.abort(); window.clearTimeout(timeout) }
  }, [query])

  return <section className="klipy-explorer" id="library" aria-labelledby="library-title">
    <div className="klipy-explorer__heading"><p className="eyebrow">The actual catalog</p><h2 id="library-title">Search real GIFs.<br />Not a reaction pack.</h2><p>What you see here is the same KLIPY library Tiny GIFs makes available from the Messages drawer.</p></div>
    <div className="klipy-explorer__browser">
      <label className="klipy-search"><span className="visually-hidden">Search KLIPY</span><svg viewBox="0 0 20 20" aria-hidden="true"><circle cx="8.5" cy="8.5" r="4.8" fill="none" stroke="currentColor" strokeWidth="1.6" /><path d="m12 12 4.5 4.5" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" /></svg><input value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Search KLIPY" /></label>
      <div className="klipy-explorer__meta"><span>{query.trim() ? `Results for “${query.trim()}”` : 'Trending now'}</span><span>Powered by KLIPY</span></div>
      <div className="klipy-explorer__results" aria-live="polite">
        {!apiKey && <div className="klipy-explorer__empty"><strong>Live KLIPY results appear here in production.</strong><p>This local preview does not include the production API key.</p></div>}
        {apiKey && status === 'loading' && <div className="klipy-explorer__empty">Loading KLIPY results…</div>}
        {apiKey && status === 'error' && <div className="klipy-explorer__empty"><strong>KLIPY could not load right now.</strong><p>Try a different search.</p></div>}
        {apiKey && status === 'idle' && gifs.map((gif) => <button className={`klipy-gif ${selected === gif.id ? 'is-selected' : ''}`} key={gif.id} type="button" onClick={() => setSelected(gif.id)} aria-label={`Select ${gif.title}`} aria-pressed={selected === gif.id}><img src={gif.previewUrl} alt={gif.title} /><span>{selected === gif.id ? 'Selected' : 'Preview'}</span></button>)}
      </div>
    </div>
  </section>
}
