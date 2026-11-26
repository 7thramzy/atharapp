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

## Approved Arabic tafsir integration

The selected in-app edition is **Al-Jami' Al-Wajiz fi Tafsir Ay al-Kitab al-Aziz**, authored by Sheikh Dr. Ayman Fathih Al-Amer.

The author's source repository includes an explicit **CC BY-ND 4.0** licence. Its Arabic licence summary permits copying and redistribution in any medium and for any purpose, including commercial use, provided the author is credited and the text is not modified. The API maintainer documents this edition as imported from the author's JSON export and redistributed unchanged.

The app requests one ayah at a time from the pinned static release:

`https://cdn.jsdelivr.net/gh/spa5k/tafsir_api@v1.2.3/tafsir/ar-tafsir-al-jami-al-wajiz/{surah}/{ayah}.json`

Runtime behavior:

1. The study screen requests tafsir by the exact surah/ayah selected in the Hafs Mushaf.
2. The app verifies that the returned surah and ayah numbers match the requested location.
3. The text is shown verbatim as plain text. It is not paraphrased, normalized, transformed, summarized, or passed through an HTML renderer.
4. The author's name, source repository, release version, and CC BY-ND 4.0 licence are shown in the attribution panel.
5. The app does not bundle this content or retain an offline copy in this implementation.
6. If an ayah has no entry or the source is unavailable, the screen reports that condition instead of inventing text.

The `MIT` licence of the API repository applies to the repository's software/code; it is **not** treated as the tafsir text licence. The tafsir is used under the author's separate CC BY-ND 4.0 grant.

The QUL editions listed above remain blocked for embedding because their individual resource pages do not provide adequate rights information. The Quran Foundation API remains a future alternative if Athaar later receives its app credentials and sets up a secure server-side integration.

## Next gate for additional tafsir editions

Only add another edition after confirming its individual text licence. For CC BY-ND material, keep the text unchanged and display the exact author/source attribution and licence link. A repository-level software licence or the fact that a text is available on a CDN does not by itself grant rights to the content.

## Sources reviewed

- QuranEnc API and OpenAPI: https://quranenc.com/ar/home/api and https://quranenc.com/openapi.json
- Quran Foundation Content API v4: https://api-docs.quran.com/docs/content_apis_versioned/4.0.0/content-apis/
- Quran Foundation app access request: https://api-docs.quran.com/request-access/
- Quran Foundation developer terms: https://api-docs.quran.com/legal/developer-terms/
- Author's Al-Jami' Al-Wajiz source and explicit CC BY-ND 4.0 licence: https://github.com/yamanamr/quran-tafsir-jami-wajiz and https://github.com/yamanamr/quran-tafsir-jami-wajiz/blob/main/LICENSE
- Pinned data release and edition source: https://github.com/spa5k/tafsir_api/tree/v1.2.3
- QuranEnc terms: https://quranenc.com/en/home/about/conditions
- QUL Tafsir resources: https://qul.tarteel.ai/resources/tafsir
- QUL Tafsir Muyassar resource 38: https://qul.tarteel.ai/resources/tafsir/38/licence
- QUL Tafseer Al-Saadi resource 24: https://qul.tarteel.ai/resources/tafsir/24/licence
- QUL Arabic Al-Mukhtasar resource 251: https://qul.tarteel.ai/resources/tafsir/251/licence
