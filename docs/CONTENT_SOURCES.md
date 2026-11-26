# Athaar content sources and licensing register

**Last reviewed:** 2026-11-27  
**Purpose:** Record which religious text, tafsir, translation, font, layout, audio, and other content sources may be used in Athaar.

This document is a conservative engineering decision register, not legal advice. A source is not cleared merely because it is publicly downloadable, appears in a permissively licensed repository, or is used by another Quran app.

## Status meanings

- **APPROVED:** The exact source/version and intended Athaar use are supported by a documented license/permission and required notices are defined.
- **CONDITIONALLY APPROVED:** The source may be used only within explicit conditions. The implementation must enforce those conditions.
- **RESEARCH REQUIRED:** A source is useful for discovery but the exact resource rights are not yet verified.
- **BLOCKED:** Do not copy, bundle, redistribute, train on, or use the resource until written permission or a suitable license is obtained.
- **REJECTED:** Do not use this candidate for Athaar.

## 1. Quran Arabic text

### Primary offline candidate — Tanzil Quran Text, Uthmani v1.1

**Status: APPROVED FOR VERBATIM IN-APP USE, subject to the conditions below.**

- Source: https://tanzil.net/download/
- License/terms: https://tanzil.net/docs/Text_License
- Edition shown by the source: Uthmani, version 1.1.
- Terms allow verbatim copies and use in any website or application.
- The text must not be changed.
- Clearly identify Tanzil Project as the source and provide a link to tanzil.net so users can follow updates.
- Preserve the complete copyright/license notice provided with the downloaded text in every copy or file containing a substantial portion.
- Do not silently normalize, rewrite, remove diacritics, change pause marks, merge tokens, or modify the canonical Arabic field.
- Search normalization must be calculated and stored in a separate field/index; it must never replace or overwrite the canonical Quran text.
- The exact downloaded version, options, file hash, retrieval date, and preserved notice must be recorded in a content manifest before implementation.
- Do not mix Quran text with UI labels or other text in a way that could be mistaken for Quran text.

Tanzil's published terms explicitly permit use in apps while requiring unchanged text, attribution, and a source link. This makes it a better fit for the first offline bundle than the Quran Foundation API data.

### Quran Foundation Content APIs

**Status: NOT APPROVED AS A STATIC APP BUNDLE. ONLINE USE ONLY AFTER API/TERMS REVIEW.**

- API documentation: https://api-docs.quran.foundation/
- Developer terms: https://api-docs.quran.com/legal/developer-terms/
- Quran Foundation permits display within the end-user application subject to its terms.
- Its developer terms restrict caching/storage beyond one week unless an expressly permitted offline-sync exception applies.
- Raw QF content or API data must not be separately redistributed as a dataset, download, package, or public repository asset.
- Do not use Quran Foundation content as a prepackaged static Quran database in the app.
- If an online integration is considered later, implement the applicable Content Sync requirements, refresh/retention controls, required attribution, privacy policy obligations, and rate limits.
- Quran Foundation content must not be used to train, fine-tune, evaluate, or otherwise develop an AI/ML model under the current developer terms.

Do not combine the Tanzil offline dataset with Quran Foundation data unless a separate architecture and source-integrity review approves that exact combination.

## 2. Translations of meanings

**Status: APPROVED FOR ON-DEMAND API DISPLAY UNDER EACH EDITION'S CONDITIONS; NO OFFLINE TRANSLATION BUNDLE APPROVED.**

- Every translation is a separate copyrighted edition with its own translator, publisher, rights holder, and license.
- QUL can be used to discover translations, but its general repository MIT license does not automatically license translation contents.
- QUL says commercial use is possible only after reviewing the specific resource license; some resources have restrictions or require attribution.
- Quran Foundation translations inherit Quran Foundation's content and storage restrictions.
- Do not assume that a translation is public domain because the original translator died long ago; modern editing, translation, typesetting, digitization, and publisher rights may differ.
- The UI must label translated content as a translation of meaning and display it in a separate layer from Arabic Quran text.

