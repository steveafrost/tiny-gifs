import test from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'

const site = readFileSync(new URL('../src/App.tsx', import.meta.url), 'utf8')
const app = readFileSync(new URL('../ios/TinyGIFsApp/TinyGIFsApp.swift', import.meta.url), 'utf8')

test('product site presents the containing app as a focused setup path, not another reaction pack', () => {
  assert.match(site, /The app sets up Tiny GIFs\. Messages does the sending\./)
  assert.match(site, /What opens first/)
  assert.doesNotMatch(site, /Useful everywhere else\./)
})

test('first-launch app leads with Messages and describes the optional keyboard as a secondary path', () => {
  assert.match(app, /Messages first\./)
  assert.match(app, /Optional: add the keyboard later/)
  assert.doesNotMatch(app, /Big feeling\.\\nTiny footprint\./)
  assert.doesNotMatch(app, /GIPHY SEARCH/)
})
