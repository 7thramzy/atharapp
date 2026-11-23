# Athaar roadmap

## M0 — Repository foundation and source policy

**Status: COMPLETE**

- Independent repository created.
- Starter repositories inspected; selective reuse chosen over a full fork.
- Flutter, Riverpod, Drift, GoRouter, and deferred backend integration recorded.
- Local domain model, roadmap, security, content policy, and agent workflow established.
- Source-level content rights register created; no unapproved media copied.

## M1 — Flutter application shell

**Status: COMPLETE — merged to main (PR #5, commit b0b51e6)**

Implemented and verified on main:
- Flutter 3.50.0 application shell with Arabic-first Material 3.
- Riverpod state, GoRouter navigation, and generated Arabic/English localization.
- Athaar petrol/emerald light/dark theme tokens.
- Drift schema v1 for settings, reading position, and app metadata.
- SQLite persistence tests and basic widget test.
- Codespaces Dev Container and Android/iOS native project bootstrap script.
- GitHub Actions quality, Android debug, and unsigned iOS build jobs.

Remaining M1 gates:
- Resolve and commit pubspec.lock.
- Generate and review Android/iOS platform folders and .metadata.
- Run code generation, format, analysis, all tests, Android debug build, and unsigned iOS build in CI.
- Integrate exact Cairo OFL font file and notice when its asset is ready.
- Confirm provisional package/bundle identifier before first store-bound build.
- Merge only after CI is green and PR review is complete.

## Parallel source review

**Status: READY — independent GitHub issues**

- #2: Tanzil Quran text and Mushaf/UI font rights.
- #3: exact tafsir and translation resource rights.
- #4: recitation provider and per-reciter audio rights.

Research tasks may proceed in parallel with M1. No content binaries may be bundled until the coordinator updates docs/CONTENT_SOURCES.md based on completed dossiers.

## M2 — Quran reader and verified content

**Status: IMPLEMENTED FOUNDATION — verified Tanzil dataset import remains gated.**

- Added Drift v2 tables for Quran surahs/ayahs, source manifest, bookmarks, and private notes.
- Added atomic JSON import with SHA-256 verification, canonical surah/ayah counts, order, uniqueness, and non-empty text checks.
- Added surah navigation, verse reading, search, bookmarks, notes, and last-reading persistence UI.
- Added a source notice and explicit empty state; no fabricated Quran text is bundled.
- Remaining gate: verify the exact Tanzil Uthmani v1.1 download and required notice before importing it; complete physical-device offline/reopen QA.

## M3 — Adhkar and memorization

**Status: IMPLEMENTED LOCAL WORKFLOWS — curated content and scheduled notifications remain gated.**

- Added personal adhkar entries with required source reference and explicit unverified status.
- Added persistent daily local counters.
- Added per-ayah memorization states and range-based revision sessions.
- Added a private impact dashboard derived from actual local activity, without public rankings.
- Remaining gates: independently review each bundled adhkar source and implement/QA user-scheduled local notifications.

## M4 — Audio and recitation support

- First add recording/playback UX and permissions without any server upload.
- Verify allowed recitation streams for named reciters.
- Establish a consented, labelled evaluation set before any model assessment.
- Start with verse/word alignment and obvious omission/repetition detection.
- Measure false positives/negatives; show uncertainty.
- Tajweed assessment requires qualified human evaluation.
- Do not use playback assets as model-training data without separate permission.

## M5 — Guided reflection and trust center

- Use resource-level approved tafsir and hadith/source records.
- Add source citations and review status.
- Clearly distinguish AI-assisted suggestions from reviewed religious content.
- Add correction/report path and visible source details.

## M6 — Mentorship, family, communities and initiatives

- Verified mentor profiles and clear verification status.
- Safe session requests, report/block and moderation.
- Optional family/small-group participation.
- No public worship rankings or pressure-based competition.
- Non-financial initiative participation and evidence.

## M7 — Backend and synchronization

- Reassess Supabase only after local schema and product value are proven.
- Design account/device identity, auth, ownership, RLS, outbox, retries, conflict resolution, backup/export/deletion, and privacy controls.
- Keep local Drift as the offline source; backend is a synchronization layer, not a reason to remove local functionality.
- Payment operations remain separate from user progress sync.

## M8 — Donations and financial accountability

A separate go/no-go gate is mandatory:

- registered/legal operating entity and target-country review;
- payment-provider collection and payout eligibility;
- documented case verification;
- server-confirmed payments and idempotency;
- immutable double-entry ledger and reversal entries;
- separated case approval and disbursement;
- refunds, chargebacks, reconciliation and audit logs;
- transparent reports that protect beneficiary privacy.

## Store release gates

Before Google Play or App Store submission:

- final Quran/resource integrity and rights review;
- public privacy policy and content-source screen;
- Android/iOS permissions justified and documented;
- accessibility, Arabic RTL, font scaling, and theme QA;
- physical-device testing for audio, notifications, offline transitions, and migrations;
- signed Android App Bundle and iOS TestFlight archive;
- support contact, store listing, screenshots, and account/policy requirements.
