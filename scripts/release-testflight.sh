#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
project="$root/ios/TinyGIFs.xcodeproj"
scheme="TinyGIFs"
export_options="$root/ios/ExportOptions.plist"
keychain_service="${TINY_GIFS_KLIPY_KEYCHAIN_SERVICE:-tiny-gifs-klipy-api-key}"

usage() {
  cat <<'USAGE'
Usage: scripts/release-testflight.sh <build-number> [--validate|--archive|--upload]

Reads the KLIPY key (beta or production) from KLIPY_API_KEY or the macOS Keychain item
"tiny-gifs-klipy-api-key". The key is placed only in a temporary build config,
never written into the repository or printed in logs.

Modes:
  --validate  Verify that a KLIPY key is available and accepted.
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

api_key="${KLIPY_API_KEY:-}"
if [[ -z "$api_key" ]]; then
  api_key="$(security find-generic-password -s "$keychain_service" -w 2>/dev/null || true)"
fi
if [[ -z "$api_key" ]]; then
  echo "A KLIPY key is required. Set KLIPY_API_KEY or add the Keychain item '$keychain_service'." >&2
  exit 65
fi

workdir="$(mktemp -d "${TMPDIR:-/tmp}/tiny-gifs-release.XXXXXX")"
cleanup() {
  rm -rf "$workdir"
}
trap cleanup EXIT
chmod 700 "$workdir"

report_build_failure() {
  local saved_log
  saved_log="$(mktemp "${TMPDIR:-/tmp}/tiny-gifs-release-failure.XXXXXX")"
  KLIPY_API_KEY="$api_key" node --input-type=module - "$log" "$saved_log" <<'JS'
import { readFileSync, writeFileSync } from 'node:fs'
const sanitized = readFileSync(process.argv[2], 'utf8')
  .split(process.env.KLIPY_API_KEY).join('[redacted]')
writeFileSync(process.argv[3], sanitized, { mode: 0o600 })
const lines = sanitized.split('\n').filter(line => /error:|Error|failed|errSec|not allowed|not permitted|Authentication/.test(line))
console.error(lines.slice(-20).map(line => line.slice(0, 1000)).join('\n'))
JS
  echo "Sanitized build log retained at $saved_log." >&2
}

# Pass the credential through the child environment, never process arguments.
KLIPY_API_KEY="$api_key" node "$root/scripts/validate-klipy-key.mjs"

if [[ "$mode" == "--validate" ]]; then
  exit 0
fi

media_approved="${KLIPY_MEDIA_PROCESSING_APPROVED:-NO}"
internal_testing="${KLIPY_INTERNAL_TESTING:-NO}"
review_pending="${KLIPY_REVIEW_PENDING:-NO}"
if [[ "$media_approved" != "YES" && "$internal_testing" != "YES" && "$review_pending" != "YES" ]]; then
  echo "Compact KLIPY sharing requires written KLIPY approval for local media processing. Set KLIPY_MEDIA_PROCESSING_APPROVED=YES only after approval." >&2
  exit 65
fi

build_config="$workdir/ReleaseOverrides.xcconfig"
# Keep this file private: Info.plist variable substitution embeds the API key in the
# product, but it must not land in source control or command-line build logs.
umask 077
printf 'KLIPY_API_KEY = %s\nCURRENT_PROJECT_VERSION = %s\nKLIPY_MEDIA_PROCESSING_APPROVED = %s\nKLIPY_INTERNAL_TESTING = %s\nKLIPY_REVIEW_PENDING = %s\n' "$api_key" "$build_number" "$media_approved" "$internal_testing" "$review_pending" > "$build_config"

if [[ "$internal_testing" == "YES" ]]; then
  export_options="$workdir/InternalTestingExport.plist"
  cp "$root/ios/ExportOptions.plist" "$export_options"
  /usr/libexec/PlistBuddy -c 'Add :testFlightInternalTestingOnly bool true' "$export_options"
  echo "This upload is restricted to internal TestFlight testing."
fi

if [[ "$review_pending" == "YES" ]]; then
  echo "App Store review build: KLIPY approval remains pending. App Store release follows the owner-selected setting."
fi

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
  report_build_failure
  echo "Archive failed." >&2
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
  archived_key="$(/usr/libexec/PlistBuddy -c 'Print :KLIPY_API_KEY' "$plist" 2>/dev/null || true)"
  for field in KLIPY_MEDIA_PROCESSING_APPROVED KLIPY_INTERNAL_TESTING KLIPY_REVIEW_PENDING; do
    case "$field" in
      KLIPY_MEDIA_PROCESSING_APPROVED) expected_value="$media_approved" ;;
      KLIPY_INTERNAL_TESTING) expected_value="$internal_testing" ;;
      KLIPY_REVIEW_PENDING) expected_value="$review_pending" ;;
    esac
    archived_value="$(/usr/libexec/PlistBuddy -c "Print :$field" "$plist" 2>/dev/null || true)"
    if [[ "$archived_value" != "$expected_value" ]]; then
      echo "Archive configuration mismatch for $field in ${plist#$archive/}." >&2
      exit 1
    fi
  done
  if [[ "$archived_build" != "$build_number" ]]; then
    echo "Archive bundle version mismatch in ${plist#$archive/}: expected $build_number." >&2
    exit 1
  fi
  if [[ -z "$archived_key" || "$archived_key" == *'$(KLIPY_API_KEY)'* ]]; then
    echo "Archive is missing a resolved KLIPY key in ${plist#$archive/}." >&2
    exit 1
  fi
done

keyboard_plist="$app/PlugIns/TinyGIFsKeyboard.appex/Info.plist"
requests_open_access="$(/usr/libexec/PlistBuddy -c 'Print :NSExtension:NSExtensionAttributes:RequestsOpenAccess' "$keyboard_plist" 2>/dev/null || true)"
if [[ "$requests_open_access" != "true" ]]; then
  echo "Archive keyboard extension is not configured to request Full Access." >&2
  exit 1
fi
uses_non_exempt_encryption="$(/usr/libexec/PlistBuddy -c 'Print :ITSAppUsesNonExemptEncryption' "$app/Info.plist" 2>/dev/null || true)"
if [[ "$uses_non_exempt_encryption" != "false" ]]; then
  echo "Archive does not declare that Tiny GIFs uses no non-exempt encryption." >&2
  exit 1
fi
echo "Verified build $build_number, resolved KLIPY configuration, export compliance, and keyboard Open Access in app and extensions."

if [[ "$mode" == "--upload" ]]; then
  if ! xcodebuild \
    -exportArchive \
    -archivePath "$archive" \
    -exportOptionsPlist "$export_options" \
    -allowProvisioningUpdates >"$log" 2>&1; then
    report_build_failure
    echo "App Store Connect upload failed." >&2
    exit 1
  fi
  echo "Upload accepted by App Store Connect."
fi
