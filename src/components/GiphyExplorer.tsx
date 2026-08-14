import { useEffect, useState } from 'react'
import { toGifItems } from '../lib/giphy.js'

type GiphyItem = { id: string; title: string; previewUrl: string; gifUrl: string; sourceUrl: string }
type GiphyResponse = { data: Array<{ id: string; title: string; url?: string; images?: { fixed_width_small?: { webp?: string; url?: string }; fixed_height?: { url?: string } } }> }

const apiKey = import.meta.env.VITE_GIPHY_API_KEY?.trim()

export function GiphyExplorer() {
  const [query, setQuery] = useState('')
  const [gifs, setGifs] = useState<GiphyItem[]>([])
  const [status, setStatus] = useState<'idle' | 'loading' | 'error'>('idle')
  const [selected, setSelected] = useState<string | null>(null)

  useEffect(() => {
    if (!apiKey) return
    const controller = new AbortController()
    const timeout = window.setTimeout(async () => {
      setStatus('loading')
      try {
        const params = new URLSearchParams({ api_key: apiKey, limit: '12', rating: 'g', bundle: 'messaging_non_clips' })
        const term = query.trim()
        if (term) params.set('q', term)
        const endpoint = term ? 'search' : 'trending'
        const response = await fetch(`https://api.giphy.com/v1/gifs/${endpoint}?${params}`, { signal: controller.signal })
        if (!response.ok) throw new Error('GIPHY request failed')
        const payload = await response.json() as GiphyResponse
        setGifs(toGifItems(payload.data) as GiphyItem[])
        setStatus('idle')
      } catch (error) {
        if ((error as Error).name !== 'AbortError') setStatus('error')
      }
    }, query ? 280 : 0)
    return () => { controller.abort(); window.clearTimeout(timeout) }
  }, [query])

  return <section className="giphy-explorer" id="library" aria-labelledby="library-title">
    <div className="giphy-explorer__heading"><p className="eyebrow">The actual catalog</p><h2 id="library-title">Search real GIFs.<br />Not a reaction pack.</h2><p>What you see here is the same GIPHY library Tiny GIFs makes available from the Messages drawer.</p></div>
    <div className="giphy-explorer__browser">
      <label className="giphy-search"><span className="visually-hidden">Search GIPHY</span><svg viewBox="0 0 20 20" aria-hidden="true"><circle cx="8.5" cy="8.5" r="4.8" fill="none" stroke="currentColor" strokeWidth="1.6" /><path d="m12 12 4.5 4.5" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" /></svg><input value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Search GIPHY" /></label>
      <div className="giphy-explorer__meta"><span>{query.trim() ? `Results for “${query.trim()}”` : 'Trending now'}</span><span>Powered by GIPHY</span></div>
      <div className="giphy-explorer__results" aria-live="polite">
        {!apiKey && <div className="giphy-explorer__empty"><strong>Live GIPHY results appear here in production.</strong><p>This local preview does not include the production API key.</p></div>}
        {apiKey && status === 'loading' && <div className="giphy-explorer__empty">Loading GIPHY results…</div>}
        {apiKey && status === 'error' && <div className="giphy-explorer__empty"><strong>GIPHY could not load right now.</strong><p>Try a different search.</p></div>}
        {apiKey && status === 'idle' && gifs.map((gif) => <button className={`giphy-gif ${selected === gif.id ? 'is-selected' : ''}`} key={gif.id} type="button" onClick={() => setSelected(gif.id)} aria-label={`Select ${gif.title}`} aria-pressed={selected === gif.id}><img src={gif.previewUrl} alt={gif.title} /><span>{selected === gif.id ? 'Selected' : 'Preview'}</span></button>)}
      </div>
    </div>
  </section>
}
