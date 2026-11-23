# Agent file ownership contract

This is the concrete path map for concurrent work. It is intentionally conservative at the start of the project.

## Shared / single-owner paths

| Path | Single owner | Other agents may |
|---|---|---|
| pubspec.yaml, pubspec.lock | Integration lead | Request dependencies in issue/PR |
| lib/main.dart, lib/app/** | Integration lead | Request bootstrap or route integration |
| lib/core/database/** | Database lead | Request tables/queries through a contract |
| lib/core/design_system/** | Design-system lead | Consume exported widgets/tokens; request additions |
| lib/core/localization/**, l10n/**, lib/l10n/** | Localization lead | Add feature translation proposals in own handoff |
| lib/app/router/** or global router file | Integration lead | Request new routes |
| .github/workflows/**, .devcontainer/** | CI/build lead | Request job changes |
| docs/CONTENT_SOURCES.md | Content governance lead | Deliver a resource-specific review dossier |
| docs/STATUS.md, docs/agents/WORK_BOARD.md | Coordinator | Read and report status |
| README.md, AGENTS.md, docs/AGENT_WORKFLOW.md | Coordinator | Suggest edits in issue comments |

## Feature ownership

| Feature | Owned paths | Must not edit |
|---|---|---|
| Quran | lib/features/quran/**; test/features/quran/** | Global router, pubspec, DB root/migrations, shared content registry |
| Adhkar | lib/features/adhkar/**; test/features/adhkar/** | Global router, pubspec, DB root/migrations, shared content registry |
| Memorization | lib/features/memorization/**; test/features/memorization/** | Global router, pubspec, DB root/migrations |
| Personal impact | lib/features/personal_impact/**; test/features/personal_impact/** | Global router, pubspec, DB root/migrations |
| Reflections | lib/features/reflections/**; test/features/reflections/** | Religious-source registry and review governance |
| Audio assessment | docs/audio-evaluation/**; later lib/features/audio_assessment/** | Recording uploads, training pipelines, or provider secrets without approval |
| Mentorship | lib/features/mentorship/**; test/features/mentorship/** | Auth backend or messaging provider without approved design |
| Communities | lib/features/communities/**; test/features/communities/** | Moderation policy or cross-user data access without approval |
| Initiatives | lib/features/initiatives/**; test/features/initiatives/** | Payment/donation flows |
| Donations | Future docs/finance/** and separately approved backend paths | Any live payment code before legal and financial go/no-go |

## Content review ownership

Research-only agents may create only the exact dossier files reserved in the issue:

- Quran text and fonts: docs/content-reviews/quran-text.md and docs/content-reviews/mushaf-fonts.md.
- Tafsir and translations: docs/content-reviews/tafsir-translations.md.
- Recitations: docs/content-reviews/recitations.md.

Do not edit the shared content-source registry during parallel research. The coordinator is responsible for merging evidence and decisions.

## Generated files

Generated code belongs to the owner of its source configuration/schema. Never independently hand-edit generated Drift, Riverpod, localization, or platform files. Include generated outputs only when the owning source change and code-generation command are part of the PR.
