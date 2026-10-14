const apiKey = process.env.GIPHY_API_KEY?.trim()

if (!apiKey) {
  console.error('A GIPHY API key is required.')
  process.exit(65)
}

try {
  const url = new URL('https://api.giphy.com/v1/gifs/trending')
  url.search = new URLSearchParams({ api_key: apiKey, limit: '1', rating: 'g' })
  const response = await fetch(url, { signal: AbortSignal.timeout(20_000) })
  const payload = response.ok ? await response.json() : null
  if (!response.ok || !Array.isArray(payload?.data) || !payload.data.length) {
    console.error(`GIPHY access validation failed (HTTP ${response.status}).`)
    process.exit(65)
  }
  console.log('Verified GIPHY API access.')
} catch {
  // Network errors can contain the request URL, including the API key.
  console.error('GIPHY access validation failed: network error or invalid response.')
  process.exit(65)
}
