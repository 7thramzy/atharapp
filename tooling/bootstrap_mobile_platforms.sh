#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

NEEDS_GENERATION=0
[[ -d android ]] || NEEDS_GENERATION=1
[[ -d ios ]] || NEEDS_GENERATION=1

if [[ "$NEEDS_GENERATION" -eq 0 ]]; then
  echo "Android and iOS platform folders already exist."
  exit 0
fi

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK is required to generate native platform folders." >&2
  exit 1
fi

TEMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

flutter create \
  --no-pub \
  --project-name athaar \
  --org com.athaar \
  --platforms=android,ios \
  "$TEMP_DIR/athaar"

if [[ ! -d android ]]; then
  cp -a "$TEMP_DIR/athaar/android" "$ROOT_DIR/android"
fi

if [[ ! -d ios ]]; then
  cp -a "$TEMP_DIR/athaar/ios" "$ROOT_DIR/ios"
fi

if [[ ! -f .metadata ]]; then
  cp "$TEMP_DIR/athaar/.metadata" "$ROOT_DIR/.metadata"
fi

echo "Generated missing Android/iOS platform folders."
echo "Review and commit the native folders when the application identifier is finalized."
