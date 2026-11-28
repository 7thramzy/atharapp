# Issue 38 — implementation status and release gates

**Date:** 2026-11-28  
**Branch:** `feat/admin-adhkar-sharing-points`  
**PR:** https://github.com/7thramzy/atharapp/pull/39  
**Tracking issue:** https://github.com/7thramzy/atharapp/issues/38

## Implemented in this branch

### Offline adhkar foundation
- Added an offline seed manifest built only from the project's already checksum-verified Tanzil Uthmani Quran text.
- The initial seed contains Ayat al-Kursi and the complete three Quls (all verses) in morning and evening categories.
- Morning/evening entries have target counts (1 for Ayat al-Kursi, 3 for each Qul), stable IDs, source references and local metadata.
- The import is idempotent and updates seed text without resetting a user's progress or favorite state.
- Added a new library screen with category chips, local repeat counters, progress indicators and favorites.
- Added database metadata and migration support for review state, dataset version and sorting.

**Content boundary:** This is an initial Quranic recitation subset, not a complete Sunnah adhkar collection. No hadith wording has been fabricated or silently imported. Additional morning/evening, post-prayer, sleep and waking adhkar remain gated on exact primary-source text, source references, named grading where applicable, and qualified review. The earlier OpenDua v0.0.4 review remains a conditional research source, not blanket authorization for all underlying texts.

### Local reminders
- Added a timezone-aware daily reminder service for Android and Apple platforms.
- Added user controls for morning/evening reminder times, permission request, enable/disable, cancellation and persisted local preferences.
- Android manifest includes boot rescheduling receivers and the required boot permission; Gradle enables core-library desugaring.
- Reminder state is device-local and works without a cloud account.

**Not the same as admin broadcasts:** Sending an announcement from Athaar administration to all installed devices is not implemented. The repository has no configured backend, authenticated admin roles, push token registry, FCM/APNs sender or delivery audit. This must be built server-side; no sender credentials may be embedded in the mobile app.

### Ayah image sharing
- Added an Arabic RTL share-card renderer with a dark green/gold Islamic visual style.
- Added a share screen for an exact locally stored ayah, with optional user-supplied translation and tafsir text.
- The screen requires a source label when translation/tafsir is included; the app does not invent or silently attach a translation.
- Added share actions from both the downloaded Quran text reader and the selected ayah panel in the Hafs Mushaf.
- Uses in-memory PNG/XFile export and the native share sheet; no persistent user data is uploaded.

### Activity points and achievement sharing
- Added a local idempotent activity event ledger.
- Reading completion earns 1 activity point per exact ayah reference per local day.
- A recorded memorization session earns 5 activity points per exact range per local day.
- Added points summary and an achievement image share card.
- Points are activity markers only. They are not an automated judgement of tajwid, recitation accuracy, memorization correctness or religious merit.

## Automated coverage added

- Database schema test now expects schema v3.
- Added tests for offline seed idempotency and morning/evening grouping.
- Added tests for favorite persistence.
- Added tests for idempotent daily reading points.
- Existing memorization tests now exercise the activity ledger indirectly.

## Validation status

- No successful Flutter CI run has yet been recorded for this feature branch.
- The current Flutter CI workflow previously did not target feature branches or PRs against the `agent/**` base branch. This branch updates its trigger filters so future feature PR pushes run the quality and platform build jobs.
- No physical Android/iOS notification test, native share-sheet test, iPad share popover test, long-ayah image golden test, or screen-reader test has been run yet.
- No production build or release has been created.

## Remaining gates

1. Run Flutter CI on this exact branch head and fix all format, analyzer, test and platform build failures.
2. Physically test local reminders on Android and iOS, including reboot, permission denial, timezone changes and daylight-saving behavior where applicable.
3. Test PNG export/share on Android, iPhone/iPad and web; inspect Arabic shaping, diacritics, clipping and long-text overflow.
4. Have Arabic Quran content reviewed against the approved text source before release; keep the current seed's scope label explicit.
5. Expand the adhkar corpus only from traceable primary sources and qualified review.
6. Select and provision a trusted backend for administrative broadcasts, admin RBAC, device registration, FCM/APNs credentials, opt-outs, rate limits and delivery logs.
7. Complete privacy-policy and production artifact review before release.

**Do not merge or ship this PR until the CI and device gates are satisfied. Do not describe admin push broadcasts or a complete Sunnah adhkar library as shipped.**