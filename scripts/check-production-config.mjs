const required = ['VITE_GIPHY_API_KEY']
const missing = required.filter((name) => !process.env[name]?.trim())

if (missing.length) {
  console.error(`Production build requires: ${missing.join(', ')}`)
  process.exit(1)
}

console.log('Production GIF configuration is present.')
