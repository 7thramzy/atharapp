# أثَر | Athaar

**An offline-first Islamic learning and community application.**

أثَر connects personal worship and learning with meaningful community contribution. It is being developed as an independent Flutter application for Android and iOS.

> **Repository status:** Repository audit and engineering foundation documented. Application implementation has not started. Backend integration is intentionally deferred.

## Product principles

- **Offline first:** Quran reading, adhkar, bookmarks, notes, memorization progress, and personal settings work without an account or network connection.
- **Trust before scale:** Quranic text, religious references, teachers, initiatives, and any future donation cases require documented sources and appropriate review.
- **Privacy by default:** Personal worship activity remains private. Audio is not retained or uploaded by default.
- **Human accountability:** AI suggestions are clearly identified and do not replace qualified Quran teachers or religious reviewers.
- **Financial integrity:** Future donations will use server-confirmed payments and an auditable double-entry ledger. Financial actions will never be finalized offline.
- **Independent modules:** Quran and learning are built first; mentorship, community initiatives, and financial services are introduced only after their prerequisites are satisfied.

## Initial technology decisions

| Area | Decision |
|---|---|
| Mobile application | Flutter |
| State management | Riverpod |
| Local database | Drift + SQLite |
| Navigation | GoRouter |
| UI | Material 3 with Athaar design tokens |
| Languages | Arabic first, English next |
| Backend | Deferred; no Supabase or Laravel integration in the foundation stage |
| Cloud development | GitHub Codespaces |
| CI | GitHub Actions |
| Store builds | Codemagic or an equivalent Android/macOS cloud build service |

Drift is the persistence layer for the first implementation. We will not introduce a second local database or a remote database before the local product is stable.

## Product modules

1. **Worship and learning:** Quran reader, adhkar, reading plans, memorization and revision.
2. **Recitation support:** staged audio capture and assessment, beginning with measurable text-alignment capabilities and human review.
3. **Guided reflection:** sourced reflections and optional practical tasks, reviewed before being presented as religious guidance.
4. **Personal impact:** private progress and a user-controlled summary of learning and contributions.
5. **Trust center:** source attribution, content review status, teacher verification, and later public financial reporting.
6. **Community:** optional family and small-group spaces, mentorship, and non-financial initiatives.
7. **Donations:** a later, separately governed module requiring legal, payment-provider, and financial-control approval.

## Engineering documentation

- [Repository audit](docs/engineering/REPOSITORY_AUDIT.md)
- [Architecture decisions](docs/engineering/ARCHITECTURE_DECISIONS.md)
- [Local data model](docs/engineering/LOCAL_DATA_MODEL.md)
- [Reuse and license register](docs/engineering/REUSE_AND_LICENSE_REGISTER.md)
- [MVP scope and roadmap](docs/engineering/MVP_SCOPE_AND_ROADMAP.md)
- [Development and release plan](docs/engineering/DEVELOPMENT_AND_RELEASE_PLAN.md)
- [Security and content governance](docs/engineering/SECURITY_AND_CONTENT_GOVERNANCE.md)

## Current boundary

This repository currently contains product and engineering foundation documents only. No Flutter package, application source, Supabase project, credentials, or store signing material has been added. The next implementation milestone is the Flutter application shell with Arabic RTL, the design system, Riverpod, and a tested Drift database.
