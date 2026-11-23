# Athaar architecture decision records

Decisions are intentionally small and explicit. Amend an existing decision only through a reviewed PR that states the reason and migration impact.

## D-001 — Independent product, not a full fork

**Status: ACCEPTED**

Athaar has its own repository, name, navigation, design system, and product model. Reuse selected MIT-licensed code only after file-level review. Do not copy an entire upstream app to save setup time.

## D-002 — Flutter mobile application

**Status: ACCEPTED**

Flutter targets Android and iOS. Codespaces removes the need for a local Flutter setup; cloud CI and build tools provide compilation. Physical-device QA is still required.

## D-003 — Drift is the only local database

**Status: ACCEPTED**

Use Drift + SQLite for Quran reference data and user-owned local progress. Do not use Hive, Isar, ObjectBox, or SharedPreferences as competing domain persistence layers.

## D-004 — Backend integration is the last infrastructure phase

**Status: ACCEPTED**

Supabase remains a candidate, not a current dependency. Do not create a Supabase project, add SDKs, configure Auth, or create cloud schema before the local MVP and sync contract are validated. Laravel is not part of the current plan.

## D-005 — Riverpod is the single state/dependency layer

**Status: ACCEPTED**

Use Riverpod 3 for application state and dependency composition. Do not add GetIt as a second global service locator. GoRouter handles navigation.

## D-006 — Arabic first, English second

**Status: ACCEPTED**

Default locale is Arabic with RTL. English is the next supported UI locale. Use Cairo for interface typography only after including the SIL OFL notice. Quran text uses a separate reviewed Uthmani script font and must not be altered.

## D-007 — Athaar visual identity

**Status: ACCEPTED**

- Primary petrol/emerald: #006F88.
- Silver support: #C9CDD2.
- Restrained gold for milestones and selected status.
- Warm cream light theme.
- Dark slate dark theme.
- Avoid excessive glassmorphism or animation in Quran reading; accessibility and text legibility take priority.

## D-008 — Tanzil Uthmani is the initial offline Quran text source

**Status: ACCEPTED, subject to manifest verification**

Use Tanzil Quran Text Uthmani v1.1 as the first bundled Arabic Quran candidate. Keep it verbatim, preserve its provided notice, attribute Tanzil Project, and link to tanzil.net. Any search normalization lives in a separate field. Record the exact downloaded options, version, hash, and retrieval date before importing it.

Do not bundle Quran Foundation API content as a static dataset. QF terms impose separate storage/sync and redistribution limits.

## D-009 — Every tafsir, translation, font, and recording has its own rights record

**Status: ACCEPTED**

QUL is a resource catalogue, not a blanket data license. Do not bundle a resource until its exact record, edition, rights holder, license, attribution, offline and commercial use conditions are known. KFGQPC and Cairo are preferred font sources under their published digital-use/OFL conditions, subject to the exact asset record.

## D-010 — No prepackaged recitation audio in the MVP

**Status: ACCEPTED**

Use no bundled MP3 files in the initial app. AlQuran Cloud/Islamic Network may be considered for user-initiated streaming under its terms and reciter-level review. EveryAyah remains blocked until clear recording rights are documented. No rehosting, remixing, or model training on playback assets.

## D-011 — Multiple coding agents use isolated branches and path ownership

**Status: ACCEPTED**

Agents may work concurrently only on disjoint path sets, one issue per agent, with a recorded claim, unique branch, PR, tests, and handoff. The coordinator owns shared files, the work board, and project status. No agent pushes directly to main. See docs/AGENT_WORKFLOW.md.

## D-012 — Personal impact is private and non-competitive

**Status: ACCEPTED**

Reading, memorization, and adhkar activity is private by default. No public worship rankings, shame-based reminders, or automatic sharing. Family and group visibility is explicit opt-in.

## D-013 — AI assistance is not religious authority

**Status: ACCEPTED**

AI reflections cite approved sources and are distinguished from reviewed material. Recitation assessment exposes uncertainty and routes uncertain cases to a qualified teacher. AI-generated material must not invent verses, hadith, tafsir, or rulings.

## D-014 — Donations are out of MVP

**Status: ACCEPTED**

No real financial transaction before legal operating status, payment-provider eligibility, case verification, double-entry immutable ledger, idempotent webhooks, reconciliation, separated approval/disbursement, refund handling, audit, and public reporting are designed and tested.
