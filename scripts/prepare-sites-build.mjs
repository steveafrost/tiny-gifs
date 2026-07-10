import { copyFileSync, mkdirSync, writeFileSync } from 'node:fs'

mkdirSync('dist/server', { recursive: true })
mkdirSync('dist/.openai', { recursive: true })

copyFileSync('.openai/hosting.json', 'dist/.openai/hosting.json')

writeFileSync(
  'dist/server/index.js',
  `export default {
  async fetch(request, env) {
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
