#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
project="$root/ios/TinyGIFs.xcodeproj"
scheme="TinyGIFs"
export_options="$root/ios/ExportOptions.plist"
keychain_service="${TINY_GIFS_GIPHY_KEYCHAIN_SERVICE:-tiny-gifs-giphy-api-key}"

usage() {
  cat <<'USAGE'
Usage: scripts/release-testflight.sh <build-number> [--validate|--archive|--upload]

Reads the production GIPHY key from GIPHY_API_KEY or the macOS Keychain item
"tiny-gifs-giphy-api-key". The key is placed only in a temporary build config,
never written into the repository or printed in logs.

Modes:
  --validate  Verify that a production GIPHY key is available and accepted.
  --archive   Create and inspect a signed archive with the supplied build number.
  --upload    Archive, inspect, and upload to App Store Connect.
USAGE
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage >&2
  exit 64
fi

build_number="$1"
mode="${2:---validate}"
if [[ ! "$build_number" =~ ^[1-9][0-9]*$ ]]; then
  echo "Build number must be a positive integer." >&2
  exit 64
fi
case "$mode" in
  --validate|--archive|--upload) ;;
  *) usage >&2; exit 64 ;;
esac

api_key="${GIPHY_API_KEY:-}"
if [[ -z "$api_key" ]]; then
  api_key="$(security find-generic-password -s "$keychain_service" -w 2>/dev/null || true)"
fi
if [[ -z "$api_key" ]]; then
  echo "A production GIPHY key is required. Set GIPHY_API_KEY or add the Keychain item '$keychain_service'." >&2
  exit 65
fi

workdir="$(mktemp -d "${TMPDIR:-/tmp}/tiny-gifs-release.XXXXXX")"
cleanup() {
  rm -rf "$workdir"
}
trap cleanup EXIT
chmod 700 "$workdir"

response="$workdir/giphy-response.json"
curl_config="$workdir/giphy-validation.curl"
# Keep the client credential out of curl's process arguments as well as out of logs.
printf 'silent\nshow-error\nmax-time = 20\nget\nurl = "https://api.giphy.com/v1/gifs/trending"\ndata-urlencode = "api_key=%s"\ndata-urlencode = "limit=1"\ndata-urlencode = "rating=g"\noutput = "%s"\nwrite-out = "%%{http_code}"\n' "$api_key" "$response" > "$curl_config"
http_status="$(curl --config "$curl_config")"
if [[ "$http_status" != "200" ]] || ! python3 - "$response" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as source:
    payload = json.load(source)
if not isinstance(payload.get("data"), list) or not payload["data"]:
    raise SystemExit(1)
PY
then
  echo "The configured GIPHY key was rejected or returned no usable trending result (HTTP $http_status)." >&2
  exit 65
fi
echo "Verified production GIPHY access."

if [[ "$mode" == "--validate" ]]; then
  exit 0
fi

build_config="$workdir/ReleaseOverrides.xcconfig"
# Keep this file private: Info.plist variable substitution embeds the API key in the
# product, but it must not land in source control or command-line build logs.
umask 077
printf 'GIPHY_API_KEY = %s\nCURRENT_PROJECT_VERSION = %s\n' "$api_key" "$build_number" > "$build_config"

archive="$root/build/TinyGIFs-${build_number}.xcarchive"
log="$workdir/xcodebuild.log"
rm -rf "$archive"

if ! xcodebuild \
  -project "$project" \
  -scheme "$scheme" \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath "$archive" \
  -xcconfig "$build_config" \
  -allowProvisioningUpdates \
  archive >"$log" 2>&1; then
  grep -E '(^| )error:|Provisioning|Signing|not permitted' "$log" | tail -80 >&2 || true
  echo "Archive failed; full build log is private at $log until this command exits." >&2
  exit 1
fi

app="$archive/Products/Applications/TinyGIFs.app"
expected_plists=(
  "$app/Info.plist"
  "$app/PlugIns/messages.appex/Info.plist"
  "$app/PlugIns/TinyGIFsKeyboard.appex/Info.plist"
)
for plist in "${expected_plists[@]}"; do
  if [[ ! -f "$plist" ]]; then
    echo "Archive is missing expected bundle metadata: ${plist#$archive/}" >&2
    exit 1
  fi
  archived_build="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$plist" 2>/dev/null || true)"
  archived_key="$(/usr/libexec/PlistBuddy -c 'Print :GIPHY_API_KEY' "$plist" 2>/dev/null || true)"
  if [[ "$archived_build" != "$build_number" ]]; then
    echo "Archive bundle version mismatch in ${plist#$archive/}: expected $build_number." >&2
    exit 1
  fi
  if [[ -z "$archived_key" || "$archived_key" == *'$(GIPHY_API_KEY)'* ]]; then
    echo "Archive is missing a resolved GIPHY key in ${plist#$archive/}." >&2
    exit 1
  fi
done

keyboard_plist="$app/PlugIns/TinyGIFsKeyboard.appex/Info.plist"
requests_open_access="$(/usr/libexec/PlistBuddy -c 'Print :NSExtension:NSExtensionAttributes:RequestsOpenAccess' "$keyboard_plist" 2>/dev/null || true)"
if [[ "$requests_open_access" != "true" ]]; then
  echo "Archive keyboard extension is not configured to request Full Access." >&2
  exit 1
fi
echo "Verified build $build_number, resolved GIPHY configuration, and keyboard Open Access in app and extensions."

if [[ "$mode" == "--upload" ]]; then
  if ! xcodebuild \
    -exportArchive \
    -archivePath "$archive" \
    -exportOptionsPlist "$export_options" \
    -allowProvisioningUpdates >"$log" 2>&1; then
    grep -E '(^| )error:|ERROR|Upload|not permitted|Authentication' "$log" | tail -80 >&2 || true
    echo "App Store Connect upload failed; full export log is private at $log until this command exits." >&2
    exit 1
  fi
  echo "Upload accepted by App Store Connect."
fi
