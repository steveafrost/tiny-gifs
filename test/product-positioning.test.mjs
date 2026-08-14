import test from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'

const site = readFileSync(new URL('../src/App.tsx', import.meta.url), 'utf8')
const app = readFileSync(new URL('../ios/TinyGIFsApp/TinyGIFsApp.swift', import.meta.url), 'utf8')

test('product site presents the containing app as a focused first-launch path, not another GIF feed', () => {
  assert.match(site, /Open once\./)
  assert.match(site, /Then send from Messages\./)
  assert.match(site, /The downloaded app/)
  assert.match(site, /The downloaded app is a focused first-launch guide—not another GIF feed\./)
  assert.doesNotMatch(site, /Useful everywhere else\./)
})

test('first-launch app gives Messages a clear primary action, respects appearance, and keeps the keyboard optional', () => {
  assert.match(app, /Use Tiny GIFs in Messages\./)
  assert.match(app, /No setup is required for the one-tap Messages path\./)
  assert.match(app, /Open Messages/)
  assert.match(app, /Optional keyboard/)
  assert.match(app, /Search GIPHY in the drawer/)
  assert.match(app, /openURL\(URL\(string: "sms:"\)!\)/)
  assert.doesNotMatch(app, /\.preferredColorScheme\(\.light\)/)
  assert.doesNotMatch(app, /Big feeling\.\\nTiny footprint\./)
  assert.doesNotMatch(app, /GIPHY SEARCH/)
})
