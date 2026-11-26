# Athaar project status

**Last verified:** 2026-11-27  
**Default branch:** main  
**Current phase:** M2/M3 local-first workflows are implemented. PRs #16, #18 and #20 have been merged to main. Public-release preparation is on `agent/public-release-readiness`; the 604-page map test, offline recitation downloads, production signing pipeline and device validation are still being verified.

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
- No production Android/iOS binary is signed or published yet; the release workflow now supports tag-gated signing after the owner adds platform secrets.
- No Supabase/backend connection has been created.

## Content source decisions

- Tanzil Uthmani v1.1: selected for verbatim offline Arabic Quran text with the required notice and link; exact downloaded file/hash still needs to be recorded before bundling.
- Quran Foundation API content: not selected as a static app bundle.
- QUL: discovery catalogue only; each translation/tafsir/font/audio item requires resource-level review.
- Cairo UI font: OFL 1.1; exact file and notice still to be added.
- KFGQPC Quran font/Mushaf resources: conditional on exact file and official digital-use notice.
- Tafsir and translations: no exact dataset is approved yet.
- Recitations: no MP3 bundle in MVP; provider/reciter rights tasks remain open.


## QCF Hafs Mushaf integration (PR #16)

- Pinned `qcf_quran_plus: 0.1.1` behind an Athaar-owned `HafsRendererAdapter`; no QCF package types leak into the Drift/domain contract.
- Added the 604-page Hafs reader at `/quran/mushaf`, including page jump/navigation, Tajweed toggle, responsive two-page layout, word tap/highlighting, long-press ayah selection, Drift bookmarks, and last-reading-position restore.
- Fonts are loaded page-by-page (current page + next page); the all-pages `setupFontsAtStartup` helper is not called.
- CI run [45471585911](https://github.com/7thramzy/atharapp/actions/runs/45471585911) passed source acquisition, static analysis, all tests, Android debug build, unsigned iOS simulator build, Windows release/installer, and generated-source persistence.
- Android debug APK measured **251,830,435 bytes (240.16 MiB)**. This is a large debug build; release packaging and size optimization review is still required.
- Physical-device visual QA and full 604-page mapping verification are not yet complete. The integration is on PR #16 and has not been merged to main.

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


## Public release integration snapshot (2026-11-27)

- PR #16 (QCF Hafs reader), PR #18 (approved mobile visual design), and PR #20 (ayah study, tafsir, translations, streaming and ASR evaluation harness) were merged to `main` in that order.
- Vercel Preview deployments were disabled for the `athaar-preview` project to avoid automatic preview deployments. GitHub Actions CI remains active.
- Release branch `agent/public-release-readiness` adds the About/source-credit screen, production Android INTERNET permission, removes stale test download URLs, clarifies the privacy notice without publishing a full privacy policy, and introduces native app-private offline surah audio downloads with stream fallback.
- A new automated test compares every QCF page range to the page assignment on every Tanzil ayah (6,236 ayahs across 604 pages). This is an acceptance gate; do not claim a complete match until CI passes.
- The About screen distinguishes Tanzil's verbatim Uthmani text from QCF's page renderer. MIT covers the QCF package code; exact rights for the bundled QCF fonts/page data remain separately unverified and must be resolved before public redistribution.
- AlQuran Cloud offline downloads are limited to user-requested private app storage for personal/educational use, with deletion and no upload/rehosting/export/model training. Re-check terms and reciter edition rights before launch.
- Production signing pipelines are tag-gated for Android AAB/APK, iOS App Store IPA, and Windows installer/EXE. They require owner-managed GitHub Actions secrets and have not been run with the actual production certificates yet.
- A full public privacy policy remains deferred at the product owner's request; it is still a mandatory gate before a public store release.
