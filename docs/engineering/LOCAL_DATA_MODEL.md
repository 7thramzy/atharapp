# Athaar Local Data Model

**Persistence:** Drift + SQLite  
**Scope:** First offline-first implementation  
**Backend:** Not connected; remote synchronization is deferred.

This is the conceptual schema, not generated Drift code. The schema will be refined into migrations and tests during the first database implementation issue.

## Data ownership boundaries

### A. Reference content (read-only to the user)

| Table | Purpose | Key |
|---|---|---|
| quran_surahs | Canonical chapter metadata | surah_number |
| quran_ayahs | Verified Arabic ayah text and structural metadata | (surah_number, ayah_number) |
| adhkar_categories | Versioned categories for curated adhkar | category_id |
| adhkar_items | Curated Arabic wording, target count, and source reference | item_id |

Quran reference data is seeded from an approved dataset. Store dataset version, source, import date, and integrity checksum in an app metadata record. The app must not silently rewrite Quran text.

### B. User-owned local data

| Table | Purpose | Key / constraint |
|---|---|---|
| reading_positions | Last reading location and reading mode | One active record per local profile |
| bookmarks | Saved ayah references and optional folders | UUID; unique verse/folder combination as appropriate |
| verse_notes | User notes attached to an ayah | UUID; verse foreign key |
| verse_highlights | User-selected ayah highlight | UUID or unique verse key |
| memorization_progress | Per-ayah learning/revision state | Unique (surah_number, ayah_number) |
| memorization_sessions | A completed or abandoned memorization session | UUID |
| daily_wird_progress | Optional user-defined daily reading target and completion | Unique (local_date, plan_id) |
| adhkar_progress | User's count for a curated item and local day | Unique (item_id, local_date) |
| app_settings | Locale, theme, reminder preferences, and accessibility settings | Key/value or typed settings table |

### C. Future-only modules

The following are not created in the first database migration:

- Audio recordings or voice profiles.
- AI assessment results.
- Generated reflection tasks.
- Teacher/student sessions.
- Communities and initiative participation.
- Donation cases, payment records, ledger entries, refunds, or disbursements.
- Remote sync outbox and conflict records.

They will receive separate schema reviews when their milestones begin. Do not store recordings by default.

## Quran reference integrity

- quran_surahs.surah_number is in the range 1–114.
- quran_ayahs uses a composite primary key (surah_number, ayah_number).
- Every ayah references an existing surah.
- Dataset validation checks the expected chapter and ayah structure, page/Juz metadata, duplicates, missing keys, empty Arabic text, and checksums.
- Arabic Quran text is preserved exactly as received from the approved source. Search normalization is calculated separately and never written over the canonical field.
- Translation text is a separate data field and must be labelled as a translation of meaning.
- Dataset version changes are explicit and tested; a failed import must not leave a partially updated Quran dataset.

## Memorization model

The initial per-ayah state should remain small and understandable, for example:

- not_started
- learning
- needs_revision
- stable

A session records the selected range, start/end time, session mode, and user-entered or later assessed outcome. It does not imply an AI accuracy score unless an independently validated assessment feature is added.

Progress summaries are derived from local records; avoid storing duplicated counters that can drift from the underlying session history.

## Offline transaction rules

1. A screen reads from a repository backed by Drift, not directly from widgets making SQL calls.
2. Multi-row progress changes run in a Drift transaction.
3. Database schema changes use sequential migrations and migration tests.
4. Reference-data imports are versioned and atomic from the user's perspective.
5. User-created records receive stable UUIDs, timestamps, and deterministic references.
6. Core actions remain usable without network access.
7. Payments, if ever introduced, are never reported as successful until a trusted server verifies the provider event.

## Future sync compatibility

The first release does not implement cloud sync. Nevertheless:

- Keep user-created IDs stable and globally unique.
- Keep timestamps in UTC internally; represent the user's calendar day using the device's configured timezone.
- Separate immutable reference content from mutable user progress.
- Avoid relying on SQLite rowids as cross-device identifiers.
- Before adding sync, define a versioned command/outbox contract, conflict policy per entity, tombstone behavior, retries, and account/device ownership rules.

## Database test requirements

- First-install schema creation.
- Upgrade from every released schema version.
- Foreign-key and uniqueness constraints.
- Atomicity of multi-row writes.
- Quran dataset import rollback on failure.
- Duplicate and missing ayah detection.
- Reading-position persistence after app restart.
- Memorization and adhkar progress persistence with the device offline.
