#!/usr/bin/env bash
set -euo pipefail

EXPECTED_FLUTTER="3.50.0"
FLUTTER_HOME="${FLUTTER_HOME:-/opt/flutter}"
ANDROID_HOME="${ANDROID_HOME:-/opt/android}"
FLUTTER_ARCHIVE="/tmp/flutter_linux_${EXPECTED_FLUTTER}-stable.tar.xz"

if [[ ! -x "${FLUTTER_HOME}/bin/flutter" ]]; then
  echo "Installing Flutter ${EXPECTED_FLUTTER} into ${FLUTTER_HOME}..."
  curl -fsSL --retry 3 \
    "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${EXPECTED_FLUTTER}-stable.tar.xz" \
    -o "${FLUTTER_ARCHIVE}"
  sudo mkdir -p "${FLUTTER_HOME%/*}"
  sudo tar -xf "${FLUTTER_ARCHIVE}" -C "${FLUTTER_HOME%/*}"
  sudo chown -R "$(id -un):$(id -gn)" "${FLUTTER_HOME}"
  rm -f "${FLUTTER_ARCHIVE}"
fi

export PATH="${FLUTTER_HOME}/bin:$PATH"
echo 'export PATH="/opt/flutter/bin:$PATH"' >> "$HOME/.bashrc"

FLUTTER_VERSION="$(flutter --version | head -n 1)"
if [[ "$FLUTTER_VERSION" != *"Flutter ${EXPECTED_FLUTTER}"* ]]; then
  echo "Expected Flutter ${EXPECTED_FLUTTER}, found: $FLUTTER_VERSION" >&2
  exit 1
fi

flutter config --no-analytics --android-sdk "${ANDROID_HOME}"
if command -v sdkmanager >/dev/null 2>&1; then
  yes | sdkmanager --licenses >/dev/null || true
fi
flutter doctor --android-licenses || true

cd "$(dirname "$0")/.."
bash tooling/bootstrap_mobile_platforms.sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs

echo
echo "Athaar Codespace is ready."
echo "Run: flutter analyze"
echo "Run: flutter test"
echo "Run: flutter run"
