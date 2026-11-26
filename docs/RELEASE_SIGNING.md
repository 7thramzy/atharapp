# Production signing for Athaar

This document configures signing without committing private keys or certificates to Git.

## Android — Google Play upload key

1. Confirm the final application ID in Google Play Console. The repository currently uses com.athaar.athaar; do not change it after the first public upload.
2. Generate an upload key on a trusted computer and keep an encrypted backup:
   
   keytool -genkeypair -v -keystore athaar-upload.jks -keyalg RSA -keysize 4096 -validity 10000 -alias athaar-upload

3. Convert the file locally to Base64:
   
   base64 -w 0 athaar-upload.jks

4. In GitHub → Settings → Environments, create an environment named production. Add these environment secrets:
   - ANDROID_KEYSTORE_BASE64
   - ANDROID_KEY_ALIAS
   - ANDROID_KEYSTORE_PASSWORD
   - ANDROID_KEY_PASSWORD

5. Run the workflow named Android production signed release from the main branch. It builds a signed AAB and ARM64 APK, verifies both signatures and the production Internet permission, and uploads the files as Actions artifacts. It does not publish to Google Play automatically.

The workflow refuses to build when the production keystore is missing. Ordinary CI artifacts remain test-only and debug-signed.

## Windows — Authenticode

Obtain a trusted code-signing certificate with its private key in PFX format. Add these secrets to the GitHub production environment:
- WINDOWS_SIGNING_PFX_BASE64
- WINDOWS_SIGNING_PFX_PASSWORD

The Windows production signed release workflow builds the Windows app and installer, signs the executable and installer using SHA-256 plus an RFC 3161 timestamp, verifies the signatures, and uploads the files. The certificate must contain the Code Signing EKU and chain to a trusted certificate authority. A valid signature does not guarantee immediate SmartScreen reputation.

## iOS — Apple distribution

An unsigned simulator build is not a distributable iOS app. Before a signed IPA can be built:
1. Confirm the App Store bundle identifier; the repository currently uses com.athaar.athaar.
2. Obtain an Apple Developer Program account, Apple Distribution certificate in P12 format including its private key, and an App Store provisioning profile whose bundle ID and Team match the project.
3. Add these secrets to the GitHub production environment:
   - IOS_DISTRIBUTION_CERTIFICATE_BASE64
   - IOS_DISTRIBUTION_CERTIFICATE_PASSWORD
   - IOS_PROVISIONING_PROFILE_BASE64
   - IOS_PROVISIONING_PROFILE_NAME
   - IOS_TEAM_ID
   - IOS_BUNDLE_ID
   - IOS_KEYCHAIN_PASSWORD

The current CI iOS Simulator build is unsigned and is not an IPA. The signed iOS workflow still needs to be configured after the Apple team, bundle ID, certificate and profile are available.

## Security requirements

- Never commit JKS, keystore, P12, mobileprovision, passwords, Base64 secrets or API keys.
- Never send signing credentials in chat messages, issue comments, pull requests or logs.
- Keep a secure offline backup of each private key. Loss of an Android upload key or Apple signing identity can block future updates.
- Rotate signing identities only through the relevant platform's official process.
- Store secrets in GitHub Environment secrets, not in repository files or workflow literals.