Current Athaar behavior is on-demand display through QuranEnc. The API catalogue supplies edition key, publisher title, language, version, description, direction and update metadata; these are shown with the ayah translation. The app does not bundle a translation database. Every edition remains subject to its own publisher terms. Do not add local storage or offline caching unless the exact edition's licence explicitly permits it.

## 3. Tafsir and Quranic commentary

**Status: ONE EXACT ARABIC EDITION APPROVED FOR VERBATIM ON-DEMAND DISPLAY; OTHER EDITIONS REMAIN RESEARCH REQUIRED.**

Selected in-app edition: **Al-Jami' Al-Wajiz fi Tafsir Ay al-Kitab al-Aziz**, authored by Sheikh Dr. Ayman Fathih Al-Amer, pinned to `spa5k/tafsir_api@v1.2.3`. The author's separate text licence is CC BY-ND 4.0. Athaar displays the selected ayah verbatim with author, source and licence attribution. No offline tafsir database is bundled or retained. The API repository's MIT software licence is not treated as a licence for third-party text.

Potential discovery catalogue: https://qul.tarteel.ai/resources/tafsir

Rules:

- QUL is a resource management/download platform, not a blanket license for all tafsir.
- Review each exact record and edition separately, including language, editor/translator, rights holder, resource license, attribution, commercial use, and offline distribution.
- Do not copy tafsir databases from Quran Offline Mobile until their exact QUL resource records and terms are checked.
- The MIT license in the QUL software repository covers the software under that repository's license; it does not automatically cover third-party tafsir data.
- Do not convert a commentary into AI-generated religious guidance without a reviewed content policy and reliable citations.
- A missing license field or “copyright information unavailable” means BLOCKED for bundling until the rights holder gives permission.

Relevant QUL guidance:
- https://qul.tarteel.ai/faq
- https://qul.tarteel.ai/docs/getting-started
- https://github.com/TarteelAI/quranic-universal-library/issues/891
- https://github.com/TarteelAI/quranic-universal-library/issues/957

The issues are examples of licensing questions raised by developers; an unanswered issue is not a license grant.

## 4. UI font — Cairo

**Status: APPROVED, subject to preserving OFL notices.**

- Source: https://github.com/Gue3bara/Cairo
- License: SIL Open Font License 1.1.
- Use for normal Arabic/Latin interface typography.
- Include the OFL license text and required copyright/author notices with the font files in the distributed application/repository.
- Do not sell the font file by itself.
- Do not apply Cairo as a substitute for a verified Quran script font unless Quran rendering is separately validated.

## 5. Quran script font and Mushaf layout

### King Fahd Glorious Quran Printing Complex (KFGQPC)

**Status: CONDITIONALLY APPROVED FOR DIGITAL APPLICATION/SOFTWARE USE.**

- Official source: https://qurancomplex.gov.sa/mushaf-printing
- Official developer platform announcement: https://qurancomplex.gov.sa/مجمع-الملك-فهد-لطباعة-المصحف-الشريف-يتيح-منصة-لخدمة-مطوري-برمجيات-القرآن-الكريم-وعلومه/
- The Complex's published rights for its digital Madinah Mushaf edition permit use in computer programs/software and digital publishing, in addition to other listed uses.
- Use only the exact asset downloaded from an official Complex source or a verified official distribution.
- Preserve original files unchanged unless the specific official terms permit a particular transformation.
- Record exact file, version, hash, source URL, and the downloaded rights statement before bundling.
- The official page distinguishes digital software uses from certain physical Mushaf printing/sale restrictions. Athaar is a digital app, not a printed Mushaf publishing business.

### QUL QPC V2/V4, SurahNameV2, glyph and page-font assets

**Status: RESEARCH REQUIRED.**

