# Issue 38 handoff — admin notifications, adhkar, and sharing

**Date:** 2026-11-28  
**Branch:** `feat/admin-adhkar-sharing-points`  
**Tracking issue:** https://github.com/7thramzy/atharapp/issues/38  
**Status:** source review completed; application implementation not yet complete.

## Verified existing architecture

- Local-only Drift/SQLite persistence is already used; no Athaar backend, cloud auth, FCM/APNs sender, or admin RBAC service is configured.
- Existing schema has `adhkar_categories`, `adhkar_items`, and `adhkar_progress`, but the item shape stores only one Arabic text field, target count, one source string, and a boolean source flag. It cannot faithfully represent source versions, variations, ordered recitation/instruction blocks, item references, and review records.
- Existing adhkar screen supports manually adding a personal text and incrementing its local count. It does not provide a curated library, category navigation, search, favorites, or a reviewed daily wird.
- The settings notification row is a placeholder dialog.
- Memorization sessions and private impact summaries exist locally. They are not a validated recitation assessment engine and do not currently establish a score for recitation correctness.
- No image export/share dependency or share-card rendering workflow was found in the current app dependency manifest.
- Existing project content rules prohibit bundling content without exact source and rights records.

## Work completed in this branch

- Added `docs/content-reviews/opendua-v0.0.4.md` with pinned-source, CC BY 4.0 boundary, attribution, scholarly-review limitations, and a safe import decision.
- OpenDua v0.0.4 is a conditional candidate, not an approved religious-content corpus. Its public methodology and changelog make clear that source references and reported gradings are preserved, but the dataset must not be described as scholarly-certified by Athaar.
- Audio is intentionally excluded from the first content import.
- No unverified adhkar have been inserted into production tables.

## Implementation plan and ownership boundaries

1. **Content lane:** obtain exact pinned catalogue bytes in the build environment, calculate SHA-256/byte count, preserve licence/attribution, build a parser preserving entries, variations and ordered blocks, then human-review the morning/evening and post-prayer subsets. Do not mark content verified before review.
2. **Database lane:** dedicated schema migration for source/version metadata, categories, entry/dua IDs, variations, ordered blocks, references, review state, and favorites. Do not flatten multi-step content into the current single text field.
3. **Adhkar UI lane:** category filters, search, morning/evening/post-prayer/sleep/waking collections, repeat counters, favorites, daily progress, and offline-first data loading.
4. **Notifications lane:** implement local reminders only after selecting and testing a maintained Flutter notifications plugin, with permission UX, timezone-safe schedules, quiet hours and preferences. Administrative push announcements require a server-side service, authenticated admin RBAC, FCM/APNs credentials kept server-side, and auditable delivery logs. Do not fake remote admin delivery in a client-only app.
5. **Ayah share lane:** add a renderer/export service with a preview screen, font/RTL/diacritic tests, licensed translation/tafsir source metadata, multi-card overflow for long passages, and explicit user action before file/share output.
6. **Achievement/points lane:** derive points from idempotent local event records with a versioned transparent rule set. Reading completion and a user-recorded memorization session may count as activity, but never as proof of correct recitation. Provide share preview and default-hide personal identity.
7. **QA lane:** database migration tests, parser fixtures, content reference review, offline tests, Android/iOS permission tests, timezone tests, duplicate-event tests, and image golden tests for short/long Arabic passages.

## Blocking dependencies / honest scope

- The repository has no configured server/backend; admin broadcast push cannot be completed securely as a client-only feature.
- Exact OpenDua catalogue bytes have not yet been committed or checksummed in the repository; no claim is made that all 267 entries have been imported.
- The current database schema requires a migration before faithful full-catalogue import.
- No physical-device notification or image export test has been run.
- No points have been assigned for recitation correctness.

**Do not close issue #38 or call the features shipped until code, migrations, tests, source review, and backend/device gates are complete.**