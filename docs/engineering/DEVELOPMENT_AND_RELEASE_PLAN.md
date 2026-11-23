# Development and Release Plan

## Cloud-first development workflow

The development environment is designed to work from a browser. A local Flutter installation is optional, not a prerequisite for the first code milestones.

### Development

1. Open 7thramzy/atharapp in GitHub Codespaces.
2. Use a repository Dev Container to install a pinned Flutter/Dart toolchain.
3. Run dependency installation and code generation in the Codespaces terminal.
4. Edit code through the browser-based VS Code environment.
5. Push a feature branch and open a pull request.
6. Let GitHub Actions run the quality gates.

The Dev Container version must match the Flutter/Dart versions used in CI. Pin tool versions and dependency lockfiles instead of following an unbounded latest channel.

### Continuous integration

Initial GitHub Actions checks:

- Flutter/Dart toolchain setup with caching.
- flutter pub get.
- dart format --output=none --set-exit-if-changed lib test.
- dart run build_runner build --delete-conflicting-outputs.
- flutter analyze.
- flutter test.
- Android debug build as an early platform smoke test.

Do not build desktop targets in the initial mobile-only matrix. Add iOS simulator/build validation on a macOS runner when the first platform folders exist.

### Store builds

Use Codemagic or an equivalent managed cloud build service for signed release artifacts:

- Android: signed Android App Bundle (.aab) for Google Play.
- iOS: signed archive/IPA and TestFlight distribution.

Cloud builds do not remove the need for physical-device testing. Audio capture, background playback, notifications, permissions, app lifecycle, and offline database behavior must be checked on real devices.

## Secrets and signing

- Never commit keystores, provisioning profiles, certificates, passwords, API secrets, or backend service keys.
- Store signing material in the chosen build provider's encrypted secret storage.
- Keep debug and release application identifiers distinct when needed.
- Choose the final Android application ID and iOS bundle ID before the first store-bound build; verify ownership and availability.
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

Supabase is deliberately not configured in this stage. The first product slice must demonstrate a reliable local-only workflow. The backend is selected only after the data ownership, sync contract, privacy model, and operational costs can be evaluated using real application behavior.
