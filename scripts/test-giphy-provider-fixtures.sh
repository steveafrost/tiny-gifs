#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
check_dir="$(mktemp -d "${TMPDIR:-/tmp}/tiny-gifs-provider-check.XXXXXX")"
trap 'rm -rf "$check_dir"' EXIT
for service in Shared messages; do
  swiftc "$root/ios/$service/GiphyService.swift" "$root/test/GiphyProviderFixtureChecks.swift" -o "$check_dir/check"
  "$check_dir/check"
done
