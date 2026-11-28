# OpenDua v0.0.4 — source and rights review for Athaar

**Review date:** 2026-11-28  
**Decision:** CONDITIONAL CANDIDATE — NOT YET APPROVED FOR PRODUCTION IMPORT  
**Intended use:** Offline Arabic adhkar text, with optional English editorial fields kept separate.

## Exact source

- Pinned catalogue: https://opendua.org/v0.0.4/catalogue.json
- Downloads and release description: https://opendua.hdfund.org/downloads/
- Data licence: https://opendua.org/licence/data
- Methodology: https://opendua.org/methodology
- Changelog: https://opendua.org/changelog
- Dataset version: 0.0.4, released 2026-09-09
- Published catalogue counts: 267 entries, 132 chapters, 262 dua records, 249 recordings.
- The catalogue is versioned and immutable at the pinned path.

## Rights boundary

OpenDua publishes its independently authored English translation, transliteration, editorial metadata and dataset structure under CC BY 4.0. Its licence explicitly does **not** claim ownership of the underlying Quranic, hadith or supplication text. The source collection is Hisn al-Muslim by Sa'id ibn Ali ibn Wahf al-Qahtani.

Required attribution, preserved verbatim:

> OpenDua dataset v0.0.4 (https://opendua.org), by Ihsan Labs at the Human Development Fund. Based on Hisn al-Muslim by Sa'id ibn Ali ibn Wahf al-Qahtani. OpenDua editorial text, dataset structure and the recitation by Muhammad Jumah are licensed CC BY 4.0. OpenDua makes no ownership claim over the underlying religious texts.

The text-data licence does not by itself establish rights to third-party underlying works. The app must preserve source references and must not imply OpenDua owns the religious text. Audio is separately licensed and is excluded from this initial text-only import.

## Scholarly and content-quality boundary

The publisher's methodology states that entries carry source references and that reported gradings retain their named authorities; OpenDua does not issue its own hadith gradings. The v0.0.4 changelog says editorial review state and internal rights profiles are not exposed in normal public resources. Therefore:
- Treat the dataset as a structured, sourced candidate, not as a scholarly certification.
- Do not infer a hadith grade when the record has none.
- Preserve every variant and its distinct repetition count.
- Keep instructions, narrations and actual recitation text as separate content blocks.
- Do not merge morning and evening variants or infer that a chapter is a complete independent daily wird.
- Any item with missing/ambiguous reference mapping remains excluded from the approved core until human review against the named primary source.
- Arabic text must be reviewed for exactness, diacritics, punctuation, and block boundaries before production approval.

## Import decision

1. Use the pinned v0.0.4 catalogue as the preferred research/import candidate, not a live mutable endpoint.
2. Before bundling the full catalogue, acquire the exact file in the repository build environment and record its SHA-256, byte count, retrieval timestamp, and complete licence notice.
3. Build a deterministic parser that preserves IDs, chapter order, variations, ordered steps, item boundaries, repetition metadata, references, and attribution.
4. Import only reviewed Arabic recitation items to the initial offline library. Keep translations/transliteration optional and visibly attributed to OpenDua.
5. Do not bundle audio in the first pass. It is not required for the offline text experience.
6. Require a qualified human content review of the morning/evening and post-prayer subsets before labeling them "verified" in the UI.
7. Keep the source version and checksum in app metadata so later updates are explicit, reviewable, and reversible.

## App mapping

The existing Athaar local schema has adhkar categories, items, and progress tables. Its current item schema is too small to faithfully represent OpenDua's ordered multi-step structures, variations, item-level source references, and dataset version. A production import should extend the schema through a dedicated migration rather than flattening the catalogue into one text field.

Required fields for the expanded model:
- stable source entry ID and dua ID;
- source dataset/version and checksum;
- chapter/category and original order;
- variation ID;
- ordered content blocks with type (recitation, instruction, narration);
- Arabic text and optional separately licensed/editorial translation/transliteration;
- target repetition count per recited item;
- all source references and named grading authorities, if present;
- review state and reviewer/date;
- required attribution key.

## References checked

- OpenDua Downloads: https://opendua.hdfund.org/downloads/
- OpenDua Data Licence: https://opendua.org/licence/data
- OpenDua Methodology: https://opendua.org/methodology
- OpenDua Changelog: https://opendua.org/changelog

**Release gate remains open:** no production seed data is approved by this dossier alone.