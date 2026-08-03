#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
keyboard_plist="$root/ios/TinyGIFsKeyboard/Info.plist"
host_source="$root/ios/TinyGIFsApp/TinyGIFsApp.swift"
website_source="$root/src/components/SharingPathDemo.tsx"

requests_open_access="$(/usr/libexec/PlistBuddy -c 'Print :NSExtension:NSExtensionAttributes:RequestsOpenAccess' "$keyboard_plist")"
test "$requests_open_access" = "true"

grep -Fq 'supported chat apps' "$host_source"
grep -Fq 'Keyboard for supported chats.' "$website_source"

if grep -Fq 'GIFs wherever' "$host_source" || grep -Fq 'from any app' "$host_source"; then
  echo 'Overbroad keyboard compatibility claim remains in the native host app.' >&2
  exit 1
fi

echo 'Keyboard Open Access and launch compatibility claims verified.'
