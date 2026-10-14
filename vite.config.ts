import { defineConfig, loadEnv } from 'vite'
import react from '@vitejs/plugin-react'
import { serveKlipy } from './server/klipy.js'

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, '.', '')
  return {
    plugins: [react(), {
      name: 'private-klipy-api',
      configureServer(server) {
        server.middlewares.use('/api/gifs', (req, res) => {
          void serveKlipy(req, res, env.KLIPY_API_KEY)
        })
      },
    }],
    build: { outDir: 'dist/client' },
  }
})
