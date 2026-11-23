# Development and Release Plan

## Cloud-first development workflow

Development is designed to run from a browser. A local Flutter installation is optional.

### GitHub Codespaces

The repository Dev Container uses Ubuntu 24.04, Java 17, Android SDK tooling, and a setup script that downloads Flutter 3.50.0 stable.

On creation it:
1. Installs/validates the pinned Flutter SDK.
2. Accepts Android SDK licenses when the SDK manager is available.
3. Generates Android and iOS native project folders if they are absent.
4. Runs flutter pub get.
5. Generates Drift code with build_runner.

Open the repository in Codespaces and use flutter analyze, flutter test, and flutter run.

### CI

GitHub Actions checks:
- Flutter 3.50.0 / Dart 3.14.
- Android/iOS project scaffolding generation.
- Dependency resolution.
- Drift code generation.
- Dart formatting.
- Flutter static analysis.
- Unit and widget tests.
- Android debug APK build.
- Unsigned iOS debug build on macOS.

### Native platform files

The first Codespaces/CI setup generates missing Android/iOS directories into the working tree. Review and commit these directories and .metadata after confirming the provisional application ID. The current generated identifier is com.athaar.athaar and is not yet verified as available for store registration.

## Store builds

Use Codemagic or an equivalent managed cloud build service for signed release artifacts:
- Android: signed Android App Bundle (.aab) for Google Play.
- iOS: signed archive/IPA and TestFlight distribution.

Cloud builds do not remove the need for physical-device QA. Audio capture, background playback, notifications, permissions, app lifecycle, and offline database behavior must be checked on real devices.

## Dependency lockfile

Flutter resolves package versions with flutter pub get and creates pubspec.lock. Commit the generated application lockfile after the first successful Codespaces/CI resolution so subsequent builds use the same resolved dependency graph.

## Secrets and signing

- Never commit keystores, provisioning profiles, certificates, passwords, API secrets, or backend service keys.
- Store signing material in the chosen build provider's encrypted secret storage.
- Choose and verify final Android application ID and iOS bundle ID before the first store-bound build.
- Use least-privilege tokens and rotate any credential that may have been exposed.

## Release gates

A store submission is blocked until:
- Quran text/data provenance, license, and integrity checks are complete.
- Privacy disclosures accurately describe local storage, recording, and any future upload.
- Every requested permission has a user-facing explanation and is actually needed.
- Accessibility, Arabic RTL, font scaling, and dark/light themes are checked.
- Android and iOS physical-device QA passes.
- App icons, screenshots, descriptions, support contact, and privacy policy are ready.
- Developer accounts and store-specific policy requirements are satisfied.
- Crash reporting and release rollback procedures are defined.

## Backend timing

Supabase is deliberately not configured in this stage. The first product slice must demonstrate a reliable local-only workflow. Backend selection occurs only after data ownership, sync contract, privacy model, and operational costs can be evaluated against real application behavior.
