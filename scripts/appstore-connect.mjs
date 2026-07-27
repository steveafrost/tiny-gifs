#!/usr/bin/env node

import { createPrivateKey, createSign } from 'node:crypto'
import { readFileSync } from 'node:fs'

const [command, ...args] = process.argv.slice(2)
const keyID = process.env.APP_STORE_CONNECT_KEY_ID
const issuerID = process.env.APP_STORE_CONNECT_ISSUER_ID
const keyPath = process.env.APP_STORE_CONNECT_KEY_PATH

if (!command || !keyID || !issuerID || !keyPath) {
  console.error('Usage: APP_STORE_CONNECT_KEY_ID=… APP_STORE_CONNECT_ISSUER_ID=… APP_STORE_CONNECT_KEY_PATH=… node scripts/appstore-connect.mjs <apps-list|apps-create> [arguments]')
  process.exit(2)
}

const encode = (value) => Buffer.from(value).toString('base64url')

function token() {
  const header = encode(JSON.stringify({ alg: 'ES256', kid: keyID, typ: 'JWT' }))
  const now = Math.floor(Date.now() / 1000)
  const payload = encode(JSON.stringify({ iss: issuerID, iat: now, exp: now + 1_100, aud: 'appstoreconnect-v1' }))
  const signer = createSign('SHA256')
  signer.update(`${header}.${payload}`)
  signer.end()
  const signature = signer.sign({ key: createPrivateKey(readFileSync(keyPath)), dsaEncoding: 'ieee-p1363' }).toString('base64url')
  return `${header}.${payload}.${signature}`
}

async function request(path, options = {}) {
  const response = await fetch(`https://api.appstoreconnect.apple.com/v1${path}`, {
    ...options,
    headers: { Authorization: `Bearer ${token()}`, 'Content-Type': 'application/json', ...(options.headers ?? {}) },
  })
  const body = await response.text()
  if (!response.ok) throw new Error(`${response.status} ${body}`)
  return body ? JSON.parse(body) : null
}

