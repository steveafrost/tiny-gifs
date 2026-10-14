import test from 'node:test'
import assert from 'node:assert/strict'
import { klipyRequestURL, toGifItems } from '../src/lib/klipy.js'
const item = { id: 6914457558367152, slug: 'hello', title: 'Hello', type: 'gif', file: { sm: { gif: { url: 'https://static.klipy.com/small.gif?delivery=keep' } }, hd: { gif: { url: 'https://static.klipy.com/full.gif?delivery=keep' } } } }
test('KLIPY maps previews and full GIFs without changing delivery URLs or ordering', () => {
  const items = toGifItems({ result: true, data: { data: [item, { ...item, id: 'second' }] } })
  assert.deepEqual(items.map(x => x.id), ['6914457558367152', 'second'])
  assert.equal(items[0].previewUrl, item.file.sm.gif.url)
  assert.equal(items[0].gifUrl, item.file.hd.gif.url)
})
test('KLIPY preserves incomplete and ad composition by rejecting unsupported responses', () => {
  for (const record of [{ ...item, file: {} }, { ...item, type: 'ad' }]) assert.throws(() => toGifItems({ result: true, data: { data: [record] } }))
  assert.throws(() => toGifItems({ result: false, data: { data: [] } }))
})
test('KLIPY uses provider paging and high content safety and preserves the exact search', () => {
  const url = klipyRequestURL('test-key', { query: ' hello & bye! ', page: 2, limit: 24 })
  assert.equal(url.pathname, '/api/v1/test-key/gifs/search')
  assert.equal(url.searchParams.get('q'), ' hello & bye! ')
  assert.equal(url.searchParams.get('page'), '2')
  assert.equal(url.searchParams.get('content_filter'), 'high')
  assert.equal(klipyRequestURL('test-key').pathname, '/api/v1/test-key/gifs/trending')
})