- QUL provides several script/font and Mushaf layout resources.
- Each record has its own rights and data provenance.
- Do not assume that the KFGQPC rights automatically cover every QUL-created glyph, page layout, font conversion, or image set.
- Prefer the official KFGQPC file where it satisfies the rendering needs; otherwise complete the QUL resource-level rights review first.

## 6. Recitation audio

### AlQuran Cloud / Islamic Network CDN

**Status: CONDITIONALLY APPROVED FOR USER-INITIATED STREAMING AND PRIVATE OFFLINE LISTENING FOR PERSONAL/EDUCATIONAL USE.**

- Terms: https://alquran.cloud/terms-and-conditions
- CDN documentation: https://alquran.cloud/cdn
- The provider permits streaming, embedding and downloading for personal and educational use. Recordings remain copyrighted by their reciters/rightsholders, who may request removal.
- Athaar now supports user-initiated streaming and whole-surah downloads. Native builds store requested tracks only in the app-private support directory; playback checks local storage first, then streams the selected ayah when needed.
- Users can delete saved audio. Interrupted downloads retain completed tracks for resumption; incomplete temporary files are discarded.
- No audio file is bundled in the app, uploaded, shared, exported, re-hosted, mirrored, remixed, or used for AI/ML training/evaluation.
- Display the selected reciter, edition identifier and AlQuran Cloud / Islamic Network attribution. Disable a reciter/edition when access is withdrawn or requested by the rights holder.
- Re-check the provider's current terms and the exact reciter edition before launch. Do not assume personal/educational rights extend to subscriptions, advertising, commercial redistribution or monetized access.

### EveryAyah

**Status: BLOCKED UNTIL RECORDING-SPECIFIC RIGHTS ARE DOCUMENTED.**

- Website: https://everyayah.com/
- A public MP3 URL or availability for download is not proof of a distribution license.
- The site does not provide a clear site-wide recording license in the sources reviewed for this audit.
- Do not mirror, bundle, cache for redistribution, or make this the production audio provider until each recording's rights holder and permission are established.

### QUL recitation resources

**Status: RESEARCH REQUIRED.**

- Review every exact recitation record and its rights holder, license, allowed uses, attribution, caching, offline download, and commercial-use conditions.
- The QUL software license does not automatically license the audio assets.
- Do not use a recitation as AI training material merely because it is downloadable.

## 7. AI datasets and recitation assessment

- Audio used for playback is not automatically licensed for model training, evaluation, voice identification, or biometric processing.
- Do not train on Quran Foundation content under its developer terms.
- The Sanad research repository uses AGPL-3.0. It is a research reference only; do not copy its code into Athaar without a deliberate open-source licensing decision.
- Any speech model dataset must have its own rights, consent, intended-use, and redistribution review.
- Model evaluation must use authorized recordings and qualified human review. Publicly available recordings are not automatically a permitted benchmark.

## 8. Source attribution inside Athaar

The in-app “حول التطبيق والمصادر” screen is implemented. Before public release, verify its links, source metadata and wording against the exact versions being shipped. It must display, for every shipped content asset:

- Source/provider name.
- Author, translator, reciter, or rights holder where known.
- Exact edition/version.
- License/permission and source link.
- Required copyright notice and attribution.
- Any meaningful use limitation.

Attribution strings should be sourced from the reviewed register/content manifest wherever possible; do not improvise credit wording or claim that Athaar owns the materials.

## 9. Content approval record

No content asset may move into the production bundle until it has a resource-level record with:

- Stable source ID.
- Title and content type.
- Author/translator/reciter/rights holder.
- Exact edition/version/file.
- Canonical source and download URL.
- Retrieval date and SHA-256.
- License identifier and license URL or written permission reference.
- Allowed uses: display, offline bundle, user download, server hosting, commercial use, adaptation, AI processing.
- Required attribution and takedown contact.
- Review state and reviewer.

A changed file hash or source edition requires a new review. Unknown, disputed, or withdrawn rights switch the resource to BLOCKED.
