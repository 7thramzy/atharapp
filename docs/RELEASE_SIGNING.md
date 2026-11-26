# Athaar production signing and release procedure

**Last reviewed:** 2026-11-27  
**Default branch:** main  
**Release trigger:** a protected, reviewed Git tag matching `v*`

This document records the release signing pipeline and the credentials that must be supplied by the repository owner. The GitHub workflow contains no private certificates or signing passwords. They must be added manually as encrypted GitHub Actions repository secrets.

## 1. General safety rules

- Do not commit Android keystores, Apple certificates, provisioning profiles, Windows PFX files, password files, or base64 copies.
- Do not paste passwords, certificate contents, provisioning profiles, or signing material into chat, issues, pull requests, workflow logs, or source files.
- Keep the original signing materials in at least two encrypted backups under the account owner's control.
- If a signing secret is exposed, revoke/rotate the certificate or key where possible and update the corresponding GitHub secret.
- Do not create a public release tag until the code, asset rights, page-map integrity, device tests, and store identity are approved.

## 2. Android — signed AAB and APK

The repository contains `tooling/release/create_android_upload_keystore.sh`. Run it in a trusted local shell with a supported JDK installed. It prompts locally for the key passwords and creates:

- `android/app/upload-keystore.jks` — private upload keystore.
- `android/athaar-upload-keystore.base64` — encoded copy used only to add the GitHub secret.

The root `.gitignore` and `android/.gitignore` exclude signing material.

In GitHub repository Settings → Secrets and variables → Actions, create these repository secrets:

| Secret | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Entire contents of the generated base64 file |
| `ANDROID_STORE_PASSWORD` | Keystore password entered into keytool |
| `ANDROID_KEY_ALIAS` | `athaar-upload` |
| `ANDROID_KEY_PASSWORD` | Private-key password entered into keytool |

A tag push will then create an Android App Bundle and a universal APK, verify their signatures, and upload both as a GitHub Actions artifact. Regular branch CI builds remain debug-signed test packages only; never distribute those as production releases.

The current application ID is `com.athaar.athaar`. Confirm that it is the intended permanent identifier and is available/owned in the relevant store account before registering the first public release. Do not change it after an app has been published.

## 3. iOS — App Store Connect IPA

The tagged workflow expects all of the following:

| Secret | Required content |
|---|---|
| `IOS_DISTRIBUTION_P12_BASE64` | Base64-encoded Apple Distribution certificate exported as a password-protected P12 |
| `IOS_DISTRIBUTION_P12_PASSWORD` | Password used for the P12 export |
| `IOS_PROVISIONING_PROFILE_BASE64` | Base64-encoded App Store provisioning profile for the exact bundle ID |
| `IOS_TEAM_ID` | Apple Developer Team ID |

The profile must match bundle ID `com.athaar.athaar`, the selected Apple Developer team, and App Store distribution. The workflow imports the certificate into an ephemeral macOS keychain, installs the profile, archives the iOS app, exports an IPA, and uploads it as an artifact. The current non-tag CI build is an unsigned simulator build only.

The user/account owner must hold a suitable Apple Developer membership and create the certificate/profile. A successful simulator build is not proof that App Store distribution is configured.

## 4. Windows — Authenticode-signed installer and executable

The tagged Windows workflow expects:

| Secret | Required content |
|---|---|
| `WINDOWS_SIGNING_PFX_BASE64` | Base64-encoded PFX containing a valid code-signing certificate and private key |
| `WINDOWS_SIGNING_PFX_PASSWORD` | PFX export password |

The workflow signs the application executable and the generated installer with SHA-256 and an RFC 3161 timestamp, then verifies the signatures. Non-tag branch builds remain unsigned test artifacts.

A self-signed certificate does not establish public publisher trust. Choose a certificate and distribution route appropriate to the intended Windows audience before release. The portable ZIP is a package archive; the signed EXE is the installer/executable.

## 5. Tag-gated build flow

After release review and version update:

1. Merge the tested release branch into `main`.
2. Ensure all signing secrets for the platforms being released are present.
3. Create a protected release tag such as `v0.3.0` on the approved main commit.
4. The tagged workflow builds and verifies the signed Android, iOS and Windows artifacts.
5. Verify the certificate identity, bundle/application ID, version, install/upgrade behavior, hashes, and artifact contents before publishing to the stores.
6. Upload through the appropriate store process only after legal/content/privacy review and store metadata are ready.

Tagging is a build trigger, not an automatic store submission. The current workflow uploads artifacts to GitHub Actions; it does not submit an app to Google Play, Apple App Store, or Microsoft Store.

## 6. Remaining manual gates

- Configure the GitHub Actions secrets above; secret-management operations are deliberately not performed by source-code commits.
- Complete physical-device install/upgrade tests on Android and iOS and clean-machine Windows installer tests.
- Review the exact certificate identity and test signatures on each target platform.
- Confirm package/bundle ID ownership, store eligibility, developer-account status, store metadata, and release policy requirements.
- A full public privacy policy is intentionally deferred per the product owner's instruction, but it remains a required gate before public store distribution.
- Obtain and preserve source/redistribution evidence for the exact QCF font and page-data assets. The MIT licence of `qcf_quran_plus` package code is not treated as an automatic licence for every bundled third-party font or page-data binary.
- Reconfirm recitation provider terms and selected reciter editions at launch.
- Do not claim that AI recitation assessment or Tajweed scoring is included: the ASR model remains an isolated research candidate.

## 7. Local verification checklist

Before pushing release signing changes, run:

```bash
flutter pub get
dart run build_runner build
dart format lib test
flutter analyze --fatal-infos
flutter test
```

Then inspect the generated merged Android release manifest for `android.permission.INTERNET`, verify the final APK/AAB signatures, and inspect the iOS archive and Windows signatures from the tag workflow.
