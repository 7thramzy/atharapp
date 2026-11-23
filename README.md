# أثَر | Athaar

**An offline-first Islamic learning and community application.**

أثَر connects personal worship and learning with meaningful community contribution. It is an independent Flutter application for Android and iOS.

## Product principles

- **Offline first:** Quran reading, adhkar, bookmarks, notes, memorization progress, and personal settings work without an account or network connection.
- **Trust before scale:** Quranic text, translations, tafsir, teachers, initiatives, and any future donation cases require documented sources and appropriate review.
- **Privacy by default:** Personal worship activity remains private. Audio is not retained or uploaded by default.
- **Human accountability:** AI suggestions are clearly identified and do not replace qualified Quran teachers or religious reviewers.
- **Financial integrity:** Future donations will use server-confirmed payments and an auditable double-entry ledger. Financial actions will never be finalized offline.
- **Independent modules:** Quran and learning are built first; mentorship, community initiatives, and financial services are introduced only after their prerequisites are satisfied.

## Technology decisions

| Area | Decision |
|---|---|
| Mobile | Flutter |
| State management | Riverpod |
| Local database | Drift + SQLite |
| Navigation | GoRouter |
| UI | Material 3, Athaar design tokens |
| Languages | Arabic first, English next |
| Backend | Deferred; no Supabase or Laravel integration yet |
| Cloud development | GitHub Codespaces |
| CI | GitHub Actions |
| Store builds | Codemagic or equivalent cloud build service |

Drift is the only persistence layer in the initial implementation. Supabase remains a future option and will be evaluated after the offline MVP.

## Content sources

- **Arabic Quran text:** Tanzil Uthmani v1.1, verbatim, with its required notice and link.
- **Quran script font:** KFGQPC official digital resources, subject to recording the exact file and rights notice.
- **UI font:** Cairo under SIL OFL 1.1.
- **Tafsir and translations:** QUL is a resource catalogue; each exact item needs an individual license review.
- **Recitations:** AlQuran Cloud/Islamic Network is a conditional streaming candidate; no MP3 bundle in MVP. EveryAyah is not approved until recording-specific rights are documented.

See [Content sources and licenses](docs/CONTENT_SOURCES.md). Do not add religious content assets without an approved source record.

## Engineering documentation

- [Agent instructions](AGENTS.md)
- [Agent workflow and parallel development](docs/AGENT_WORKFLOW.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Architecture decisions](docs/DECISIONS.md)
- [Domain model](docs/DOMAIN_MODEL.md)
- [Content sources and licenses](docs/CONTENT_SOURCES.md)
- [Security and governance](docs/SECURITY.md)
- [Roadmap](docs/ROADMAP.md)
- [Project status](docs/STATUS.md)
- [Starter audit](docs/STARTER_AUDIT.md)
- [Parallel work board](docs/agents/WORK_BOARD.md)
- [Path ownership](docs/agents/FILE_OWNERSHIP.md)
- [Agent handoff template](docs/agents/HANDOFF_TEMPLATE.md)
- [Detailed engineering audit](docs/engineering/REPOSITORY_AUDIT.md)

## Current status

The repository audit and documentation foundation are complete. Application code has not started. The next implementation milestone is [M1: Flutter application shell](https://github.com/7thramzy/atharapp/issues/1).

Independent content-rights reviews can run in parallel:
- [Quran text and Mushaf fonts](https://github.com/7thramzy/atharapp/issues/2)
- [Tafsir and translations](https://github.com/7thramzy/atharapp/issues/3)
- [Recitations and audio](https://github.com/7thramzy/atharapp/issues/4)

## Repository boundary

This repository contains project documentation and engineering policy at this stage. No Flutter package, Quran dataset, tafsir database, audio file, Supabase project, credential, or store signing material has been added.
