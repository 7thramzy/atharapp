# Athaar Architecture Decisions

This document records the decisions that govern the first implementation. Changes should be made through a short Architecture Decision Record (ADR) so that the application does not drift into incompatible patterns.

## ADR-001 — Independent Flutter application

**Status:** Accepted

Athaar is its own product and repository. It is not a branded fork of an existing Quran application.

- Target platforms: Android and iOS.
- UI framework: Flutter with Material 3.
- Cloud development: GitHub Codespaces.
- Source of truth for code: this GitHub repository.

## ADR-002 — Local-first data architecture

**Status:** Accepted

Drift/SQLite is the single persistence layer for the first application milestones.

- Quran text and approved reference data are packaged locally after licensing and integrity checks.
- User-owned bookmarks, notes, settings, reading position, memorization progress, and adhkar counts are stored locally.
- Screens read from local repositories; the UI must not depend on a network connection for core reading and personal progress.
- Each database change is versioned and covered by migration tests.
- Use stable UUIDs for user-created records and stable natural keys for Quran references.
- Use explicit transactions for multi-row user actions.

No Supabase SDK, credentials, remote database tables, or network repositories are added in the foundation milestone.

## ADR-003 — Backend integration is deferred

**Status:** Accepted

The backend decision is intentionally postponed until the local application has proven its data model and offline behavior.

- Define domain repository interfaces so a later remote adapter can be introduced without changing UI code.
- Do not create a fake network layer or add a server dependency just to appear cloud-ready.
- A future sync adapter must specify retry semantics, conflict handling, deletions/tombstones, and privacy controls before it is implemented.
- Any future payment or donation command must be server-confirmed and idempotent.

Laravel is not part of the initial technology plan. Supabase remains a candidate for a later backend decision, not an active dependency.

## ADR-004 — State management and navigation

**Status:** Accepted

- Riverpod 3 is the state-management and dependency-composition mechanism.
- Use generated providers where they materially improve dependency declarations and testing.
- GoRouter is the navigation layer.
- Do not combine Riverpod and get_it as competing global service locators.
- Keep repositories and use cases independently testable.

## ADR-005 — Feature-oriented Clean Architecture

**Status:** Accepted

Organize the app by product feature, with clear domain/data/presentation boundaries inside complex modules.

Planned high-level layout:

~~~text
lib/
  app/
    app.dart
    router/
    bootstrap/
  core/
    design_system/
    localization/
    errors/
    database/
    utils/
  features/
    home/
    quran/
    adhkar/
    memorization/
    personal_impact/
    reflections/
    settings/
    audio_assessment/       # later
    mentorship/             # later
    communities/            # later
    initiatives/            # later
    donations/              # later, separately governed
~~~

Do not create empty modules for every future idea in the first commit. Add a feature when its implementation milestone begins.

## ADR-006 — Arabic-first localization and typography

**Status:** Accepted

- Arabic (ar) is the initial interface locale; English (en) is the next supported locale.
- Layout direction follows the selected locale.
- Use Flutter's generated localization support with ARB resources and flutter_localizations/intl.
- Cairo is the planned interface font, subject to bundling its valid font license.
- Quran text uses a separate verified Uthmani script font/data source. It must never be styled by rewriting or normalizing the sacred text.
- Translations of meanings are displayed in a separate layer below or beside the Arabic text and are never represented as the Arabic Quran.

## ADR-007 — Athaar visual identity

**Status:** Accepted

- Primary: petrol/emerald #006F88.
- Supporting silver: #C9CDD2.
- Gold is a restrained accent for meaningful milestones, not a general decorative color.
- Light mode uses a warm cream surface.
- Dark mode uses dark slate rather than pure black.
- Occasion themes may adjust small accents and micro-interactions; they must not compromise contrast, accessibility, or reading focus.
- Quran reading remains low-distraction and avoids unnecessary animation.

Exact surface shades, typography scale, spacing, and contrast pairs will be finalized during the design-system implementation and checked for WCAG contrast.

## ADR-008 — Reuse policy

**Status:** Accepted

- Reuse MIT-licensed source selectively, preserving notices for copied or substantial portions.
- Do not assume a repository's code license also covers its data, fonts, icons, audio, translations, tafsir, or other bundled assets.
- Keep a third-party register and record the exact upstream commit and files used.
- Do not import GPL/AGPL code into the mobile application without a specific license review.
- Do not make a whole-app fork merely to save initial setup time.

## ADR-009 — Trust and high-risk modules

**Status:** Accepted

- AI-generated religious reflections must cite approved references and remain distinguishable from reviewed content.
- Recitation assessment must expose confidence and uncertainty; it cannot present its output as a definitive ruling on recitation validity.
- Recordings are ephemeral by default. Upload or retention requires explicit consent and a clear retention policy.
- Mentors and teachers require an appropriate verification workflow before being presented as verified.
- Donations are out of MVP scope until legal operating status, payment provider eligibility, case verification, double-entry ledger, reconciliation, disbursement controls, refund handling, and audit trails are designed and tested.
- Financial activity is never finalized offline.

## ADR-010 — Cloud build and release strategy

**Status:** Accepted

- GitHub Actions runs formatting, generation, static analysis, tests, and mobile build checks.
- Codespaces is the browser-based development environment; it is not the release-signing system.
- Codemagic or an equivalent managed cloud build service produces signed Android/iOS artifacts when signing credentials are configured securely.
- No signing keys, passwords, service-role keys, or private credentials are committed to the repository.
- Store publication occurs only after physical-device QA, privacy review, content/data license review, and developer account setup.
