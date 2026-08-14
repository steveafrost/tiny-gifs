export function toGifItems(records) {
  return records.flatMap((record) => {
    const previewUrl = record.images?.fixed_width_small?.webp || record.images?.fixed_width_small?.url
    const gifUrl = record.images?.fixed_height?.url

    if (!record.id || !previewUrl || !gifUrl) return []

    return [{
      id: record.id,
      title: record.title || 'GIPHY GIF',
      previewUrl,
      gifUrl,
      sourceUrl: record.url || `https://giphy.com/gifs/${record.id}`,
    }]
  })
}
