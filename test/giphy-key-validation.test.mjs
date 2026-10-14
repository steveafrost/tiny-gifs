import test from 'node:test'
import assert from 'node:assert/strict'
import { spawnSync } from 'node:child_process'

function validateWith(fetchBody, key = 'private-test-key') {
  return spawnSync(process.execPath, ['--input-type=module', '--eval', `
    globalThis.fetch = async () => { ${fetchBody} }
    await import('./scripts/validate-giphy-key.mjs')
  `], {
    cwd: new URL('..', import.meta.url),
    env: { ...process.env, GIPHY_API_KEY: key },
    encoding: 'utf8',
  })
}

test('release validation accepts a working key without requiring an enterprise tier', () => {
  const result = validateWith('return { ok: true, status: 200, json: async () => ({ data: [{ id: "gif" }] }) }')
  assert.equal(result.status, 0)
  assert.doesNotMatch(result.stdout + result.stderr, /private-test-key/)
})

test('release validation rejects an exhausted beta key', () => {
  const result = validateWith('return { ok: false, status: 429 }')
  assert.equal(result.status, 65)
  assert.match(result.stderr, /HTTP 429/)
})

test('release validation never exposes a credential in network errors', () => {
  const result = validateWith('throw new Error("https://api.giphy.com/?api_key=private-test-key")')
  assert.equal(result.status, 65)
  assert.doesNotMatch(result.stdout + result.stderr, /private-test-key|https:/)
})

test('release validation rejects missing keys and empty results', () => {
  assert.equal(validateWith('throw new Error("must not fetch")', '').status, 65)
  assert.equal(validateWith('return { ok: true, status: 200, json: async () => ({ data: [] }) }').status, 65)
})
