# Agent handoff — issue 26

## Identity

- Date: 2026-11-28
- Agent role/ID: Integration lead — P0 Quran integrity investigation
- GitHub issue: https://github.com/7thramzy/atharapp/issues/26
- Branch: `agent/quran/26-mushaf-integrity`
- Base commit: `535e7d5a1c9320d8836fa95554a80c6f1f26c444`
- Investigation checkpoint commit: pending
- Reserved paths: `lib/features/quran/**`, `test/quran/**`; issue-specific handoff only under `docs/agents/handoffs/`

## Result

- Status: IMPLEMENTED IN BRANCH — screenshot symptom reproduced; isolated QCF parsed-line ordering correction and 604-page order regression test added. CI and visual confirmation are still pending.
- Confirmed screenshot evidence (user supplied, 1920×1020 preview):
  - The two-page spread placement itself is correct: page 1 (Al-Fatihah) is on the right and page 2 (Al-Baqarah) is on the left.
  - The reported defect is inside the first text line of page 2, not the left/right placement of the pages.
  - On the Al-Baqarah page, the first line visually places the segment `ذَٰلِكَ الْكِتَٰبُ لَا رَيْبَ فِيهِ هُدًى...` on the right side and the `الٓمٓ` segment at the far left, so the visual reading sequence is reversed across the line. In a right-to-left Mushaf line, `الٓمٓ` must occur at the right/start of the line, followed by its ayah marker, then the continuation beginning `ذَٰلِكَ الْكِتَٰبُ...` toward the left.
  - This is a genuine visible ordering defect in the supplied screenshot. Do not describe it as a page-spread RTL defect: the spread placement is correct.
  - The first-page Al-Fatihah layout in the same screenshot appears in expected reading order at this scale; that does not prove all lines/pages are correct.
- Code findings:
  - The current Athaar adapter sets no custom line ordering; it initializes QCF metadata and exposes page-boundary lookups.
  - Existing tests validate all 6,236 ayah-to-page lookups, 604 populated pages, and contiguous page start/end boundaries. They do not validate visual ayah ordering within a rendered line, line-to-line ordering, glyph placement, or basmala placement.
  - In inspected QCF upstream source, `GetPage._generateLines()` appends ayah segments in source-list order. `parseLine()` iterates `line.ayahs.toList().reversed` before `QuranLine` wraps each ayah in a `WidgetSpan` inside an RTL `RichText`.
  - The parser reversal matches the observed symptom: source lines are assembled in Quran order, `parseLine()` reverses their ayah list, and `QuranLine` embeds the result in an RTL `RichText`. The adapter now reverses only the cached parsed-ayah presentation list back to source order after repository loading. This does not alter source text, QCF glyphs, or page metadata. The test checks all cached lines against the source page data across 604 pages. The exact archive source was not downloaded independently; `pubspec.lock` pins version 0.1.1 with SHA-256 `335ec9188d8a35114d4c7d0f3a578d4b3fed478aaa6dc34b6bedeae05228f124`, while the inspected upstream source provides the internal API/implementation shape. CI must confirm API compatibility.
  - The page spread uses an RTL Row and intentionally puts odd page left / even page right. In this screenshot page 1 is on the right and page 2 on the left, which is correct.
  - No canonical Tanzil text or QCF dependency was changed. A narrowly scoped reversal of parsed presentation entries was added to counter the package parser's reversal before RTL rendering.

- Exact paths changed: `lib/features/quran/data/qcf_hafs_renderer_adapter.dart`, `test/quran/qcf_hafs_renderer_adapter_test.dart`, and this handoff.
- Decisions made: classify the screenshot as a confirmed within-line ordering defect on page 2; preserve Quran source text and avoid speculative code edits until the exact package source and a regression test establish the minimal safe fix.

## Validation

| Command or check | Result | Notes |
|---|---|---|
| Inspect current main commit and repository tree | PASS | Base is `535e7d5a1c9320d8836fa95554a80c6f1f26c444` |
| Inspect Athaar QCF adapter and existing tests | PASS | Existing page-map coverage confirmed |
| Inspect QCF upstream parser and page construction source | PARTIAL | Upstream main inspected; exact source revision for pub package 0.1.1 not yet established |
| User screenshot visual inspection | PASS | Confirms page 2 first-line ayah segments are in wrong visual order; spread page placement itself is correct |
| Flutter format/analyze/tests | PENDING | New branch commits have not yet produced a CI run at last check |
| Exact package-version reproduction | PARTIAL | Lockfile version and checksum confirmed; archive source not independently retrieved |
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

- Exact QCF 0.1.1 source revision correspondence remains to be established.
- The new test checks parsed ayah order against source order for every cached line across all 604 pages, including multi-ayah lines. A rendered screenshot and physical-device check are still required to prove visual layout.
- Confirm whether the symptom originates in parser reversal, Flutter bidi treatment of WidgetSpan placeholders, or source line data.
- Complete full 604-page visual/reference QA; structural page-map coverage alone is insufficient.
- Resolve QCF font and page-data rights before public distribution.

## Next recommended action

Run CI on the current branch. If the ordering test passes, build a preview and visually compare page 2 line 1 with an approved Mushaf reference. If the rendered order remains wrong, inspect Flutter WidgetSpan bidi behavior before changing any further ordering logic.

## Instructions for the next agent

- Relevant files/contracts: `lib/features/quran/data/qcf_hafs_renderer_adapter.dart`, `lib/features/quran/presentation/hafs_mushaf_screen.dart`, `test/quran/qcf_hafs_renderer_adapter_test.dart`, QCF `parseLine`, `QuranLine`, and `QuranPageView`.
- Do not change: canonical Tanzil text, QCF dependency, `pubspec.yaml`, router, Drift schema/migrations, source registry, or CI without integration-lead approval.
- Required next step: CI pass plus rendered screenshot comparison for page 2 line 1 and representative multi-ayah lines.
