import test from 'node:test'
import assert from 'node:assert/strict'
import { spawnSync } from 'node:child_process'

function validateWith(fetchBody, key = 'private-test-key') {
  return spawnSync(process.execPath, ['--input-type=module', '--eval', `
    globalThis.fetch = async () => { ${fetchBody} }
    await import('./scripts/validate-klipy-key.mjs')
  `], {
    cwd: new URL('..', import.meta.url),
    env: { ...process.env, KLIPY_API_KEY: key },
    encoding: 'utf8',
  })
}

test('release validation accepts a working key without requiring an a pricing tier', () => {
  const result = validateWith('return { ok: true, status: 200, json: async () => ({ result: true, data: { data: [{ id: "gif", slug: "gif", file: { hd: { gif: { url: "https://static.klipy.com/gif.gif" } } } }] } }) }')
  assert.equal(result.status, 0)
  assert.doesNotMatch(result.stdout + result.stderr, /private-test-key/)
})

test('release validation rejects an rate-limited key', () => {
  const result = validateWith('return { ok: false, status: 429 }')
  assert.equal(result.status, 65)
  assert.match(result.stderr, /HTTP 429/)
})

test('release validation never exposes a credential in network errors', () => {
  const result = validateWith('throw new Error("https://api.klipy.com/?api_key=private-test-key")')
  assert.equal(result.status, 65)
  assert.doesNotMatch(result.stdout + result.stderr, /private-test-key|https:/)
})

test('release validation rejects missing keys and empty results', () => {
  assert.equal(validateWith('throw new Error("must not fetch")', '').status, 65)
  assert.equal(validateWith('return { ok: true, status: 200, json: async () => ({ result: true, data: { data: [] } }) }').status, 65)
})
