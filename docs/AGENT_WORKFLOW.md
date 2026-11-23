# Agent workflow and parallel development

## Purpose

Athaar may be developed by several independent coding agents in parallel. This workflow prevents duplicate work, overlapping edits, conflicting migrations, dependency churn, and unreviewed changes to sensitive content.

This document coordinates work; it does not automatically launch agents or grant them repository access. Each agent must be started with the appropriate GitHub/repository access by the project owner.

## 1. Start of every agent session

1. Read AGENTS.md and every mandatory project document listed there.
2. Inspect the current main commit, working tree, file tree, dependency manifest, CI status, and open issue.
3. Read docs/STATUS.md and docs/agents/WORK_BOARD.md; verify their state against GitHub.
4. Select one bounded issue and confirm that its paths are unclaimed.
5. Post a claim on that issue using the format below.
6. Create a unique branch from the latest main.
7. Implement only the approved scope and paths.

### Claim format

Post this in the GitHub issue before editing:

- Agent ID / role:
- Issue:
- Branch:
- Reserved paths:
- Expected output:
- Dependencies:
- Start commit:
- Status: ACTIVE

The coordinator records the claim in docs/agents/WORK_BOARD.md. If another agent has already reserved any path, do not start editing those paths.

## 2. Branch and pull-request model

- Main is the protected integration line. Agents never commit directly to main.
- Branch naming: agent/<role>/<issue-number>-<short-slug>.
- One issue and one accountable agent per branch.
- Branch from the latest main; do not create parallel branches from stale feature branches unless the coordinator explicitly requests it.
- Keep commits focused and descriptive.
- Open a pull request to main when acceptance criteria are met.
- Every PR must identify the issue, changed paths, test commands/results, license impact, migration impact, and known limitations.
- The integration lead resolves conflicts and merges. Task agents must not force-push over another agent's work.
- If GitHub branch protection is available, require passing CI and at least one review before merge. If it is not configured, follow the same policy operationally.

## 3. Parallelism model

Agents may run at the same time only when their work sets are independent.

### Recommended parallel lanes

| Lane | Agent role | Typical owned paths | Can run in parallel with |
|---|---|---|---|
| A | Integration lead / architect | Shared app wiring, cross-feature contracts, main integration, shared docs | Research lanes and isolated feature lanes |
| B | Content rights researcher | docs/content-reviews/<resource>/ only | UI and database work |
| C | Design-system agent | lib/core/design_system/** and its own tests | Content research; isolated data modules |
| D | Drift/data agent | lib/core/database/**, migrations, database tests | Design system and rights research |
| E | Quran feature agent | lib/features/quran/** and feature-local tests | Adhkar feature after shared contracts exist |
| F | Adhkar feature agent | lib/features/adhkar/** and feature-local tests | Quran feature after shared contracts exist |
| G | QA agent | Assigned test paths and test fixtures | Isolated feature work, provided it does not edit shared CI |
| H | Build/CI agent | .devcontainer/** and .github/workflows/** | Feature work, only with integration-lead approval |

These are roles, not pre-created GitHub accounts. An agent must not assume that another role is running unless a claim exists on the board.

## 4. Shared-file locks

The following files/areas are shared and must have exactly one active owner at a time:

| Shared area | Owner |
|---|---|
| pubspec.yaml and pubspec.lock | Integration lead |
| lib/main.dart and app bootstrap | Integration lead |
| App router and global navigation | Integration lead |
| Design-system public exports and token contract | Design-system lead, with integration approval |
| Localization setup, ARB registry, generated localization configuration | Localization/integration lead |
| Drift database root, schema version, migration numbering | Database lead |
| GitHub Actions and Dev Container base image | CI lead, coordinated by integration lead |
| docs/CONTENT_SOURCES.md | Content governance lead |
| docs/STATUS.md and docs/agents/WORK_BOARD.md | Coordinator only |
| README.md, AGENTS.md and workflow policy | Coordinator only |

A feature agent may request a dependency or shared-schema change in its PR description, but must not edit the shared file independently.

## 5. File ownership and collision handling

1. Reserve the narrowest useful path set, not the whole repository.
2. Do not reserve a directory if a narrower feature directory will work.
3. Never let two agents edit the same file concurrently.
4. If a task needs a shared-file change, create a request for the shared-file owner.
5. If a new conflict appears, stop before editing and notify the coordinator.
6. Do not resolve conflicts by discarding another agent's changes.
7. Generated files belong to the owner of the source schema/configuration that generated them.
8. Each agent maintains its own handoff file at docs/agents/handoffs/issue-<number>.md. This avoids concurrent edits to a shared handoff document.

See docs/agents/FILE_OWNERSHIP.md for the path-level contract.

## 6. Dependency and merge ordering

- Research-only tasks can run independently of M1.
- The M1 application shell must be integrated before feature modules depend on global routing, localization, or design-system exports.
- The Drift schema owner must publish stable repository/entity contracts before feature agents build database-dependent screens.
- Quran UI may be prototyped against fake/test repositories but must not import unapproved Quran assets.
- Adhkar content cannot be added until its source and wording are approved.
- Audio work starts with playback/capture abstractions only. No production recitation audio is bundled until its rights dossier is approved.
- Sync/backend work is blocked until the local data model, outbox/conflict policy, and privacy boundaries are reviewed.
- Donation work is blocked until legal operation, provider eligibility, ledger, reconciliation, and disbursement controls are approved.

Merge sequence: independent research first; shared foundation next; feature PRs after their contracts; final integration/QA last.

## 7. Handoff format

Each task agent creates or updates only its own file:

docs/agents/handoffs/issue-<number>.md

Use docs/agents/HANDOFF_TEMPLATE.md and record:

- Date, agent role, issue, branch, base/head commit.
- Exact files changed.
- Implementation summary.
- Commands run and their exact results.
- Tests not run and why.
- License/privacy/security impact.
- Known defects, blockers, assumptions.
- Next recommended action.

The coordinator verifies the PR and then updates docs/STATUS.md and docs/agents/WORK_BOARD.md.

## 8. Pull-request gate

A PR is not ready to merge until:

- It implements one issue without unrelated scope.
- Its reserved paths match the board.
- It does not introduce undeclared dependencies or a second database.
- It contains required tests.
- It preserves third-party notices and exact content-source attribution.
- It does not include restricted/unknown-license media or sacred-text transformations.
- It does not include secrets or personal recordings.
- The relevant format, generation, analysis, and test commands pass.
- The handoff file is complete.
- The integration lead has reviewed shared contracts and merge order.

## 9. User-facing progress and project truth

Report facts separately as:

- Completed: changed in repository.
- Tested: specific command/test passed.
- Merged: PR is in main.
- Deployed: an artifact or service was actually deployed.
- Device-verified: manually tested on an actual Android/iOS device.
- Blocked: a source, permission, toolchain, or decision prevents progress.

Never present a plan as implementation, a CI configuration as a passing CI run, or a built binary as a published store release.
