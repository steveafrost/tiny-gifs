import test from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'

const source = readFileSync(new URL('../src/components/MessagesExperience.tsx', import.meta.url), 'utf8')

test('Messages walkthrough exposes loading, empty, and failed GIPHY states', () => {
  assert.match(source, /'loading' \| 'ready' \| 'empty' \| 'error'/)
  assert.match(source, /Loading GIFs/)
  assert.match(source, /No GIFs found/)
  assert.match(source, /couldn't load GIFs/)
  assert.match(source, /Try again/)
})
