import { klipyRequestURL } from '../src/lib/klipy.js'

export async function getKlipyResponse(requestURL, key, fetchImpl = fetch) {
  if (!key?.trim()) return { status: 503, body: { error: 'GIF search is unavailable.' } }
  const params = new URL(requestURL, 'http://localhost').searchParams
  const query = params.get('q') || ''
  if (query.length > 200) return { status: 400, body: { error: 'Search is too long.' } }
  const limit = Number(params.get('limit') || 12)
  if (!Number.isInteger(limit) || limit < 8 || limit > 50) return { status: 400, body: { error: 'Invalid result limit.' } }
  try {
    const response = await fetchImpl(klipyRequestURL(key, { query, limit }), { signal: AbortSignal.timeout(10000) })
    if (!response.ok) throw new Error('Provider unavailable')
    const payload = await response.json()
    if (payload?.result !== true || !Array.isArray(payload.data?.data)) throw new Error('Invalid provider response')
    // Provider errors and request URLs must never expose the credential.
    return { status: 200, body: JSON.parse(JSON.stringify(payload).split(key).join('[redacted]')) }
  } catch {
    return { status: 502, body: { error: 'GIF search could not load right now.' } }
  }
}

export async function serveKlipy(req, res, key) {
  res.setHeader('Cache-Control', 'no-store')
  res.setHeader('Content-Type', 'application/json')
  if (req.method !== 'GET') {
    res.setHeader('Allow', 'GET')
    res.statusCode = 405
    return res.end(JSON.stringify({ error: 'Method not allowed.' }))
  }
  const result = await getKlipyResponse(req.url, key)
  res.statusCode = result.status
  res.end(JSON.stringify(result.body))
}
