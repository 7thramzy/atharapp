# Athaar agent instructions

You are working on **Athaar**, an Arabic-first, offline-first Islamic learning and community mobile application. Preserve the decisions and safety boundaries recorded in this repository.

## Mandatory reading order

Before changing anything, read:

1. This file: AGENTS.md
2. README.md
3. docs/AGENT_WORKFLOW.md
4. docs/agents/WORK_BOARD.md
5. docs/agents/FILE_OWNERSHIP.md
6. docs/DECISIONS.md
7. docs/ARCHITECTURE.md
8. docs/DOMAIN_MODEL.md
9. docs/CONTENT_SOURCES.md
10. docs/SECURITY.md
11. docs/ROADMAP.md
12. docs/STATUS.md
13. docs/STARTER_AUDIT.md

Read the issue being implemented and its linked handoff file as well.

## Session start

- Inspect the repository tree, current branch, latest commit, and existing changes before editing.
- Verify the issue is still open and that its paths are not reserved by another active agent.
- Work only on the assigned issue and assigned paths.
- Create a unique branch from the latest main; never work directly on main.
- Do not assume a Flutter app, data asset, backend, signing secret, or deployment exists merely because a plan mentions it.
- Verify all current toolchain and dependency requirements before pinning versions.

## Multi-agent rules

- One issue has one accountable agent at a time.
- Multiple agents may work in parallel only when their file ownership sets do not overlap.
- Reserve paths on the board before editing.
- Shared files require the integration lead's approval: pubspec.yaml, pubspec.lock, application bootstrap, router, design-system exports, localization configuration, Drift database root and migration sequence, GitHub workflows, and the shared source/status registers.
- Never let two agents independently edit the same Drift schema or migration number.
- The coordinator owns WORK_BOARD.md and STATUS.md. Task agents use their own issue-specific handoff file.
- If a conflict or unowned shared-file requirement appears, stop and request coordination rather than force-merging or overwriting another agent's work.
- All changes arrive through pull requests. No direct main commits, force pushes, or unreviewed merges.
- The integration lead reviews file overlap, source attribution, tests, migration safety, and CI before merging.

The workflow is defined in docs/AGENT_WORKFLOW.md. The active work board is docs/agents/WORK_BOARD.md.

## Product and data rules

- Flutter is the mobile framework.
- Riverpod is the only state/dependency composition layer.
- Drift + SQLite is the only local persistence layer in the foundation stage.
- Supabase and all backend integration are deferred until the local MVP is proven.
- Do not add Laravel, Firebase, Supabase, remote auth, payment SDKs, or network repositories without a recorded decision and approved issue.
- Core reading and personal progress must not require a network connection.
- Do not change Quran Arabic text. Any search-normalized form must be separate from the canonical text.
- A source code license does not license the datasets, fonts, audio, translations, tafsir, images, or artwork included by an upstream project.
- Do not bundle a religious text, translation, tafsir, font, recitation, or dataset unless its exact resource, version, license, attribution, and intended use have been reviewed and recorded in docs/CONTENT_SOURCES.md or an approved content-review dossier.
- Treat missing/unknown rights as blocked, not implicitly free.
- Never fabricate religious citations, hadith attribution, tafsir statements, reciter permissions, dataset versions, or content verification.
- AI output is an assistive suggestion, not a religious ruling or a substitute for a qualified teacher/scholar.
- Recordings are ephemeral by default. Do not upload or retain recordings without explicit consent and an approved privacy design.
- Do not use sacred text or user recordings for model training unless a separate, explicit rights and consent review permits it.
- Donations and financial processing are out of the MVP. No app-only or offline action may be treated as a confirmed payment.

## Engineering rules

- Prefer small, independently reviewable changes.
- Keep domain logic independent of Flutter widgets, platform APIs, and future backend SDKs.
- Add tests for user-visible logic, data integrity, migrations, permissions, and failure paths.
- Use Drift migrations; never drop or rewrite user data without an approved recovery plan.
- Do not add a second local database or duplicate state store.
- Pin dependencies and commit lockfiles.
- Keep secrets, keystores, provisioning profiles, tokens, private datasets, and personal recordings out of Git.
- Never commit generated Quran/tafsir/audio/font assets simply because an upstream repo contains them.
- Use descriptive commits and attach test evidence to the pull request.
- Update only the assigned handoff file; the coordinator updates shared status after review/merge.

## Definition of done

A change is done only when:

- The requested scope is implemented.
- Relevant tests and checks have been run and their exact results recorded.
- License and privacy implications have been checked.
- No unrelated file ownership was violated.
- The handoff file lists changed paths, commit, validation, known gaps, and next action.
- The pull request has been reviewed and merged by the integration lead.

Clearly distinguish **implemented**, **tested**, **merged**, **deployed**, and **verified on a real device**. Never claim one because another happened.
