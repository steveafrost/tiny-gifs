import test from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'

const source = readFileSync(new URL('../src/components/GiphyExplorer.tsx', import.meta.url), 'utf8')

test('GIPHY results are selectable buttons with real preview media', () => {
  assert.match(source, /<button className=\{`giphy-gif/)
  assert.match(source, /<img src=\{gif\.previewUrl\}/)
  assert.doesNotMatch(source, /<a className=\{`giphy-gif/)
})
