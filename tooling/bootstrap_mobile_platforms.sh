#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

configure_audio_permissions() {
  local android_manifest="$ROOT_DIR/android/app/src/main/AndroidManifest.xml"
  local ios_plist="$ROOT_DIR/ios/Runner/Info.plist"

  if [[ -f "$android_manifest" ]]; then
    python3 - "$android_manifest" <<'PY'
from pathlib import Path
import sys

manifest = Path(sys.argv[1])
text = manifest.read_text()
permission = '<uses-permission android:name="android.permission.RECORD_AUDIO" />'
if permission not in text:
    marker = '    <application'
    if marker not in text:
        raise SystemExit('Could not locate the Android application element.')
    text = text.replace(marker, f'    {permission}\n{marker}', 1)
    manifest.write_text(text)
PY
  fi

  if [[ -f "$ios_plist" ]]; then
    python3 - "$ios_plist" <<'PY'
from pathlib import Path
import sys

plist = Path(sys.argv[1])
text = plist.read_text()
key = '<key>NSMicrophoneUsageDescription</key>'
if key not in text:
    root_end = text.rfind('</dict>')
    if root_end < 0:
        raise SystemExit('Could not locate the root dictionary in Info.plist.')
    value = (
        'Athaar uses the microphone only after you tap Start; audio is stored '
        'temporarily on this device and deleted when you leave this screen. / '
        'لا يستخدم أثَر الميكروفون إلا بعد الضغط على بدء التسجيل؛ يُحفظ الصوت '
        'مؤقتاً على الجهاز ويُحذف عند مغادرة هذه الشاشة.'
    )
    entry = f'    {key}\n    <string>{value}</string>\n'
    text = text[:root_end] + entry + text[root_end:]
    plist.write_text(text)
PY
  fi
}

NEEDS_GENERATION=0
[[ -d android ]] || NEEDS_GENERATION=1
[[ -d ios ]] || NEEDS_GENERATION=1

if [[ "$NEEDS_GENERATION" -eq 0 ]]; then
  configure_audio_permissions
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

configure_audio_permissions

echo "Generated missing Android/iOS platform folders."
echo "Review and commit the native folders when the application identifier is finalized."
