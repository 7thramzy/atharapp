# Athaar architecture

## Product direction

Athaar is an independent Flutter mobile application for Android and iOS. The first release focuses on Quran reading, adhkar, personal learning, and offline progress. Mentorship, communities, initiatives, and donations are later modules with separate privacy and governance reviews.

## Core architecture

- **Presentation:** Flutter + Material 3, Arabic-first RTL, responsive mobile layout.
- **State and dependency composition:** Riverpod only.
- **Navigation:** GoRouter.
- **Local persistence:** Drift + SQLite, with sequential schema migrations.
- **Backend:** deliberately deferred. No Supabase or Laravel dependency in the foundation/MVP.
- **Development:** GitHub Codespaces and repository Dev Container.
- **CI:** GitHub Actions.
- **Signed mobile artifacts:** Codemagic or equivalent cloud build service after signing credentials are configured securely.

## Offline-first principles

1. Core reading and personal progress are available with no account and no network connection.
2. Screens read through repositories backed by Drift.
3. Quran reference content is immutable and versioned separately from user-owned records.
4. User-owned data uses stable UUIDs and explicit transactions.
5. Local reminders are scheduled on-device.
6. Core functionality must not depend on Firebase/Supabase or a remote API.
7. Future sync is introduced only after the local data model and privacy design are stable.
8. Payments, if introduced later, always require server confirmation; an offline action must never appear as a successful donation.

## Source/data architecture

Separate content into three categories:

- **Canonical religious reference data:** Quran text, translation of meanings, tafsir, adhkar, and recitation assets. Each item has source/edition/license metadata and a versioned import manifest.
- **Local user data:** bookmarks, notes, last-read position, reading plans, memorization progress, adhkar counters, preferences.
- **Future synchronized data:** opt-in profile, teacher sessions, groups, initiative participation, and remote backups. Not part of the initial local-only build.

The initial offline Quran text choice is Tanzil Uthmani v1.1, verbatim, subject to the notice/link and no-modification requirements in docs/CONTENT_SOURCES.md. Fonts and all other content remain resource-specific.

## Suggested source layout

    lib/
      app/
        app.dart
        bootstrap/
        router/
      core/
        database/
        design_system/
        localization/
        errors/
        utils/
      features/
        home/
        quran/
        adhkar/
        memorization/
        personal_impact/
        settings/
        reflections/          # later
        audio_assessment/     # later
        mentorship/           # later
        communities/          # later
        initiatives/          # later
        donations/            # later, separately governed

Do not create empty feature folders for the entire product vision in the first commit. Add a module when its milestone begins.

## Database boundaries

- Drift is the single source of truth for local state.
- Keep canonical Quran text immutable.
- Keep search-normalized text separate.
- Store content version, source ID, license ID, and content hash in the content manifest.
- Run multi-record updates in Drift transactions.
- Use stable UUIDs for local user records; do not use SQLite rowids as future cross-device identifiers.
- Add migrations and migration tests for every schema change.
- Do not add duplicate data persistence through SharedPreferences for domain data. SharedPreferences may hold non-critical platform preferences only if the domain model explicitly permits it.

## Future sync boundary

The first MVP does not connect to a backend. Later sync must define:

- Stable identity and ownership for every synchronized record.
- Outbox/idempotency contract.
- Retry and backoff behavior.
- Conflict-resolution policy per entity.
- Tombstones/deletions.
- Device/account association and consent.
- Backup, export, and deletion rules.

The UI and domain layers must depend on repository interfaces rather than a specific future backend SDK.

## AI boundaries

- Quran pronunciation, memorization alignment, and Tajweed evaluation are different problems.
- Speech-to-text is not a Tajweed judge.
- Assessment must expose confidence and allow “uncertain / human review”.
- No recording upload or long-term audio retention by default.
- Reflection generation uses approved source references and review; it must not invent religious rulings or attributions.
- AI output never overrides deterministic financial rules, verified sources, or qualified religious review.

## Build and release

- GitHub Actions: dependency resolution, code generation, formatting, static analysis, tests, and Android build smoke check.
- Codemagic: signed Android App Bundle and iOS archive/IPA when certificates and store accounts are available.
- Test audio, notifications, permissions, storage, database migration, and offline transitions on physical devices.
- Store submission is blocked until content licenses, privacy disclosures, accessibility, and metadata have been reviewed.
