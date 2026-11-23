# Athaar project status

**Last verified:** 2026-11-23  
**Default branch:** main  
**Current phase:** M1 implementation in progress on agent/integration/1-flutter-shell. No M1 changes have been merged to main yet.

## Completed on main

- Independent Athaar repository and initial product/engineering documents.
- Source-level audit of Quran Offline Mobile and Flutter Boilerplate.
- Selective-reuse decision; no full upstream app fork.
- Flutter + Riverpod + GoRouter + Drift/SQLite architecture.
- Backend integration deferred until after the local MVP.
- Content-source policy and parallel-agent workflow.
- GitHub issues #1–#4 created for M1 and independent content-rights reviews.

## M1 implementation branch

Branch: agent/integration/1-flutter-shell

Implemented in the branch (pending CI and review):
- Flutter package manifest with Flutter 3.50.0 / Dart 3.14 compatibility.
- Riverpod, GoRouter, Drift, and generated localization wiring.
- Arabic-first home screen and settings screen with English switching.
- Athaar light/dark color scheme.
- Drift schema v1: local settings, reading position, app metadata.
- Database repository and persistence tests.
- GitHub Codespaces Dev Container setup and native platform bootstrap script.
- GitHub Actions format/analyze/test plus Android and unsigned iOS build jobs.

## M1 validation state

- Flutter commands have not yet been executed in this assistant environment.
- GitHub Actions has not yet reported a passing run for this branch.
- Generated Drift code and native Android/iOS platform folders are produced by the Codespaces/CI setup scripts, not checked in yet.
- pubspec.lock is generated during dependency resolution and must be committed after the first successful resolver run.
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

## Next actions

1. Run M1 GitHub Actions on the pull request and fix all toolchain/analyzer/test/build failures.
2. Resolve and commit pubspec.lock; review generated Android/iOS project folders and finalize the provisional app identifier before store preparation.
3. Merge M1 only after CI is green and the handoff is complete.
4. Continue content-rights reviews #2–#4 in parallel.
5. Start Quran content import only after the exact source and file hash have been recorded and approved.
