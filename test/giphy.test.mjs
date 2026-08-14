import test from 'node:test'
import assert from 'node:assert/strict'
import { toGifItems } from '../src/lib/giphy.js'

test('toGifItems uses GIPHY media previews and preserves source attribution metadata', () => {
  const items = toGifItems([
    {
      id: 'movie-night',
      title: 'Movie night reaction',
      url: 'https://giphy.com/gifs/movie-night',
      images: {
        fixed_width_small: { webp: 'https://media.giphy.com/preview.webp', url: 'https://media.giphy.com/preview.gif' },
        fixed_height: { url: 'https://media.giphy.com/full.gif' },
      },
    },
  ])

  assert.deepEqual(items, [{
    id: 'movie-night',
    title: 'Movie night reaction',
    previewUrl: 'https://media.giphy.com/preview.webp',
    gifUrl: 'https://media.giphy.com/full.gif',
    sourceUrl: 'https://giphy.com/gifs/movie-night',
  }])
})

test('toGifItems rejects incomplete GIPHY responses instead of rendering broken media tiles', () => {
  const items = toGifItems([
    { id: 'missing-preview', title: 'Broken', images: { fixed_width_small: {}, fixed_height: { url: 'https://media.giphy.com/full.gif' } } },
    { id: 'missing-full', title: 'Broken', images: { fixed_width_small: { webp: 'https://media.giphy.com/preview.webp' }, fixed_height: {} } },
  ])

  assert.deepEqual(items, [])
})
