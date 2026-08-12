import { useEffect, useState } from 'react'

type GiphyItem = {
  id: string
  title: string
  tinyUrl: string
  gifUrl: string
}

type GiphyResponse = {
  data: Array<{
    id: string
    title: string
    images: {
      fixed_width_small: { url: string }
      fixed_height: { url: string }
    }
  }>
}

const apiKey = import.meta.env.VITE_GIPHY_API_KEY?.trim()

export function GiphyExplorer() {
  const [query, setQuery] = useState('')
  const [gifs, setGifs] = useState<GiphyItem[]>([])
  const [selected, setSelected] = useState<string | null>(null)
  const [status, setStatus] = useState<'idle' | 'loading' | 'error'>('idle')

  useEffect(() => {
    if (!apiKey) return
    const controller = new AbortController()
    const timer = window.setTimeout(async () => {
      setStatus('loading')
      try {
        const params = new URLSearchParams({ api_key: apiKey, limit: '16', rating: 'g', bundle: 'messaging_non_clips' })
        const trimmed = query.trim()
        const endpoint = trimmed ? 'search' : 'trending'
        if (trimmed) params.set('q', trimmed)
        const response = await fetch(`https://api.giphy.com/v1/gifs/${endpoint}?${params}`, { signal: controller.signal })
        if (!response.ok) throw new Error('GIPHY request failed')
        const payload = await response.json() as GiphyResponse
        setGifs(payload.data.map((gif) => ({ id: gif.id, title: gif.title || 'Tiny GIF', tinyUrl: gif.images.fixed_width_small.url, gifUrl: gif.images.fixed_height.url })))
        setStatus('idle')
      } catch (error) {
        if ((error as Error).name !== 'AbortError') setStatus('error')
      }
    }, query ? 350 : 0)
    return () => { controller.abort(); window.clearTimeout(timer) }
  }, [query])

  return <section className="giphy-explorer section-rule" id="library" aria-labelledby="library-title">
    <div className="giphy-explorer__intro">
      <h2 id="library-title">The GIF library.<br />Right in Messages<span>.</span></h2>
      <p>Search GIPHY from the app drawer, pick the feeling, then tap once to send a compact animated reaction.</p>
      <label className="giphy-search"><span className="visually-hidden">Search GIPHY</span><input value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Search GIPHY" /><b>⌕</b></label>
      <small>Powered By GIPHY</small>
    </div>
    <div className="giphy-explorer__results" aria-live="polite">
      {!apiKey && <div className="giphy-explorer__empty"><strong>GIPHY search belongs in the app.</strong><p>This site’s live explorer appears when its GIPHY key is configured. In Tiny GIFs, search is available from the Messages drawer.</p></div>}
      {apiKey && status === 'loading' && <div className="giphy-explorer__empty">Finding tiny loops…</div>}
      {apiKey && status === 'error' && <div className="giphy-explorer__empty">GIPHY is taking a beat. Try again.</div>}
      {apiKey && status !== 'loading' && status !== 'error' && gifs.map((gif) => <button className={`giphy-gif ${selected === gif.id ? 'is-selected' : ''}`} key={gif.id} onClick={() => setSelected(gif.id)} aria-pressed={selected === gif.id} title={gif.title}><img src={gif.tinyUrl} alt={gif.title} /><span>{selected === gif.id ? 'Picked' : 'Pick'}</span></button>)}
    </div>
  </section>
}
