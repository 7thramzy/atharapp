# Parallel agent work board

**Coordinator:** project owner / integration lead  
**Board rule:** only the coordinator edits this shared file. Agents claim work on the corresponding GitHub issue and maintain a unique handoff file.

## Active work

| ID | GitHub issue | Workstream | Status | Owner | Branch / reserved paths | Dependencies |
|---|---|---|---|---|---|---|
| M1 | [#1 Application shell](https://github.com/7thramzy/atharapp/issues/1) | Flutter shell, Arabic RTL, design tokens, Riverpod, Drift bootstrap, CI | ACTIVE | Integration lead | agent/integration/1-flutter-shell; app bootstrap, pubspec, localization, router, Drift root, CI, tests | None |
| SRC-A | [#2 Quran text and Mushaf fonts](https://github.com/7thramzy/atharapp/issues/2) | Rights dossier for Tanzil and official Mushaf/UI fonts | READY | Unclaimed | docs/content-reviews/quran-text.md; docs/content-reviews/mushaf-fonts.md | None |
| SRC-B | [#3 Tafsir and translations](https://github.com/7thramzy/atharapp/issues/3) | Exact-resource licenses for tafsir and translations | READY | Unclaimed | docs/content-reviews/tafsir-translations.md | None |
| SRC-C | [#4 Recitations and audio](https://github.com/7thramzy/atharapp/issues/4) | Provider and per-reciter rights for streaming/download/offline use | READY | Unclaimed | docs/content-reviews/recitations.md | None |

## Newly approved execution priority (2026-11-28)

| ID | GitHub issue | Workstream | Status | Owner | Branch / reserved paths | Dependencies |
|---|---|---|---|---|---|---|
| P0-QURAN | [#26 Mushaf ordering and 604-page integrity](https://github.com/7thramzy/atharapp/issues/26) | Reproduce and diagnose reported ordering/rendering symptom; full page-map, golden, rights, and device/performance QA | READY | Unclaimed | agent/quran/26-mushaf-integrity; initially lib/features/quran/** and test/features/quran/**; shared QCF dependency/adapter contract changes require coordinator approval | Latest main; approved execution plan; D-015 |

The owner-approved phased product requirements are in [APPROVED_PRODUCT_AUDIT_AND_EXECUTION_PLAN.md](../engineering/APPROVED_PRODUCT_AUDIT_AND_EXECUTION_PLAN.md). P0-QURAN is the next execution priority. P1–P4 must be split into bounded issues after P0 findings and dependencies are known; they are not considered implemented or active. Do not start overlapping agents until each issue has an explicit claim and path reservation.

## Planned after M1

| ID | Workstream | Status | Proposed owner | Reserved paths | Dependency |
|---|---|---|---|---|---|
| M2-QDB | Quran dataset importer, version manifest, integrity tests | PLANNED | Quran data agent | tooling/content/quran/**; dataset import tests | M1 + SRC-A approved |
| M2-QUI | Quran reader, surah navigation, search, bookmarks, notes | PLANNED | Quran feature agent | lib/features/quran/**; feature-local tests | M1 + DB contract |
| M3-ADH | Adhkar catalog, counter, local reminders | PLANNED | Adhkar feature agent | lib/features/adhkar/**; feature-local tests | M1 + approved adhkar sources |
| M3-MEM | Memorization sessions and revision progress | PLANNED | Learning feature agent | lib/features/memorization/**; feature-local tests | M1 + DB contract |
| M3-IMPACT | Private personal impact summary | PLANNED | Profile/impact agent | lib/features/personal_impact/** | M2-QUI + M3-MEM |
| M4-AUDIO | Audio capture and recitation-assessment research | BLOCKED | Audio research agent | docs/audio-evaluation/**; later lib/features/audio_assessment/** | SRC-C rights + labelled evaluation protocol |
| M5-REFLECT | Source-grounded reflections and human review | PLANNED | Content/review agent | lib/features/reflections/**; review fixtures | Approved tafsir/reference sources |
| M6-COMM | Mentorship, safe groups and initiatives | PLANNED | Community agent | lib/features/mentorship/**; communities/**; initiatives/** | Auth/sync design + safeguarding review |
| M7-DON | Donation system and financial controls | BLOCKED | Financial systems lead | docs/finance/**; future backend module | Legal operator + provider eligibility + ledger design |

## Reservation protocol

1. Agent comments on its issue with agent ID, branch, exact paths, and base commit.
2. Coordinator checks for conflicts and sets the board row to ACTIVE with owner and branch.
3. Agent works only on its reserved paths.
4. Agent opens a PR and adds its handoff file.
5. Coordinator sets the row to REVIEW, verifies checks, then MERGED or BLOCKED.
6. After merge, coordinator updates the project status and frees paths.

## Current coordination notes

- M1 and SRC-A/SRC-B/SRC-C are independent and may run in parallel.
- Research agents must not edit docs/CONTENT_SOURCES.md, README.md, docs/STATUS.md, AGENTS.md, or the board. They deliver separate dossiers; the coordinator reconciles approved results into the shared registry.
- The database owner is the sole editor of database root/schema/migration files.
- The integration lead is the sole editor of shared package/config/router files unless a reservation explicitly transfers ownership.
- No agent is considered active until a claim is recorded on its GitHub issue.
