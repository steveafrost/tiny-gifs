#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
release_script="$root/scripts/release-testflight.sh"

if [[ ! -x "$release_script" ]]; then
  echo "missing executable release-testflight.sh" >&2
  exit 1
fi

# The archive verifier must reject a keyboard that cannot request Full Access.
if ! grep -Fq 'Print :NSExtension:NSExtensionAttributes:RequestsOpenAccess' "$release_script"; then
  echo "release archive verification does not inspect RequestsOpenAccess" >&2
  exit 1
fi

# A TestFlight release must never silently proceed without a production GIPHY key.
if GIPHY_API_KEY='' TINY_GIFS_GIPHY_KEYCHAIN_SERVICE='missing-test-key' "$release_script" 23 --validate; then
  echo "release validation unexpectedly accepted a missing GIPHY key" >&2
  exit 1
fi

# This host stores the production key in Keychain. Validate the real release path
# at the version currently configured for every app/extension target, without
# printing or persisting the secret.
current_build="$(/usr/bin/grep -m1 -E 'CURRENT_PROJECT_VERSION = [0-9]+;' "$root/ios/TinyGIFs.xcodeproj/project.pbxproj" | /usr/bin/grep -Eo '[0-9]+')"
test -n "$current_build"
"$release_script" "$current_build" --validate

echo "release TestFlight preflight passed"
