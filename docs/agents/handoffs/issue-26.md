# Agent handoff — issue 26

## Identity

- Date: 2026-11-28
- Agent role/ID: Integration lead — P0 Quran integrity investigation
- GitHub issue: https://github.com/7thramzy/atharapp/issues/26
- Branch: `agent/quran/26-mushaf-integrity`
- Base commit: `535e7d5a1c9320d8836fa95554a80c6f1f26c444`
- Head commit: pending
- Reserved paths: `lib/features/quran/**`, `test/quran/**`; issue-specific handoff only under `docs/agents/handoffs/`

## Result

- Status: PARTIAL — diagnosis in progress; no production fix made.
- Summary:
  - The current Athaar adapter sets no custom line ordering; it initializes QCF metadata and exposes page-boundary lookups.
  - Existing tests validate all 6,236 ayah-to-page lookups, 604 populated pages, and contiguous page start/end boundaries. They do not validate visual ayah ordering within a rendered line, line-to-line ordering, glyph placement, or basmala placement.
  - In the inspected QCF upstream source, `GetPage._generateLines()` appends ayah segments in the order received from the Quran data list. `parseLine()` then iterates `line.ayahs.toList().reversed` before `QuranLine` wraps each ayah in a `WidgetSpan` inside an RTL `RichText`.
  - This is a credible ordering risk and should be covered by a parser/rendering regression test. It is not yet a proven root cause for the owner's screenshot because the exact 0.1.1 package source-to-upstream revision correspondence and physical visual output have not been independently verified.
  - The first-two-page layout inserts the surah header and basmala as separate widgets before the page lines. The page-spread arrangement uses an RTL Row and intentionally puts odd page left / even page right. These should be checked separately from within-line verse ordering.
  - No canonical Tanzil text or QCF dependency was changed. No speculative RTL or array reversal was applied.

- Exact paths changed: this handoff only.
- Decisions made: preserve current implementation until the defect is reproduced against the exact locked package and a trusted Mushaf reference.

## Validation

| Command or check | Result | Notes |
|---|---|---|
| Inspect current main commit and repository tree | PASS | Base is `535e7d5a1c9320d8836fa95554a80c6f1f26c444` |
| Inspect Athaar QCF adapter and existing tests | PASS | Existing page-map coverage confirmed |
| Inspect QCF upstream parser and page construction source | PARTIAL | Upstream main inspected; exact source revision for pub package 0.1.1 not yet established |
| Flutter format/analyze/tests | NOT RUN | No local Flutter execution in this investigation |
| Exact screenshot reproduction | BLOCKED | Original image is not available in this execution context |
| Physical-device visual QA | NOT RUN | Requires device build and human comparison |
| QCF font/page-data rights review | BLOCKED | D-015 remains open; package MIT code license does not establish asset rights |
| Release size/startup/cache benchmarks | NOT RUN | Existing spike records a 240.16 MiB Android debug APK; physical-device metrics remain outstanding |

## Source and safety review

- New dependency/assets: none.
- Source URL and exact version: Athaar pins `qcf_quran_plus: 0.1.1`; inspected upstream repository source at https://github.com/hussein12347/qcf_quran_plus. Exact commit correspondence to 0.1.1 still needs verification.
- License/attribution: no new assets used. Existing D-015 QCF font/page-data rights gate remains unresolved.
- Privacy/security impact: none.
- Data migration impact: none.
- Secrets/media included: NO.

## Known gaps and blockers

- The user's original comparison screenshot must be available to reproduce the precise visual symptom.
- Establish exact QCF 0.1.1 source revision, then add deterministic tests for input ayah order, parsed output order, and rendered line order using representative multi-ayah lines.
- Confirm whether the apparent order issue originates in parser output, Flutter bidi treatment of WidgetSpan placeholders, page-spread navigation, or the source page/line data.
- Complete full 604-page visual/reference QA; structural page-map coverage alone is insufficient.
- Resolve QCF font and page-data rights before public distribution.

## Next recommended action

Reproduce the reported page 1/page 2 symptom with the exact locked QCF 0.1.1 code and a trusted reference image, then add a failing regression test before applying the smallest isolated renderer fix.

## Instructions for the next agent

- Relevant files/contracts: `lib/features/quran/data/qcf_hafs_renderer_adapter.dart`, `lib/features/quran/presentation/hafs_mushaf_screen.dart`, `test/quran/qcf_hafs_renderer_adapter_test.dart`, QCF `parseLine`, `QuranLine`, and `QuranPageView`.
- Do not change: canonical Tanzil text, QCF dependency, `pubspec.yaml`, router, Drift schema/migrations, source registry, or CI without integration-lead approval.
- Required prerequisite: exact 0.1.1 source verification and reproducible screenshot/reference evidence.
