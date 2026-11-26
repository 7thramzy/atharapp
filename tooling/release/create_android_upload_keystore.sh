#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
KEYSTORE_DIR="$ROOT_DIR/android/app"
KEYSTORE_FILE="$KEYSTORE_DIR/upload-keystore.jks"
ENCODED_FILE="$ROOT_DIR/android/athaar-upload-keystore.base64"
KEY_ALIAS="athaar-upload"

if ! command -v keytool >/dev/null 2>&1; then
  echo "ERROR: Java keytool is required. Install a supported JDK first." >&2
  exit 1
fi

if [[ -e "$KEYSTORE_FILE" ]]; then
  echo "ERROR: $KEYSTORE_FILE already exists. Refusing to overwrite an existing signing key." >&2
  exit 1
fi

if [[ -e "$ENCODED_FILE" ]]; then
  echo "ERROR: $ENCODED_FILE already exists. Move it to a secure backup before retrying." >&2
  exit 1
fi

mkdir -p "$KEYSTORE_DIR"
umask 077

echo "Creating the Athaar Android upload key."
echo "Keytool will prompt for the keystore and key passwords. Keep them private."
echo "Use a long unique password and store it in a secure password manager."
keytool -genkeypair -v \
  -keystore "$KEYSTORE_FILE" \
  -storetype JKS \
  -keyalg RSA \
  -keysize 4096 \
  -validity 10000 \
  -alias "$KEY_ALIAS" \
  -dname "CN=Athaar Android Upload, OU=Release, O=Athaar, C=YE"

chmod 600 "$KEYSTORE_FILE"
base64 < "$KEYSTORE_FILE" | tr -d '\n' > "$ENCODED_FILE"
chmod 600 "$ENCODED_FILE"

echo
echo "Created the local Android upload keystore."
echo "Keystore: $KEYSTORE_FILE"
echo "Base64 secret file: $ENCODED_FILE"
echo "Alias: $KEY_ALIAS"
echo
echo "Copy the CONTENTS of the base64 file into GitHub Actions secret:"
echo "  ANDROID_KEYSTORE_BASE64"
echo "Create these additional repository secrets manually:"
echo "  ANDROID_STORE_PASSWORD"
echo "  ANDROID_KEY_ALIAS (value: $KEY_ALIAS)"
echo "  ANDROID_KEY_PASSWORD"
echo
echo "Keep at least two encrypted backups of the original .jks file offline."
echo "Never commit the .jks file, the .base64 file, key.properties, or passwords."
