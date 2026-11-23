# Athaar project status

**Last verified:** 2026-11-24  
**Default branch:** main  
**Current phase:** M2 and M3 local-first workflows implemented; verified content import and device QA remain open.

## Completed on main

- M1 Flutter foundation merged through PR #5; CI passed quality, Android debug, and unsigned iOS build jobs.
- M2 reader/search/bookmark/note/import foundation and M3 local adhkar/memorization/personal-impact workflows added.
- Drift schema upgraded to v2 with a migration path and local feature tables.
- Independent Athaar repository and initial product/engineering documents.
- Source-level audit of Quran Offline Mobile and Flutter Boilerplate.
- Selective-reuse decision; no full upstream app fork.
- Flutter + Riverpod + GoRouter + Drift/SQLite architecture.
- Backend integration deferred until after the local MVP.
- Content-source policy and parallel-agent workflow.
- GitHub issues #1–#4 created for M1 and independent content-rights reviews.

## M1 implementation

Merged to main through PR #5. CI run 45259877678 passed all four jobs.
- Flutter package manifest with Flutter 3.50.0 / Dart 3.14 compatibility.
- Riverpod, GoRouter, Drift, and generated localization wiring.
- Arabic-first home screen and settings screen with English switching.
- Athaar light/dark color scheme.
- Drift schema v1: local settings, reading position, app metadata.
- Database repository and persistence tests.
- GitHub Codespaces Dev Container setup and native platform bootstrap script.
- GitHub Actions format/analyze/test plus Android and unsigned iOS build jobs.

## M1 validation state

- GitHub Actions run 45259877678 passed formatting, static analysis, tests, Android debug build, unsigned iOS build, and generated-source persistence.
- Cairo font binary is not bundled; system Arabic fallback is used pending the exact OFL asset and notice.
- No Android/iOS binary is signed or published.
- No Supabase/backend connection has been created.

## Content source decisions

- Tanzil Uthmani v1.1: selected for verbatim offline Arabic Quran text with the required notice and link; exact downloaded file/hash still needs to be recorded before bundling.
- Quran Foundation API content: not selected as a static app bundle.
- QUL: discovery catalogue only; each translation/tafsir/font/audio item requires resource-level review.
- Cairo UI font: OFL 1.1; exact file and notice still to be added.
- KFGQPC Quran font/Mushaf resources: conditional on exact file and official digital-use notice.
- Tafsir and translations: no exact dataset is approved yet.
- Recitations: no MP3 bundle in MVP; provider/reciter rights tasks remain open.

## Active GitHub work

- #1 M1: Flutter app shell, Arabic RTL, Drift, Codespaces and CI.
- #2 Quran text and Mushaf font rights dossier.
- #3 Tafsir and translation rights dossier.
- #4 Recitation audio rights dossier.

## M2/M3 acceptance gates

- Verify the exact Tanzil Uthmani v1.1 file SHA-256 and required attribution notice before importing the text.
- Complete independent review of adhkar sources before shipping a curated pre-populated catalog; user-entered entries remain explicitly unverified.
- Implement and physically test user-scheduled local reminders.
- Run CI on the latest main commit and complete Arabic RTL, accessibility, offline, and migration QA.