if (command === 'developer-resources') {
  const result = await Promise.all([
    request('/bundleIds?filter%5Bidentifier%5D=com.tinygifs.app&limit=10'),
    request('/certificates?filter%5BcertificateType%5D=DISTRIBUTION&limit=10'),
    request('/profiles?filter%5BprofileType%5D=IOS_APP_STORE&limit=200'),
  ])
  console.log(JSON.stringify({ bundleIds: result[0], certificates: result[1], profiles: result[2] }, null, 2))
} else if (command === 'profiles-download') {
  if (args.length === 0) throw new Error('profiles-download requires one or more profile IDs')
  const result = await Promise.all(args.map((profileID) => request(`/profiles/${profileID}`)))
  console.log(JSON.stringify(result, null, 2))
} else if (command === 'profile-bundleids') {
  if (args.length === 0) throw new Error('profile-bundleids requires one or more profile IDs')
  const result = await Promise.all(args.map((profileID) => request(`/profiles/${profileID}/bundleId`)))
  console.log(JSON.stringify(result, null, 2))
} else if (command === 'builds-list') {
  const appID = args[0]
  if (!appID) throw new Error('builds-list requires an App Store Connect app ID')
  const result = await request(`/builds?filter%5Bapp%5D=${encodeURIComponent(appID)}&sort=-uploadedDate&limit=10`)
  console.log(JSON.stringify(result, null, 2))
} else if (command === 'appstore-versions-list') {
  const appID = args[0]
  if (!appID) throw new Error('appstore-versions-list requires an App Store Connect app ID')
  const result = await request(`/apps/${appID}/appStoreVersions?include=appStoreVersionLocalizations&limit=50`)
  console.log(JSON.stringify(result, null, 2))
} else if (command === 'appstore-version-create') {
  const [appID, versionString] = args
  if (!appID || !versionString) throw new Error('appstore-version-create requires <app-id> <version-string>')
  const result = await request('/appStoreVersions', {
    method: 'POST',
    body: JSON.stringify({ data: { type: 'appStoreVersions', attributes: { platform: 'IOS', versionString }, relationships: { app: { data: { type: 'apps', id: appID } } } } }),
  })
  console.log(JSON.stringify(result, null, 2))
} else if (command === 'appstore-version-set-build') {
  const [versionID, buildID] = args
  if (!versionID || !buildID) throw new Error('appstore-version-set-build requires <version-id> <build-id>')
  const result = await request(`/appStoreVersions/${versionID}`, {
    method: 'PATCH',
    body: JSON.stringify({ data: { type: 'appStoreVersions', id: versionID, relationships: { build: { data: { type: 'builds', id: buildID } } } } }),
  })
  console.log(JSON.stringify(result, null, 2))
} else if (command === 'build-set-encryption') {
  const [buildID, value] = args
  if (!buildID || !['true', 'false'].includes(value)) throw new Error('build-set-encryption requires <build-id> <true|false>')
  const result = await request(`/builds/${buildID}`, {
    method: 'PATCH',
    body: JSON.stringify({ data: { type: 'builds', id: buildID, attributes: { usesNonExemptEncryption: value === 'true' } } }),
  })
  console.log(JSON.stringify(result, null, 2))
} else if (command === 'beta-group-create') {
  const [appID, name] = args
  if (!appID || !name) throw new Error('beta-group-create requires <app-id> <name>')
  const result = await request('/betaGroups', {
    method: 'POST',
    body: JSON.stringify({ data: { type: 'betaGroups', attributes: { name, isInternalGroup: false, publicLinkEnabled: true, publicLinkLimit: 10000 }, relationships: { app: { data: { type: 'apps', id: appID } } } } }),
  })
  console.log(JSON.stringify(result, null, 2))
} else if (command === 'beta-group-add-build') {
  const [groupID, buildID] = args
  if (!groupID || !buildID) throw new Error('beta-group-add-build requires <group-id> <build-id>')
  const result = await request(`/betaGroups/${groupID}/relationships/builds`, {
    method: 'POST',
    body: JSON.stringify({ data: [{ type: 'builds', id: buildID }] }),
  })
  console.log(JSON.stringify(result, null, 2))
} else if (command === 'beta-group-enable-public-link') {
  const [groupID] = args
  if (!groupID) throw new Error('beta-group-enable-public-link requires <group-id>')
  const result = await request(`/betaGroups/${groupID}`, {
    method: 'PATCH',
    body: JSON.stringify({ data: { type: 'betaGroups', id: groupID, attributes: { publicLinkEnabled: true, publicLinkLimit: 10000 } } }),
  })
  console.log(JSON.stringify(result, null, 2))
} else if (command === 'beta-build-localization-create') {
  const [buildID, locale, ...whatsNewParts] = args
  const whatsNew = whatsNewParts.join(' ')
  if (!buildID || !locale || !whatsNew) throw new Error('beta-build-localization-create requires <build-id> <locale> <whats-new>')
  const result = await request('/betaBuildLocalizations', {
    method: 'POST',
    body: JSON.stringify({ data: { type: 'betaBuildLocalizations', attributes: { locale, whatsNew }, relationships: { build: { data: { type: 'builds', id: buildID } } } } }),
  })
  console.log(JSON.stringify(result, null, 2))
} else if (command === 'beta-app-localization-create') {
  const [appID, locale, ...descriptionParts] = args
  const description = descriptionParts.join(' ')
  if (!appID || !locale || !description) throw new Error('beta-app-localization-create requires <app-id> <locale> <description>')
  const result = await request('/betaAppLocalizations', {
    method: 'POST',
    body: JSON.stringify({ data: { type: 'betaAppLocalizations', attributes: { locale, description }, relationships: { app: { data: { type: 'apps', id: appID } } } } }),
  })
  console.log(JSON.stringify(result, null, 2))
} else if (command === 'beta-app-localization-update') {
  const [localizationID, feedbackEmail, marketingUrl, privacyPolicyUrl] = args
  if (!localizationID || !feedbackEmail || !marketingUrl || !privacyPolicyUrl) throw new Error('beta-app-localization-update requires <localization-id> <feedback-email> <marketing-url> <privacy-policy-url>')
  const result = await request(`/betaAppLocalizations/${localizationID}`, {
    method: 'PATCH',
    body: JSON.stringify({ data: { type: 'betaAppLocalizations', id: localizationID, attributes: { feedbackEmail, marketingUrl, privacyPolicyUrl } } }),
  })
  console.log(JSON.stringify(result, null, 2))
} else if (command === 'app-info-localization-update') {
  const [localizationID, subtitle, privacyPolicyUrl] = args
  if (!localizationID || !subtitle || !privacyPolicyUrl) throw new Error('app-info-localization-update requires <localization-id> <subtitle> <privacy-policy-url>')
  const result = await request(`/appInfoLocalizations/${localizationID}`, {
    method: 'PATCH',
    body: JSON.stringify({ data: { type: 'appInfoLocalizations', id: localizationID, attributes: { subtitle, privacyPolicyUrl } } }),
  })
  console.log(JSON.stringify(result, null, 2))
} else if (command === 'appstore-localization-update') {
  const [localizationID, description, keywords, marketingUrl, supportUrl] = args
  if (!localizationID || !description || !keywords || !marketingUrl || !supportUrl) throw new Error('appstore-localization-update requires <localization-id> <description> <keywords> <marketing-url> <support-url>')
  const result = await request(`/appStoreVersionLocalizations/${localizationID}`, {
    method: 'PATCH',
    body: JSON.stringify({ data: { type: 'appStoreVersionLocalizations', id: localizationID, attributes: { description, keywords, marketingUrl, supportUrl } } }),
  })
  console.log(JSON.stringify(result, null, 2))
} else if (command === 'screenshot-set-create') {
  const [localizationID, screenshotDisplayType] = args
  if (!localizationID || !screenshotDisplayType) throw new Error('screenshot-set-create requires <localization-id> <display-type>')
  const result = await request('/appScreenshotSets', {
    method: 'POST',
    body: JSON.stringify({ data: { type: 'appScreenshotSets', attributes: { screenshotDisplayType }, relationships: { appStoreVersionLocalization: { data: { type: 'appStoreVersionLocalizations', id: localizationID } } } } }),
  })
  console.log(JSON.stringify(result, null, 2))
} else if (command === 'screenshot-upload') {
  const [screenshotSetID, filePath] = args
  if (!screenshotSetID || !filePath) throw new Error('screenshot-upload requires <screenshot-set-id> <file-path>')
  const { readFileSync, statSync } = await import('node:fs')
  const { basename } = await import('node:path')
  const { createHash } = await import('node:crypto')
  const image = readFileSync(filePath)
  const sourceFileChecksum = createHash('md5').update(image).digest('hex')
  const reservation = await request('/appScreenshots', {
    method: 'POST',
    body: JSON.stringify({ data: { type: 'appScreenshots', attributes: { fileName: basename(filePath), fileSize: statSync(filePath).size }, relationships: { appScreenshotSet: { data: { type: 'appScreenshotSets', id: screenshotSetID } } } } }),
  })
  const screenshot = reservation.data
  for (const operation of screenshot.attributes.uploadOperations ?? []) {
    const headers = Object.fromEntries((operation.requestHeaders ?? []).map(({ name, value }) => [name, value]))
    const body = image.subarray(operation.offset ?? 0, (operation.offset ?? 0) + (operation.length ?? image.length))
    const response = await fetch(operation.url, { method: operation.method, headers, body })
    if (!response.ok) throw new Error(`Screenshot asset upload failed: ${response.status} ${await response.text()}`)
  }
  const result = await request(`/appScreenshots/${screenshot.id}`, {
    method: 'PATCH',
    body: JSON.stringify({ data: { type: 'appScreenshots', id: screenshot.id, attributes: { uploaded: true, sourceFileChecksum } } }),
  })
  console.log(JSON.stringify(result, null, 2))
} else if (command === 'age-rating-set-safe-gifs') {
  const [declarationID] = args
  if (!declarationID) throw new Error('age-rating-set-safe-gifs requires <age-rating-declaration-id>')
  const attributes = {
    advertising: false,
    alcoholTobaccoOrDrugUseOrReferences: 'NONE',
    contests: 'NONE',
    gambling: false,
    gamblingSimulated: 'NONE',
    gunsOrOtherWeapons: 'NONE',
    healthOrWellnessTopics: false,
    lootBox: false,
    medicalOrTreatmentInformation: 'NONE',
    messagingAndChat: false,
    parentalControls: false,
    profanityOrCrudeHumor: 'NONE',
    ageAssurance: false,
    sexualContentGraphicAndNudity: 'NONE',
    sexualContentOrNudity: 'NONE',
    horrorOrFearThemes: 'NONE',
    matureOrSuggestiveThemes: 'NONE',
    unrestrictedWebAccess: false,
    userGeneratedContent: false,
    violenceCartoonOrFantasy: 'NONE',
    violenceRealisticProlongedGraphicOrSadistic: 'NONE',
    violenceRealistic: 'NONE',
  }
  const result = await request(`/ageRatingDeclarations/${declarationID}`, {
    method: 'PATCH',
    body: JSON.stringify({ data: { type: 'ageRatingDeclarations', id: declarationID, attributes } }),
  })
  console.log(JSON.stringify(result, null, 2))
} else if (command === 'app-content-rights-set') {
  const [appID, value] = args
  if (!appID || !['DOES_NOT_USE_THIRD_PARTY_CONTENT', 'USES_THIRD_PARTY_CONTENT'].includes(value)) throw new Error('app-content-rights-set requires <app-id> <DOES_NOT_USE_THIRD_PARTY_CONTENT|USES_THIRD_PARTY_CONTENT>')
  const result = await request(`/apps/${appID}`, {
    method: 'PATCH',
    body: JSON.stringify({ data: { type: 'apps', id: appID, attributes: { contentRightsDeclaration: value } } }),
  })
  console.log(JSON.stringify(result, null, 2))
} else if (command === 'beta-review-detail-update') {
  const [detailID, firstName, lastName, email, phone] = args
  if (!detailID || !firstName || !lastName || !email || !phone) throw new Error('beta-review-detail-update requires <detail-id> <first-name> <last-name> <email> <phone>')
  const result = await request(`/betaAppReviewDetails/${detailID}`, {
    method: 'PATCH',
    body: JSON.stringify({ data: { type: 'betaAppReviewDetails', id: detailID, attributes: { contactFirstName: firstName, contactLastName: lastName, contactEmail: email, contactPhone: phone, demoAccountRequired: false, notes: 'No account is required. Review the Messages extension for the primary sharing flow. The optional keyboard types normally without Full Access; Full Access is used only for optional GIPHY search and local pasteboard copy.' } } }),
  })
  console.log(JSON.stringify(result, null, 2))
} else if (command === 'beta-review-submission-create') {
  const [buildID] = args
  if (!buildID) throw new Error('beta-review-submission-create requires <build-id>')
  const result = await request('/betaAppReviewSubmissions', {
    method: 'POST',
    body: JSON.stringify({ data: { type: 'betaAppReviewSubmissions', relationships: { build: { data: { type: 'builds', id: buildID } } } } }),
  })
  console.log(JSON.stringify(result, null, 2))
} else if (command === 'beta-review-submission-delete') {
  const [submissionID] = args
  if (!submissionID) throw new Error('beta-review-submission-delete requires <submission-id>')
  await request(`/betaAppReviewSubmissions/${submissionID}`, { method: 'DELETE' })
  console.log(JSON.stringify({ deleted: submissionID }))
} else if (command === 'get') {
  const path = args[0]
  if (!path?.startsWith('/')) throw new Error('get requires an App Store Connect API path beginning with /')
  const result = await request(path)
  console.log(JSON.stringify(result, null, 2))
} else if (command === 'apps-list') {
  const bundleID = args[0]
  const query = bundleID ? `?filter[bundleId]=${encodeURIComponent(bundleID)}` : ''
  const result = await request(`/apps${query}`)
  console.log(JSON.stringify(result, null, 2))
} else if (command === 'apps-create') {
  const [name, bundleID, sku] = args
  if (!name || !bundleID || !sku) throw new Error('apps-create requires <name> <bundle-id> <sku>')
  const result = await request('/apps', {
    method: 'POST',
    body: JSON.stringify({ data: { type: 'apps', attributes: { name, bundleId: bundleID, sku, primaryLocale: 'en-US' } } }),
  })
  console.log(JSON.stringify(result, null, 2))
} else {
  throw new Error(`Unsupported command: ${command}`)
}
