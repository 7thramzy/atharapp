# أثَر | Athaar

**An offline-first Islamic learning and community application.**

أثَر connects personal worship and learning with meaningful community contribution. It is an independent Flutter application for Android and iOS.

## Technology

| Area | Decision |
|---|---|
| Mobile | Flutter 3.50.0 |
| State management | Riverpod 3 |
| Navigation | GoRouter |
| Local database | Drift + SQLite |
| UI | Material 3, Athaar design tokens |
| Languages | Arabic first, English next |
| Backend | Deferred; no Supabase or Laravel integration yet |
| Development | GitHub Codespaces |
| CI | GitHub Actions |
| Store builds | Codemagic or equivalent cloud build service (later) |

Drift is the only persistence layer in the initial implementation. Supabase remains a future option and will be evaluated after the local MVP.

## Current implementation

The M1 branch contains the first application shell, Arabic/English localization, light/dark themes, initial Drift schema, and database/widget tests. The Quran reader, adhkar data, memorization feature, and audio assessment are later milestones.

- [M1 implementation notes](docs/engineering/M1_IMPLEMENTATION.md)
- [Repository audit](docs/engineering/REPOSITORY_AUDIT.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Architecture decisions](docs/DECISIONS.md)
- [Domain model](docs/DOMAIN_MODEL.md)
- [Content sources and licenses](docs/CONTENT_SOURCES.md)
- [Security and governance](docs/SECURITY.md)
- [Roadmap](docs/ROADMAP.md)
- [Agent workflow](docs/AGENT_WORKFLOW.md)
- [Parallel work board](docs/agents/WORK_BOARD.md)
- [Project status](docs/STATUS.md)

## Develop in Codespaces

Open the repository in GitHub Codespaces. The Dev Container installs the pinned Flutter SDK and Android tooling, then prepares platform scaffolding and Drift-generated code.

    flutter analyze
    flutter test
    flutter run

The first Codespaces setup creates android/, ios/, and .metadata if they are not already tracked. Review and commit those generated project files. It also resolves dependencies; commit the generated pubspec.lock before a production-bound release.

## Content source policy

- **Arabic Quran text:** Tanzil Uthmani v1.1, verbatim, with the required notice and source link.
- **Quran script font:** KFGQPC official digital resources, subject to exact-file and rights-notice recording.
- **UI font:** Cairo under SIL OFL 1.1; the exact binary and OFL notice are not bundled yet.
- **Tafsir and translations:** QUL is a resource catalogue; every exact item needs an individual license review.
- **Recitations:** no prepackaged MP3 in MVP; each reciter/provider's rights must be reviewed.

See [Content sources](docs/CONTENT_SOURCES.md). Do not add religious content assets without an approved source record.

## Product principles

- Offline-first reading and personal progress.
- Privacy by default; no account is required for the local core.
- AI suggestions are never presented as religious rulings.
- Recitation assessment exposes uncertainty and can route a user to human review.
- Community participation is opt-in.
- Donations are a later, separately governed module. No financial action can be finalized offline.

## Project boundaries

No Supabase project, cloud authentication, payment SDK, user-uploaded voice storage, signing credentials, or store submission is part of M1.
