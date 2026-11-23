# Quran Arabic text rights dossier

**Review date:** 2026-11-24  
**GitHub issue:** #2  
**Scope:** Tanzil Quran Text, Uthmani v1.1; rights review only. No Quran data file was downloaded or committed in this task.

## Decision

**APPROVED for verbatim display and redistribution inside Athaar**, including offline app bundles, provided every condition below is enforced. This is not approval to edit, normalize, transliterate, or otherwise transform the canonical Arabic text.

## Exact resource

- Publisher/source: Tanzil Project.
- Resource: Tanzil Quran Text — Uthmani, version 1.1.
- Official download page: https://tanzil.net/download/
- Official license/terms: https://tanzil.net/docs/Text_License
- Official version history: https://tanzil.net/docs/text_updates
- Version 1.1 release date shown by Tanzil: 2021-02-12.
- License stated by Tanzil: Creative Commons Attribution 3.0, with additional explicit conditions in its text-use notice.
- Exact filename, download options, retrieval timestamp, byte count, SHA-256, and embedded notice from the selected download: **PENDING acquisition**. The issue explicitly excludes downloading or committing content binaries, so these values must be captured in the separate dataset-import task, not guessed here.

## Rights and conditions

Tanzil's official terms permit copying and distributing verbatim copies and use in websites and applications. The source must be clearly identified as Tanzil Project, a link to tanzil.net must be provided, and the complete copyright notice must accompany verbatim copies and files containing a substantial portion. Tanzil expressly prohibits changing the text.

The official updates page identifies version 1.1 and its release date. The actual downloaded file may contain a more specific copyright year or notice block than the generic web license page. **Preserve the exact notice embedded in the acquired file byte-for-byte; do not replace it with a reconstructed notice.**

### Athaar implementation requirements

1. Bundle only the exact Uthmani v1.1 edition acquired from the official download page.
2. Keep the canonical Arabic field unchanged. Do not strip tashkeel, pause marks, tatweel, sajda signs, or other characters.
3. Search normalization, if required, must be a separate derived field and must never replace canonical display text.
4. Display Tanzil Project as the source and provide a clickable https://tanzil.net link in the reader and the Sources and Licenses screen.
5. Retain the full publisher notice in the bundled data asset and in any redistributed file containing a substantial portion.
6. Record the exact selected download options, source URL, retrieval date, file size, SHA-256, version, and notice in the content manifest.
7. Validate all 114 surahs and 6,236 ayahs, ordering, uniqueness, and text non-emptiness against the importer contract. These structural checks do not replace human review or source hash verification.
8. Do not silently convert the dataset to another script or mix editions.

## Distribution and commercial compatibility

The published terms expressly permit use in applications and verbatim distribution. The page does not state a non-commercial-only restriction. The stated CC BY 3.0 license is compatible with attribution-based redistribution, including commercial contexts, subject to the no-change rule and the explicit notice/source-link requirements. Athaar must not imply Tanzil endorses the app.

## Verification record

| Check | Result |
|---|---|
| Official source and license page reviewed | PASS |
| Version 1.1 history reviewed | PASS |
| App use expressly permitted | PASS |
| Verbatim redistribution expressly permitted | PASS |
| No-modification rule recorded | PASS |
| Attribution and source link recorded | PASS |
| Exact selected file and download options acquired | NOT RUN — separate import task |
| Exact source SHA-256 recorded | PENDING |
| Embedded notice compared and preserved | PENDING |
| Importer integrity checks run on acquired source | PENDING |

## References

- Tanzil Text License: https://tanzil.net/docs/Text_License
- Tanzil Text Updates: https://tanzil.net/docs/text_updates
- Tanzil Download: https://tanzil.net/download/

**Retrieval date:** 2026-11-24.  
**Rights status:** APPROVED for verbatim app use; exact-file integrity gate remains open.
