# Starter repository audit — 2026-11-23

## Decision

Do not fork an upstream application wholesale. Build Athaar independently, using the Flutter Boilerplate architecture as a reference and selectively adapting reviewed Quran reader code when the app foundation is ready.

## Candidate 1 — Quran Offline Mobile

Repository: https://github.com/hndrwn-dk/quran-offline-mobile  
Inspected branch: main  
Inspected commit: d184192b4ce44911c96bf4538f0af7e83cd23b2e  
Application source license: MIT (Copyright Hendrawan, 2025)

### Confirmed useful source modules

- Quran reader and navigation: lib/features/read and lib/features/reader.
- Audio playback: lib/features/audio.
- User library: lib/features/library.
- Search: lib/features/search.
- Local database/importer: lib/core/database/database.dart and importer.dart.
- Large unit/widget test suite.

### Confirmed constraints

- Uses an older Riverpod/Drift dependency baseline than the current Flutter Boilerplate reference.
- Its local database is focused on verses, bookmarks, notes, and highlights; it does not model Athaar memorization sessions, adhkar progress, content provenance, or future sync.
- Its importer expects external per-surah JSON files and tracks its content version via SharedPreferences.
- Its README/DATA_SOURCES.md directs users to separately obtain Quran text, translations, QUL tafsir/surah resources, fonts, and EveryAyah audio.
- The inspected Git tree did not contain the complete expected Quran verse data or all 604 QPC page fonts.
- Its Quran Foundation API reference data cannot simply be copied into a static offline bundle; the current Quran Foundation terms must be followed.
- It includes features/dependencies unnecessary to Athaar's MVP. Copying the entire app would import more complexity than value.

### Decision

Use selected reader/navigation/audio code as a later adaptation candidate. Rebuild database contracts and import pipeline around Athaar. Preserve the upstream MIT notice for any copied/substantial code. Do not copy data assets or fonts without their own rights review.

## Candidate 2 — Flutter Boilerplate

Repository: https://github.com/aazirani/flutter_boilerplate  
Inspected branch: main  
Inspected commit: 774fe212b3b514eee2944ffeacb2e7de6346fe2e  
Application source license: MIT (Copyright Amin Azirani, 2026)

### Confirmed useful patterns

- Feature-oriented Clean Architecture.
- Riverpod provider composition.
- GoRouter.
- Drift database + test database pattern.
- Material 3 theme composition, spacing, shapes and reusable state widgets.
- Basic localization/RTL structure.
- GitHub Actions format/analyze/test/build workflow.

### Confirmed constraints

- Its Drift schema is an example table, not an Athaar domain model.
- It includes GetIt alongside Riverpod; Athaar will not add a second service locator.
- Its sample locale list is not Arabic-first.
- Its purple theme and fonts are not the Athaar identity.
- It has a broad desktop CI matrix that can be narrowed to Android/iOS.

### Decision

Use as an architecture reference, not as the final app design. Reauthor the app shell, Arabic-first localization, Athaar design tokens, and schema.

## Candidate 3 — Sanad

Repository: https://github.com/harounRhim/sanad  
License: AGPL-3.0.

### Decision

Research reference only. Do not copy code or use its model/data assets in the mobile application until a separate license and model/data provenance review is approved.

## Verified reuse rules

- MIT licenses cover the named source code, not third-party data/assets referenced by that code.
- Quran, translations, tafsir, fonts, Mushaf layouts, recitations, and icons each have independent rights records.
- Preserve copyright and license notices for every copied or substantially adapted MIT code portion.
- Record exact upstream commit and file paths in the third-party register before merging the code.
- Do not claim source tests passed unless they have actually been executed in an environment with the required Flutter/native toolchains.
