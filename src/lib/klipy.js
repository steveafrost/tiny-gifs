export function klipyRequestURL(apiKey, { query = '', page = 1, limit = 12 } = {}) {
  const term = query.trim()
  const url = new URL('https://api.klipy.com/api/v1/' + encodeURIComponent(apiKey) + '/gifs/' + (term ? 'search' : 'trending'))
  url.search = new URLSearchParams({ page: String(page), per_page: String(Math.min(50, Math.max(8, limit))), locale: 'us', content_filter: 'high', format_filter: 'gif' }).toString()
  if (term) url.searchParams.set('q', query)
  return url
}

export function toGifItems(payload) {
  if (payload?.result !== true || !Array.isArray(payload.data?.data)) throw new Error('KLIPY returned an unreadable result')
  // Preserve every result and its position; never silently strip ads or broken records.
  return payload.data.data.map((record) => {
    if (record.type && record.type !== 'gif') throw new Error('This KLIPY integration requires a GIF-only API configuration')
    const previewUrl = record.file?.sm?.gif?.url || record.file?.xs?.gif?.url || record.file?.md?.gif?.url || record.file?.hd?.gif?.url
    const gifUrl = record.file?.hd?.gif?.url || record.file?.md?.gif?.url || previewUrl
    if (record.id == null || !record.slug || !previewUrl || !gifUrl) throw new Error('KLIPY returned incomplete media')
    return { id: String(record.id), slug: record.slug, title: record.title || 'KLIPY GIF', previewUrl, gifUrl }
  })
}
