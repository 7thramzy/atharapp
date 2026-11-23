# Reuse and license register

The canonical content rights register is [docs/CONTENT_SOURCES.md](../CONTENT_SOURCES.md). This file preserves the code-reuse decisions for upstream starter repositories.

## Code repositories

| Source | Code license | Athaar decision |
|---|---|---|
| [Quran Offline Mobile](https://github.com/hndrwn-dk/quran-offline-mobile) | MIT, copyright Hendrawan (2025) | Selective source-code adaptation only. Preserve notice and record exact upstream commit/files. |
| [Flutter Boilerplate](https://github.com/aazirani/flutter_boilerplate) | MIT, copyright Amin Azirani (2026) | Architectural reference and selective source-code adaptation. Preserve notice for copied/substantial portions. |
| [Sanad](https://github.com/harounRhim/sanad) | AGPL-3.0 | Research reference only. Do not copy or link its code into Athaar without a separate licensing decision. |
| [Quranic Universal Library software](https://github.com/TarteelAI/quranic-universal-library) | MIT for the QUL software repository | The software license does not grant a blanket license to every dataset/resource managed by QUL. |

## Content is not code

Every Quran text, translation, tafsir, Mushaf layout, font, recitation, icon, and image requires an independent resource-level record. The MIT license of a source application never overrides the rights of third-party content it references.

Current decisions:

- Tanzil Uthmani v1.1 may be bundled verbatim with the complete source notice and link; text modification is not allowed.
- Quran Foundation API content is not approved as a static build-time dataset; its developer terms impose storage/sync and redistribution restrictions.
- QUL is a resource discovery/download catalogue. Verify each exact resource record and intended use.
- Cairo UI font is OFL 1.1; ship its license notice.
- KFGQPC official digital Mushaf/font assets are a preferred source for app use, subject to exact asset/version and rights notice recording.
- Tafsir and translations are not yet approved as datasets.
- AlQuran Cloud/Islamic Network recitations are a conditional stream-only candidate; no audio bundle in the MVP and reciter-level rights must be recorded.
- EveryAyah is blocked until recording-specific distribution rights are documented.

## Reuse workflow

For every copied source-code portion, record:

- Original repository and exact commit.
- Exact upstream file paths.
- License identifier and copyright notice.
- Changes made and Athaar paths receiving the code.
- Test results and reviewer.

For every content asset, record the full resource metadata specified in docs/CONTENT_SOURCES.md, including the source file hash and attribution. Unknown or withdrawn rights mean the asset is blocked.

Athaar's own repository-wide license has not been selected. Do not add a blanket license until the owner decides the intended distribution model.
