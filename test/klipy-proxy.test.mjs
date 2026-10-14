import test from 'node:test'
import assert from 'node:assert/strict'
import { getKlipyResponse, serveKlipy } from '../server/klipy.js'

test('server searches KLIPY with the secret while preserving query and provider order', async () => {
  const data = { result: true, data: { data: [{ id: 2 }, { id: 1 }] } }
  const result = await getKlipyResponse('/api/gifs?q=hello%20world&limit=8', 'private-key', async (url) => {
    assert.match(url.pathname, /private-key\/gifs\/search$/)
    assert.equal(url.searchParams.get('q'), 'hello world')
    assert.equal(url.searchParams.get('content_filter'), 'high')
    return Response.json(data)
  })
  assert.equal(result.status, 200)
  assert.deepEqual(result.body, data)
})

test('provider errors and echoed credentials never reach the browser', async () => {
  const failure = await getKlipyResponse('/api/gifs', 'private-key', async () => { throw Error('https://provider/private-key') })
  assert.equal(failure.status, 502)
  assert.doesNotMatch(JSON.stringify(failure), /private-key/)
  const echoed = await getKlipyResponse('/api/gifs', 'private-key', async () => Response.json({ result: true, data: { data: [] }, debug: 'private-key' }))
  assert.doesNotMatch(JSON.stringify(echoed), /private-key/)
})

test('unconfigured and invalid requests fail before calling the provider', async () => {
  const unexpected = () => { throw Error('Unexpected provider call') }
  assert.equal((await getKlipyResponse('/api/gifs', '', unexpected)).status, 503)
  assert.equal((await getKlipyResponse('/api/gifs?limit=500', 'key', unexpected)).status, 400)
  assert.equal((await getKlipyResponse('/api/gifs?q=' + 'a'.repeat(201), 'key', unexpected)).status, 400)
  const res = { setHeader() {}, end(body) { this.body = body } }
  await serveKlipy({ method: 'POST' }, res, 'key')
  assert.equal(res.statusCode, 405)
})
