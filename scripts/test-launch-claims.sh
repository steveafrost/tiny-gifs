#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
keyboard_plist="$root/ios/TinyGIFsKeyboard/Info.plist"
host_source="$root/ios/TinyGIFsApp/TinyGIFsApp.swift"
website_source="$root/src/components/SharingPathDemo.tsx"
support_source="$root/src/components/InfoPages.tsx"
messages_source="$root/ios/messages/MessagesViewController.swift"
renderer_source="$root/ios/messages/TinyGIFAttachmentRenderer.swift"

requests_open_access="$(/usr/libexec/PlistBuddy -c 'Print :NSExtension:NSExtensionAttributes:RequestsOpenAccess' "$keyboard_plist")"
test "$requests_open_access" = "true"

grep -Fq 'supported chat apps' "$host_source"
grep -Fq "title: 'Optional keyboard elsewhere.'" "$website_source"
grep -Fq 'paste into a supported chat.' "$website_source"
grep -Fq 'send it immediately' "$website_source"
grep -Fq 'send it immediately' "$support_source"
grep -Fq 'Open Messages' "$host_source"
grep -Fq 'TinyGIFMessageSender.send(' "$messages_source"
grep -Fq 'static let canvasPixels: CGFloat = 192' "$renderer_source"
grep -Fq 'sticker-v14' "$renderer_source"

if grep -Eq 'Added — tap Send|add it to the message field, then tap Send|TinyGIFMessageSender\.insert\(' \
  "$website_source" "$support_source" "$host_source" "$messages_source"; then
  echo 'Stale two-tap Messages copy remains in a release surface.' >&2
  exit 1
fi

if grep -Fq 'GIFs wherever' "$host_source" || grep -Fq 'from any app' "$host_source"; then
  echo 'Overbroad keyboard compatibility claim remains in the native host app.' >&2
  exit 1
fi

echo 'Keyboard Open Access and launch compatibility claims verified.'
