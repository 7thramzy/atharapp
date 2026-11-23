# Athaar MVP Scope and Roadmap

## Product sequencing

Athaar is a connected product vision, not a requirement to ship every module in the first store release.

### MVP — Offline worship and learning

**In scope**

- Arabic-first application shell and onboarding.
- Home dashboard with a simple, private progress summary.
- Quran data and reader, after data source and integrity approval.
- Surah/Juz navigation and ayah search.
- Bookmarks and private notes.
- Reading position and personal reading plan.
- Adhkar catalog and local counters.
- Memorization progress and revision markers.
- Light/dark mode and Arabic RTL.
- Local reminders with user-controlled schedules.
- Privacy and data-source information screens.

**Out of scope**

- User accounts and cloud synchronization.
- AI recitation correction.
- AI-generated religious reflections.
- Teacher/student matching or live sessions.
- Public communities and family groups.
- Volunteer marketplace.
- Donations and payment processing.
- Public ranking or competitive scoring of worship.

## Delivery milestones

### M0 — Repository and engineering foundation

- [x] Create independent Athaar repository.
- [x] Inspect the two primary upstream repositories.
- [x] Decide selective reuse rather than a whole-app fork.
- [x] Decide Flutter, Riverpod, Drift, and deferred backend integration.
- [x] Document architecture, local data model, reuse rules, and release path.

### M1 — Application shell

- Flutter project and mobile platform folders.
- Arabic RTL and English localization foundation.
- Athaar design tokens, Cairo interface typography, light/dark themes.
- Riverpod and GoRouter.
- Drift database bootstrap, migration pattern, and test database.
- CI for format, generated code, analysis, and unit/widget tests.

### M2 — Quran content and reading

- Select and document an approved Quran text source.
- Add reproducible content import and manifest/checksum.
- Validate surah/ayah counts, order, metadata, and text integrity.
- Implement reader, search, bookmarks, notes, and last-reading position.
- Test offline use and app restart.

### M3 — Adhkar and memorization

- Curated, attributed adhkar dataset.
- Local counters and optional reminders.
- Memorization progress and revision sessions.
- Private personal impact summary based on actual local records.

### M4 — Recitation support research

- Evaluate audio capture on real Android and iOS devices.
- Establish a labelled evaluation set with appropriate permissions.
- First target: verse/word alignment and obvious omission/repetition detection.
- Measure false positives and false negatives.
- Add confidence and an easy human-teacher review path.
- Tajweed evaluation remains out of scope until validated against qualified reviewers.

### M5 — Guided reflection and trust center

- Approved references and source metadata.
- Human review workflow for religious material.
- Clearly separate sourced content, AI-assisted suggestions, and reviewed content.
- Privacy/data-source page and content correction pathway.

### M6 — Mentorship, family, communities, and initiatives

- Verified mentor profiles and transparent verification status.
- Safe session requests and user reporting.
- Opt-in family and small-group spaces.
- Non-financial community initiatives and completion evidence.
- Suitable moderation and safeguarding requirements.

### M7 — Donations and financial accountability

This milestone requires a separate go/no-go review.

Prerequisites:
- Legal operating entity and jurisdiction review.
- Payment provider eligibility for collection, holding, payout, and refunds.
- Beneficiary identity and case verification.
- Server-side payment confirmation and idempotency.
- Double-entry ledger with immutable postings and reversal entries.
- Segregation of duties for case approval and disbursement.
- Reconciliation, audit logs, refund handling, public reporting, and incident procedures.

No real donation processing is enabled before all prerequisites pass.

## First coding milestone acceptance criteria

The first implementation task is complete only when:

1. A fresh Codespaces environment can install the Flutter toolchain and run project checks.
2. The app launches on Android and iOS build targets.
3. Arabic is selected by default and RTL is applied correctly.
4. Light and dark themes use the Athaar color tokens.
5. Riverpod and GoRouter are wired without a second service locator.
6. Drift creates its database and applies a tested migration.
7. A database test proves that a record persists across database reopen.
8. dart format, code generation, flutter analyze, and flutter test pass in GitHub Actions.
9. No Supabase project or backend credentials are required.
