# Tafsir and translation source review

**Review date:** 2026-11-25  
**Scope:** Display inside Athaar, online access, offline storage, redistribution, and required source attribution.

## Decision summary

| Resource | Decision | Reason |
|---|---|---|
| QuranEnc translation catalogue and per-ayah API | Approved for live display subject to source terms and edition metadata | Public API documents translations, versions, titles, descriptions, and per-ayah translation/footnotes. QuranEnc permits re-publication of its translation content under stated conditions. |
| QuranEnc tafsir inside the app | Not approved for in-app copying in this implementation | The current published OpenAPI specification documents translations, not a tafsir endpoint. General site terms do not identify a specific tafsir file/edition and its complete reuse terms. Link to the publisher instead. |
| QUL Tafsir Muyassar Arabic, resource 38 | Blocked for embedding | Its resource-specific licence page states that copyright information is not available. |
| QUL Tafseer Al-Saadi Arabic, resource 24 | Blocked for embedding | Its resource-specific licence page states that copyright information is not available. |
| QUL Arabic Al-Mukhtasar, resource 251 | Blocked for embedding | Its resource-specific licence page states that copyright information is not available. |

## Approved translation integration

Use QuranEnc's documented public API:

- Translation catalogue: `GET https://quranenc.com/api/v1/translations/list?localization=ar`
- Language-filtered catalogue: `GET https://quranenc.com/api/v1/translations/list/{language}?localization=ar`
- One ayah: `GET https://quranenc.com/api/v1/translation/aya/{translation_key}/{sura_number}/{aya_number}`

The runtime implementation in `lib/features/quran_study/data/quran_study_repository.dart` reads each edition's key, title, language, version, description, direction, and last-updated timestamp. It does not invent a translator name where the publisher has not supplied one.

Display conditions:

1. Keep the published translation and footnotes unchanged.
2. Show QuranEnc as publisher/source beside every displayed edition.
3. Show the exact version supplied by the catalogue.
4. Keep the publisher's edition/translator description visible.
5. Refresh the catalogue from the publisher; do not silently freeze an old edition.
6. Do not place inappropriate advertisements beside Quran translations.
7. Submit corrections to the publisher; do not silently edit the text in Athaar.

The initial integration is live/on-demand and is not an offline copy or a bundled translation database. Any later offline import must pin a particular edition, verify its exact licence and metadata, preserve the required attribution, and include an update process.

## Tafsir decision and next gate

The current QuranEnc OpenAPI file describes itself as a read-only API for translations of Quran meanings. Its declared paths contain translations, ayah translations, surah names, and notes; it does not declare tafsir endpoints. QUL is a downloadable resource library rather than a hosted public API. Its individual Tafsir Muyassar, Tafseer Al-Saadi, and Arabic Al-Mukhtasar records each say copyright information is unavailable.

Therefore the Athaar Tafsir tab currently provides clearly labelled links to the original publishers/catalogues; it does not copy commentary text into the application. This is intentional rights protection, not a hidden or fake in-app tafsir implementation.

To enable in-app tafsir, obtain written permission or an exact machine-readable licence for a named edition that explicitly covers redistribution in a mobile application, then record author, editor, publisher, source URL, edition/version, licence, attribution text, and update policy here before importing it.

## Sources reviewed

- QuranEnc API and OpenAPI: https://quranenc.com/ar/home/api and https://quranenc.com/openapi.json
- QuranEnc terms: https://quranenc.com/en/home/about/conditions
- QUL Tafsir resources: https://qul.tarteel.ai/resources/tafsir
- QUL Tafsir Muyassar resource 38: https://qul.tarteel.ai/resources/tafsir/38/licence
- QUL Tafseer Al-Saadi resource 24: https://qul.tarteel.ai/resources/tafsir/24/licence
- QUL Arabic Al-Mukhtasar resource 251: https://qul.tarteel.ai/resources/tafsir/251/licence
