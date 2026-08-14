import test from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'

const source = readFileSync(new URL('../src/components/InfoPages.tsx', import.meta.url), 'utf8')

test('information pages link to live homepage sections only', () => {
  assert.match(source, /href="\/#library"/)
  assert.doesNotMatch(source, /#why-tiny/)
})
