import { serveKlipy } from '../server/klipy.js'

export default async function handler(req, res) {
  return serveKlipy(req, res, process.env.KLIPY_API_KEY)
}
