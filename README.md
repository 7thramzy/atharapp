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

M1 is merged to main. M2/M3 include the offline Tanzil Quran text reader, ayah search/bookmarks/notes, personal adhkar counters, memorization sessions, and a private activity summary. The QCF Hafs Mushaf, updated interface, ayah study, tafsir, translations and online recitation are merged to main. Offline recitation downloads and public-release signing are being verified on the release-preparation branch. See the implementation notes for remaining content and device-QA gates.

- [M1 implementation notes](docs/engineering/M1_IMPLEMENTATION.md)
- [M2/M3 implementation notes](docs/engineering/M2_M3_IMPLEMENTATION.md)
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
- **Recitations:** user-requested downloads are stored only in private app storage for offline listening under the provider's personal/educational terms; no app-bundled MP3s, uploads, re-hosting or exports. Each reciter/edition can be disabled if rights are withdrawn.

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
