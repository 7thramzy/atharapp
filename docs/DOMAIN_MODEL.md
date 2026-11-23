# Athaar domain model

This document defines the concepts and boundaries for the offline MVP. It is not a mandate to create every table in one migration.

## 1. Content provenance

### ContentSource

Represents the provider or publisher of a resource.

Fields:
- source_id
- display_name
- canonical_url
- source_type
- trust/review status
- last_checked_at

### ContentResource

Represents one exact edition or downloadable asset.

Fields:
- resource_id
- source_id
- resource_type: quran_text / translation / tafsir / adhkar / font / mushaf_layout / recitation / metadata
- title
- author_or_rights_holder
- language
- edition/version
- canonical_resource_url
- file_name and SHA-256 when a file is acquired
- license_identifier
- license_url or written-permission reference
- required_attribution
- allowed_uses
- prohibited_uses
- review_status: approved / conditional / research_required / blocked
- reviewed_at and reviewer

A provider is not the same thing as a resource. One QUL source can expose multiple resources whose licenses differ.

### ContentManifest

A versioned manifest controls local seed data.

Fields:
- manifest_version
- resource_id
- resource_version
- source_file_hash
- import_schema_version
- retrieved_at
- attribution_key
- integrity_status

A changed hash, edition, license, or source requires a new review before shipping an updated asset.

## 2. Quran reference data

### QuranSurah

- surah_number: 1..114
- Arabic name
- optional approved translation of the name
- revelation metadata only where its source is recorded

### QuranAyah

- composite key: surah_number + ayah_number
- canonical Arabic Uthmani text
- optional approved structural metadata (juz/page/hizb/ruku)
- resource_id and manifest version

Canonical Arabic text is immutable. Search normalization is separate and is not used for display.

## 3. Local user data

### LocalProfile

The initial app can operate without account registration. A local profile is a device-local owner namespace used to separate data if the app later supports profiles.

### ReadingPosition

- profile_id
- surah_number
- ayah_number or page
- reading_mode
- updated_at

### Bookmark

- stable UUID
- profile_id
- surah_number
- ayah_number
- optional folder/color
- created_at

### VerseNote

- stable UUID
- profile_id
- verse reference
- note_text
- created_at
- updated_at

### VerseHighlight

- stable UUID
- profile_id
- verse reference
- color
- created_at

### MemorizationProgress

- profile_id
- verse range or per-ayah reference
- state: not_started / learning / needs_revision / stable
- last_practiced_at
- optional self-assessment

### MemorizationSession

- stable UUID
- profile_id
- selected range
- started_at
- ended_at
- session_mode
- user-entered outcome
- no AI confidence unless a validated assessment feature has separately been approved

### DailyWirdPlan and DailyWirdProgress

The user-defined daily target and local completion record. The app must not infer religious merit or compare people.

### AdhkarCategory and AdhkarItem

Curated content records with exact wording, source, language, and attribution. Each item needs its own content-source approval.

### AdhkarProgress

Local day, item, count, and completion state. Timezone/calendar handling must be explicit.

### AppSettings

Locale, theme, font scaling, reminder schedule, accessibility, privacy, and optional notification preferences.

## 4. Future modules (not part of the initial schema)

- AudioRecordingSession and AssessmentResult.
- Reflection and reviewed reference records.
- MentorProfile and MentorshipSession.
- Community, membership, group goals, and moderation reports.
- Initiative, volunteer task, and participation evidence.
- DonationCase, Payment, LedgerEntry, Refund, Disbursement, and Reconciliation.

Do not create these future tables until the corresponding milestone is ready and its security model is reviewed.

## 5. Future synchronization

All user-created records need stable UUIDs and explicit owner/device scope. Before sync is implemented, define:

- outbox operation ID and idempotency key;
- retry/backoff;
- entity-specific conflict resolution;
- deletion tombstones;
- account/device transfer;
- export, deletion, and restore semantics.

Do not rely on SQLite rowids as globally stable identifiers. The server, if added, becomes the authority for payments and shared community state, not for locally available reading progress.
