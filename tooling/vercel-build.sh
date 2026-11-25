#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="3.50.0"
WORK_DIR="${TMPDIR:-/tmp}/athaar-vercel-build"
FLUTTER_ROOT="${WORK_DIR}/flutter"
FLUTTER_ARCHIVE="${WORK_DIR}/flutter-linux-${FLUTTER_VERSION}.tar.xz"
PUB_CACHE="${WORK_DIR}/pub-cache"

mkdir -p "$WORK_DIR"
export PUB_CACHE
export CI=true

if [[ ! -x "$FLUTTER_ROOT/bin/flutter" ]]; then
  rm -rf "$FLUTTER_ROOT"
  mkdir -p "$FLUTTER_ROOT"
  curl --fail --location --retry 3 --retry-delay 2 \
    "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    --output "$FLUTTER_ARCHIVE"
  tar -xJf "$FLUTTER_ARCHIVE" --strip-components=1 -C "$FLUTTER_ROOT"
fi

export PATH="$FLUTTER_ROOT/bin:$PATH"
flutter config --no-analytics --enable-web >/dev/null
flutter --version

python3 tooling/content/quran/download_source.py
python3 tooling/content/quran/build_dataset.py
mkdir -p assets/content/quran
cp build/tanzil-acquisition/tanzil-uthmani-v1.1.json assets/content/quran/

flutter create --no-pub --project-name athaar --org com.athaar --platforms=web .
flutter pub get
dart run build_runner build

mkdir -p web
curl --fail --location --retry 3 \
  "https://github.com/simolus3/drift/releases/download/drift-2.35.4/sqlite3.wasm" \
  --output web/sqlite3.wasm
curl --fail --location --retry 3 \
  "https://github.com/simolus3/drift/releases/download/drift-2.35.4/drift_worker.js" \
  --output web/drift_worker.js

echo "e7451780e78c56ff864fe9317a0fbcd6aeb2e8de3beba7f5efd963202f7ec3d9  web/sqlite3.wasm" | sha256sum --check
echo "48c950cd8e3bc3cddb34816c860e228be8832bef07a297c27e9907c057ff8162  web/drift_worker.js" | sha256sum --check

flutter build web --release
test -s build/web/index.html
test -s build/web/sqlite3.wasm
test -s build/web/drift_worker.js
