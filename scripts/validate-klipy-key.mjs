import { klipyRequestURL, toGifItems } from '../src/lib/klipy.js'
const apiKey = process.env.KLIPY_API_KEY?.trim()
if (!apiKey) { console.error('A KLIPY API key is required.'); process.exit(65) }
try {
  const response = await fetch(klipyRequestURL(apiKey, { limit: 8 }), { signal: AbortSignal.timeout(15000) })
  if (!response.ok) { console.error('KLIPY access validation failed (HTTP ' + response.status + ').'); process.exit(65) }
  if (!toGifItems(await response.json()).length) throw new Error('Empty catalog')
  console.log('Verified KLIPY API access.')
} catch {
  console.error('KLIPY access validation failed: network error or invalid response.')
  process.exit(65)
}
