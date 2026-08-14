import test from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'

const site = readFileSync(new URL('../src/App.tsx', import.meta.url), 'utf8')
const app = readFileSync(new URL('../ios/TinyGIFsApp/TinyGIFsApp.swift', import.meta.url), 'utf8')
const styles = readFileSync(new URL('../src/styles.css', import.meta.url), 'utf8')

test('product site carries Tiny GIFs’ small-signal brand while keeping the containing app focused', () => {
  assert.match(site, /SMALL SIGNALS\. BIG TIMING\./)
  assert.match(site, /The smallest thing/)
  assert.match(site, /that says a lot\./)
  assert.match(site, /The downloaded app gives the Tiny GIFs signal its home/)
  assert.match(site, /Made for the moment between the words\./)
  assert.doesNotMatch(site, /Useful everywhere else\./)
})

test('brand small text preserves AA contrast on its paper and signal surfaces', () => {
  assert.match(styles, /hero__note \{[^}]*color: #665951/)
  assert.match(styles, /giphy-explorer__meta \{[^}]*color: #665951/)
  assert.match(styles, /app-guide \.eyebrow \{ color: #38120e/)
  assert.match(styles, /app-guide__copy > p:not\(\.eyebrow\) \{[^}]*color: #38120e/)
})

test('first-launch app applies the brand while keeping Messages primary and the keyboard optional', () => {
  assert.match(app, /A little more you, right in Messages\./)
  assert.match(app, /Your three-second tour/)
  assert.match(app, /Open Messages/)
  assert.match(app, /Optional keyboard/)
  assert.match(app, /Search GIPHY in the drawer/)
  assert.match(app, /brandAccent/)
  assert.match(app, /static let brandAccent = Color\(uiColor: UIColor \{ traits in/)
  assert.match(app, /traits\.userInterfaceStyle == \.dark/)
  assert.match(app, /openURL\(URL\(string: "sms:"\)!\)/)
  assert.doesNotMatch(app, /\.preferredColorScheme\(\.light\)/)
  assert.doesNotMatch(app, /GIPHY SEARCH/)
})
