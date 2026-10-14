import { copyFileSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs'

mkdirSync('dist/server', { recursive: true })
mkdirSync('dist/.openai', { recursive: true })

copyFileSync('.openai/hosting.json', 'dist/.openai/hosting.json')
copyFileSync('src/lib/klipy.js', 'dist/server/klipy-url.js')
writeFileSync('dist/server/klipy.js', readFileSync('server/klipy.js', 'utf8').replace('../src/lib/klipy.js', './klipy-url.js'))

writeFileSync(
  'dist/server/index.js',
  `import { getKlipyResponse } from './klipy.js'

export default {
  async fetch(request, env) {
    if (new URL(request.url).pathname === '/api/gifs') {
      if (request.method !== 'GET') return Response.json({ error: 'Method not allowed.' }, { status: 405, headers: { Allow: 'GET' } })
      const result = await getKlipyResponse(request.url, env.KLIPY_API_KEY)
      return Response.json(result.body, { status: result.status, headers: { 'Cache-Control': 'no-store' } })
    }
    if (!env.ASSETS) {
      return new Response('Static asset binding unavailable', { status: 500 })
    }

    const response = await env.ASSETS.fetch(request)
    if (response.status !== 404 || request.method !== 'GET') return response

    const fallbackUrl = new URL('/index.html', request.url)
    return env.ASSETS.fetch(new Request(fallbackUrl, request))
  },
}
`,
)
