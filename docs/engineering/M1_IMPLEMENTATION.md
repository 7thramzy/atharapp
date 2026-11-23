# M1 — Flutter application shell

## Scope

M1 establishes the runnable Android/iOS Flutter foundation for Athaar. It does not implement Quran content, audio assessment, AI, communities, payments, cloud accounts, or Supabase.

## Toolchain and packages

- Flutter 3.50.0 stable; bundled Dart 3.14.0.
- Riverpod 3.5.x for application state and dependency composition.
- GoRouter 18.1.x for navigation.
- Drift 2.35.x + drift_flutter 0.3.x for the only local persistence layer.
- drift_dev/build_runner for generated database code.
- Flutter generated localization support with Arabic first and English second.

Flutter 3.50.0 is pinned in GitHub Actions and Codespaces. The Flutter SDK is not installed on the user's desktop.

## Included in this milestone

- App shell and initial home/settings screens.
- Arabic-first RTL and English locale switching.
- Athaar light/dark theme tokens.
- Local preferences and last-reading position schema in Drift.
- Database initialization metadata and version 1 migration baseline.
- SQLite file-backed persistence tests.
- Codespaces development container and mobile platform generation script.
- GitHub Actions quality checks and Android/iOS unsigned build checks.

## Local database

The file lib/core/database/app_database.dart defines:

- LocalSettings: app language and theme.
- ReadingPositions: singleton last-reading record.
- AppMetadata: small key/value records such as the local schema version.

User preferences and reading position use a stable singleton key in this first schema. New domain tables must be added through an explicit Drift migration and migration tests.

The local settings repository is designed as a data boundary. Feature screens should not issue SQL directly.

## Run in GitHub Codespaces

1. Open the repository on GitHub.
2. Choose Code → Codespaces → Create codespace on the agent/integration/1-flutter-shell branch while M1 is under review.
3. Wait for the Dev Container post-create setup to finish.
4. Run flutter analyze, flutter test, and flutter run.

The setup downloads the pinned Flutter SDK, uses the Android SDK feature, creates missing Android/iOS native project folders in the workspace, resolves packages, and generates Drift code.

The generated Android/iOS platform folders and .metadata appear as new workspace files on first setup; review and commit them before relying on later native build or store release workflows. The application identifiers are provisional (com.athaar.athaar) and must be checked before the first store upload.

## Important limits

- The exact Cairo font binary is not bundled in this commit. assets/fonts/README.md records the required OFL notice/hash process. Until the font asset is added, the operating system's Arabic fallback font is used. Runtime font downloading is deliberately disabled.
- Quran Arabic text and KFGQPC script-font binaries are not bundled by M1. The content review issues must be completed before those files enter the app.
- pubspec.lock is created by the first flutter pub get in Codespaces/CI; commit the resolved app lockfile before accepting the first production-bound release.
- The iOS CI build is unsigned. Store signing and TestFlight distribution require Apple Developer credentials and Codemagic or an equivalent macOS signing environment.
- No Android APK/AAB or iOS IPA has been published by this milestone.

## Validation commands

Run from the repository root:

- flutter pub get
- dart run build_runner build --delete-conflicting-outputs
- dart format --output=none --set-exit-if-changed lib test
- flutter analyze --fatal-infos
- flutter test
- flutter build apk --debug
- flutter build ios --debug --no-codesign (macOS only)
