import test from 'node:test'
import assert from 'node:assert/strict'
import { spawnSync } from 'node:child_process'

test('production config rejects a deployment without a GIPHY key', () => {
  const result = spawnSync('node', ['scripts/check-production-config.mjs'], {
    cwd: new URL('..', import.meta.url),
    env: { ...process.env, VITE_GIPHY_API_KEY: '' },
    encoding: 'utf8',
  })
  assert.notEqual(result.status, 0)
  assert.match(result.stderr, /VITE_GIPHY_API_KEY/)
})

test('production config accepts a non-empty GIPHY key without revealing it', () => {
  const result = spawnSync('node', ['scripts/check-production-config.mjs'], {
    cwd: new URL('..', import.meta.url),
    env: { ...process.env, VITE_GIPHY_API_KEY: 'test-key' },
    encoding: 'utf8',
  })
  assert.equal(result.status, 0)
  assert.doesNotMatch(`${result.stdout}${result.stderr}`, /test-key/)
})
