import test from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'

const site = readFileSync(new URL('../src/App.tsx', import.meta.url), 'utf8')
const app = readFileSync(new URL('../ios/TinyGIFsApp/TinyGIFsApp.swift', import.meta.url), 'utf8')

test('product site carries Tiny GIFs’ small-signal brand while keeping the containing app focused', () => {
  assert.match(site, /SMALL SIGNALS\. BIG TIMING\./)
  assert.match(site, /The smallest thing/)
  assert.match(site, /that says a lot\./)
  assert.match(site, /The downloaded app gives the Tiny GIFs signal its home/)
  assert.match(site, /Made for the moment between the words\./)
  assert.doesNotMatch(site, /Useful everywhere else\./)
})

test('first-launch app applies the brand while keeping Messages primary and the keyboard optional', () => {
  assert.match(app, /A little more you, right in Messages\./)
  assert.match(app, /Your three-second tour/)
  assert.match(app, /Open Messages/)
  assert.match(app, /Optional keyboard/)
  assert.match(app, /Search GIPHY in the drawer/)
  assert.match(app, /brandAccent/)
  assert.match(app, /openURL\(URL\(string: "sms:"\)!\)/)
  assert.doesNotMatch(app, /\.preferredColorScheme\(\.light\)/)
  assert.doesNotMatch(app, /GIPHY SEARCH/)
})
