# Athaar project status

**Last verified:** 2026-11-23  
**Default branch:** main  
**Current phase:** M0 documentation/foundation complete; M1 ready; no application code implemented yet.

## Completed and verified in GitHub

- Created independent repository: https://github.com/7thramzy/atharapp
- Inspected Quran Offline Mobile and Flutter Boilerplate at source level.
- Selected selective code reuse; rejected a whole-app fork.
- Chosen Flutter + Riverpod + GoRouter + Drift/SQLite for the mobile client.
- Deferred Supabase/backend connection until after the local MVP.
- Added repository audit, architecture decisions, local data model, licensing register, MVP scope, development/release plan and security governance under docs/engineering.
- Added canonical project documents, agent instructions, parallel workflow, file ownership rules, handoff template, and work board.
- Updated content-source policy with the initial Tanzil offline text decision and individual license gates for tafsir, translations, fonts, and recitations.
- Created M1 issue #1 and parallel rights-review issues #2, #3, and #4.

## Content-source decisions

- Tanzil Uthmani v1.1: selected for verbatim offline Quran text, provided the text remains unchanged and required attribution/notice/link are preserved. Exact source file, options, and checksum still need to be captured before import.
- Quran Foundation API content: not selected as a static bundled database; its terms impose retention/sync and redistribution restrictions.
- QUL: discovery/download catalogue only; each individual resource needs its own license review.
- Cairo UI font: OFL 1.1; include license and notice.
- KFGQPC Quran font/Mushaf assets: official digital-use source selected conditionally; exact file and usage statement must be recorded before bundling.
- Tafsir and translation content: no exact resource is approved yet.
- AlQuran Cloud/Islamic Network audio: conditional streaming/educational use; no bundled MP3 in MVP and no commercial/donation-mode assumption without rights clarification.
- EveryAyah: blocked until recording-specific rights are documented.
- Sanad AGPL-3.0: research reference only, not app code to copy.

## Active GitHub work

- #1 M1: Flutter application shell, Arabic RTL, Riverpod, Drift, Codespaces and CI.
- #2 Content review A: Quran text and Mushaf fonts.
- #3 Content review B: tafsir and translation rights.
- #4 Content review C: recitation audio and per-reciter rights.

M1 and content research issues are independent and can proceed in parallel when separate agents claim disjoint paths.

## Not implemented / not verified

- Flutter application source and platform folders.
- Drift schema, migrations, or generated code.
- Codespaces Dev Container and GitHub Actions workflow.
- Quran text import or binary assets.
- UI, audio capture, AI, or notification functionality.
- Supabase, authentication, cloud synchronization, or payment provider.
- Android/iOS signed builds, TestFlight, Google Play upload, or App Store submission.
- Flutter commands, CI, emulator tests, or physical-device tests have not yet run for Athaar.

## Next action

Implement M1 from issue #1. In parallel, complete issues #2–#4 as isolated source-rights dossiers. The coordinator reconciles approved results into docs/CONTENT_SOURCES.md before any religious content is added to the app.
