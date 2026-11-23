# Athaar Repository Audit

**Audit date:** 2026-11-23  
**Target repository:** [7thramzy/atharapp](https://github.com/7thramzy/atharapp)  
**Audit stage:** Source and repository inspection; no application code copied.

## Executive decision

Athaar will be an independent application. We will not fork either reference repository wholesale.

- Use **Flutter Boilerplate** as an architectural reference for the initial project structure, Riverpod, GoRouter, Drift setup patterns, theme composition, and test organization.
- Use **Quran Offline Mobile** as a selective source-code reference for Quran reading, ayah navigation, Arabic search normalization, bookmarks/notes/highlights, content import patterns, and recitation playback.
- Reimplement the Athaar design system, Arabic-first localization, user-progress model, and all product-specific features.
- Do not copy third-party Quran datasets, tafsir databases, Mushaf page-font bundles, audio, icons, or fonts until their individual usage and redistribution terms are checked.

## Repositories inspected

| Repository | Default branch snapshot | Source license | Role in Athaar |
|---|---|---|---|
| [hndrwn-dk/quran-offline-mobile](https://github.com/hndrwn-dk/quran-offline-mobile/tree/main) | main, commit d184192b4ce44911c96bf4538f0af7e83cd23b2e (2026-11-21) | MIT for application source | Selective Quran module reference |
| [aazirani/flutter_boilerplate](https://github.com/aazirani/flutter_boilerplate/tree/main) | main, commit 774fe212b3b514eee2944ffeacb2e7de6346fe2e (2026-11-09) | MIT for application source | Architecture and app-shell reference |
| [7thramzy/atharapp](https://github.com/7thramzy/atharapp) | main, initial commit fca377c6419a050d93e78db2f856be3fa33c3939 | No project license selected yet | Destination repository |

The Athaar repository initially contained only a short README. The audit therefore did not overwrite any existing application code.

## 1. Quran Offline Mobile

### What is reusable

The repository contains a substantial Flutter Quran application, including:

- Surah, Juz, and Mushaf reading flows.
- Ayah reader widgets and navigation.
- Bookmarks, notes, highlights, and a personal library.
- Arabic search normalization.
- Drift-backed Quran verse storage and JSON-to-database import patterns.
- Per-ayah and background audio playback.
- A large collection of unit and widget tests.

Inspected source paths:

- lib/core/database/database.dart
- lib/core/database/importer.dart
- lib/features/read/
- lib/features/reader/
- lib/features/audio/
- lib/features/library/
- lib/features/search/
- DATA_SOURCES.md
- assets/README.md
- docs/QURAN_TEXT_INTEGRITY.md

### Technical findings

- The inspected pubspec identifies the package as quran_offline, version 1.1.3+78.
- Its declared SDK lower bound is Dart 3.0.
- It uses flutter_riverpod ^2.5.1 and drift ^2.14.1; this is an older dependency baseline than the Riverpod 3 / newer Drift template we inspected.
- The package contains capabilities that are not required for Athaar's first milestone, including home-screen widgets, in-app purchase/review, and platform-specific audio-download features.
- Its Drift database has four tables: Verses, Bookmarks, Notes, and Highlights, with schema version 6.
- It does not provide Athaar's memorization sessions, daily worship plan, user impact model, or offline-to-cloud change journal.
- Its DataImporter uses bundled per-surah JSON files and a SharedPreferences version key. Athaar should keep its dataset version in its own Drift metadata table instead of introducing a second persistence mechanism for core application data.
- Its inspected Arabic substring search loads the complete verse table before matching. We should not copy that strategy unchanged; Athaar should test a normalized indexed/FTS approach against its supported SQLite runtime and fall back safely if FTS is unavailable.

### Important operational limitation

The repository is **not a turnkey Quran dataset**:

- The inspected tree contains 47 asset files.
- The expected assets/quran/s001.json and the complete 604-page QPC V2 font set are not present in that tree.
- The assets documentation expects Quran text, translations, tafsir, transliteration, surah information, and Mushaf resources to be obtained separately.
- No GitHub Actions workflow was present in the inspected tree.

The code can accelerate implementation, but it does not remove the work of acquiring, validating, attributing, and packaging the actual Quran data.

### Decision

**Do not fork the full application.** Adapt only modules that pass a focused code and dependency review. Rebuild the database around Athaar's own schema, preserve the source attribution and MIT license notice for any copied or substantially adapted source, and keep data assets out until their own terms are approved.

## 2. Flutter Boilerplate

### What is reusable

The repository provides a compact Clean Architecture sample with:

- domain, data, and presentation boundaries.
- Riverpod providers and code generation.
- GoRouter navigation.
- Drift database, tables, and DAO test examples.
- Material 3 theme composition, spacing, shapes, typography, and loading/error/empty states.
- Basic localization and RTL helpers.
- GitHub Actions checks and build examples.

Inspected source paths:

- pubspec.yaml
- lib/core/theme/
- lib/data/local/database/
- lib/domain/
- lib/presentation/
- lib/utils/routes/app_router.dart
- lib/utils/locale/app_localization.dart
- .github/workflows/flutter-ci.yml

### Technical findings

- The repository targets Flutter >=3.47.0 and Dart ^3.13.0.
- Its package constraints include Riverpod 3, GoRouter 18, Drift, drift_flutter, code generation, intl, uuid, and get_it.
- The Drift database is an example scaffold with one sample table and schema version 1; it is not an application data model.
- get_it and Riverpod are both present. Athaar will use Riverpod as the single dependency/state-management composition mechanism and will not add a second service locator without a documented need.
- The sample localization delegate supports only en and fa; it is not Arabic-ready as-is.
- The typography implementation references Arabic and other system fonts that are not all bundled in the inspected pubspec. Athaar will explicitly bundle and license its own Arabic UI font.
- The existing purple Material 3 palette does not match Athaar's approved petrol/emerald visual identity.
- The current CI matrix builds several desktop targets in addition to mobile. Athaar's initial checks should focus on formatting, generated code, analysis, tests, and Android/iOS build readiness.

### Decision

Use this repository as an **architectural reference**, not as the Athaar visual product. Reauthor the project shell and theme for Arabic-first usage, remove redundant dependency injection, and keep the testable data/domain/presentation boundaries.

## 3. Athaar repository state

At audit time:

- The destination repository is public and uses main as its default branch.
- It has an initial commit and a placeholder README only.
- It has no Flutter application, dependency manifest, database, assets, backend configuration, or store signing material.

No existing application code was replaced.

## Reuse decision matrix

| Capability | Decision | Notes |
|---|---|---|
| Flutter app structure | Reauthor using Clean Architecture and feature modules | Do not clone a starter wholesale |
| Riverpod | Adopt current Riverpod 3 generation patterns | Confirm actual package versions in CI |
| GoRouter | Adopt | Deep links can be added with feature routes |
| Drift | Adopt as the only local database | Design an Athaar-specific schema |
| Quran reader | Adapt selected widgets and logic | Review dependencies and accessibility |
| Quran content importer | Reimplement the pattern | Add manifest version and integrity checks |
| Arabic search normalization | Candidate for direct adaptation | Add tests and inspect FTS performance |
| Bookmarks/notes/highlights | Reimplement against Athaar IDs and schema | Do not carry old database schema |
| Audio playback | Use just_audio when the audio milestone begins | Keep assessment separate from playback |
| Boilerplate theme | Use architecture patterns only | Create Athaar tokens and typography |
| Boilerplate localization | Reimplement | Arabic-first plus English |
| Adhkar/dua content | Do not copy blindly | Source and license each content dataset |
| Tafsir/translations/fonts/audio | Do not copy until terms are cleared | Each asset has its own conditions |
| AI recitation and reflection | New modules | Require validation and human review |

## Verification limits

This was a source-level GitHub audit. The repository connector allowed file/tree/metadata inspection, but it did not provide a runnable Flutter SDK or native Android/iOS toolchains. No claim is made that either upstream project was rebuilt or tested during this audit. The first Athaar implementation commit must run flutter pub get, code generation, dart format, flutter analyze, and automated tests in CI.
