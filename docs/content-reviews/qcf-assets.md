# QCF package asset provenance review

**Review date:** 2026-11-28  
**Target:** Athaar dependency `qcf_quran_plus 0.1.1`  
**Decision:** BLOCKED for public redistribution pending exact asset provenance.

## What was inspected

- pub.dev package: https://pub.dev/packages/qcf_quran_plus/versions/0.1.1
- Repository: https://github.com/hussein12347/qcf_quran_plus
- Repository manifest: https://raw.githubusercontent.com/hussein12347/qcf_quran_plus/main/pubspec.yaml
- Repository license: https://raw.githubusercontent.com/hussein12347/qcf_quran_plus/main/LICENSE
- Official Complex source: https://qurancomplex.gov.sa/mushaf-printing

The package repository tree at the inspected default branch contains 604 files under `assets/fonts/qcf_tajweed/`, three additional TTF font files (`HafsSmart_08.ttf`, `QCF4_BSML.ttf`, `arsura.ttf`), and `assets/surah_banner.png`.

The only license file found in the repository tree is a root MIT license naming the package author. It covers the package software subject to its terms; it does not identify the rights holder, source release, or license for each embedded font or image. No separate font-specific license, asset attribution file, provenance manifest, or file-by-file mapping to the King Fahd Complex source was found.

The README describes the renderer as using the “official QCF (Hafs) font”, but does not identify a source release, official download URL, asset hashes, or a reproducible mapping to Complex files. The pub.dev publisher is marked unverified. These facts do not prove that the assets are unauthorized; they mean that the exact permission chain has not been established.

## Rights distinction

KFGQPC publishes a digital Madinah Mushaf edition and permits its official digital files to be used in software and digital publishing under the Complex's published usage rights. That permission is relevant to files obtained from the official Complex distribution. It cannot be automatically extended to a third-party package's assets without proving that the exact binaries are the same official files or are otherwise licensed.

## Release decision

- Do not claim that all qcf_quran_plus assets are MIT-licensed.
- Do not redistribute public application binaries while this provenance gate remains open.
- Preserve the package MIT notice for the code.
- Do not remove, rename or transform embedded font files as a workaround for missing provenance.

## Closure paths

1. Obtain written confirmation from the package maintainer identifying the official KFGQPC release, source URL, original terms, and reproducible file hashes/mapping for every font and the banner; or
2. Replace the embedded assets with direct official KFGQPC files, preserving the original files, terms, attribution and checksums, and rerun all 604-page rendering tests.

A package-maintainer statement should be retained in the repository with its date and source. If no verifiable response is obtained, use path 2 or keep the feature out of the public distribution.

## Audit limitation

This review inspected the public repository tree and published manifest/license text. It did not download and compare all 608 binary assets against an official KFGQPC archive. Therefore it is a provenance review, not a byte-for-byte authenticity certification.


## Official King Fahd Complex source verification — 2026-11-28

The official Complex publication page was rechecked on 2026-11-28:

- Official page: https://qurancomplex.gov.sa/mushaf-printing
- Edition: Madinah Mushaf, Hafs narration, digital vector edition (Illustrator)
- Published size: 423.3 MB
- Published SHA-256: `C2FA8D93A7C4F689B58EB32756E1AE56CD1B7CE4826F63E09723BE8B092224FB`
- The Complex's published usage section explicitly permits free use of this digital edition for personal work, government/private/non-profit institutions, print publishing, desktop publishing, media, websites, computer programs and similar uses, inside and outside Saudi Arabia.
- The Complex states that this approved digital production was reviewed by its scientific and Sharia committees and supervised by the Complex calligrapher; this is a statement about the Complex's source edition, not a certification of Athaar itself.
- Official computer-publishing product page: https://qurancomplex.gov.sa/mushaf-computer-publishing (version 3.16; published SHA-256 `16E7DC5E91C6118F9FCEB87244862AFAC2A616ADC6472ADAC84E2836AC39E28A`). It describes the Hafs/Warsh computer fonts but is a Windows publishing application, not a ready-made Flutter asset bundle.
- Official computer-font catalogue: https://qurancomplex.gov.sa/fonts
- Developer platform announcement: https://qurancomplex.gov.sa/مجمع-الملك-فهد-لطباعة-المصحف-الشريف-يتيح-منصة-لخدمة-مطوري-برمجيات-القرآن-الكريم-وعلومه/

### Updated decision

The official digital vector edition has a published permission broad enough to cover use in computer programs worldwide. This is a strong official source route for Athaar. However, the 604 QCF page-font files and three additional TTFs currently shipped by `qcf_quran_plus 0.1.1` are not thereby authenticated: no file-by-file binary mapping to the official archive has been established.

Do not state that the existing QCF package assets are now cleared. To close the existing dependency gate, either:

1. obtain and preserve an official package/source mapping for each embedded asset; or
2. implement a renderer that consumes files directly from the official Complex edition, with an explicit redistribution/packaging decision, and validate all 604 pages plus RTL, basmala, surah boundaries, and device rendering.

The official vector archive is 423.3 MB and is an Illustrator vector edition. It is not a drop-in replacement for the QCF page-font assets. A separate engineering conversion/rendering step and a full visual regression suite are required. Keep this release gate OPEN until that work and its tests are complete.

### Contact request

A clarification request is being prepared for the Complex at `info@qurancomplex.gov.sa`, asking whether redistribution of extracted official font/data assets inside Android, iOS, and Windows installers is covered by the published terms, whether attribution is required, and whether Athaar can be submitted for a separate scientific/technical review. A sent email or official approval must not be claimed until a response is received.


## Developer platform availability check — 2026-11-28

The Complex's official announcement dated 18 January 2021 describes a Quran software-developer platform intended to provide vetted Quran text in SQL, JSON, HTML5, XML, Excel, and Word formats, an AI vector edition, and Unicode Quran fonts:
https://qurancomplex.gov.sa/مجمع-الملك-فهد-لطباعة-المصحف-الشريف-يتيح-منصة-لخدمة-مطوري-برمجيات-القرآن-الكريم-وعلومه/

The current site landing page also describes these developer resources:
https://qurancomplex.gov.sa/

However, a direct availability check of the announced developer URL `https://qurancomplex.gov.sa/techquran/dev` returned HTTP 404 at review time. Therefore this is a documented official programme announcement, not a currently verified downloadable API/package endpoint. Do not build against guessed endpoints or claim access to a current developer bundle. Ask the Complex in the pending email for the current developer portal URL, access procedure, exact Hafs dataset/font package, checksums, licence, and integration guide.

The current official fonts catalogue is reachable and publishes individual TTF assets with SHA-256 checksums (for example, KFGQPC Uthman Taha Naskh regular and bold). These are candidate typography resources, but they are not assumed to be a drop-in replacement for the QCF page-specific Tajweed renderer; Quran text/font shaping, glyph coverage, waqf marks, page layout, and tajweed coloring must be independently validated before changing the reader.

Official catalogue:
https://qurancomplex.gov.sa/fonts

Examples:
- Naskh regular: https://qurancomplex.gov.sa/fonts/naskh-regular
- Naskh bold: https://qurancomplex.gov.sa/fonts/naskh-bold

Decision: keep the existing reader unchanged while a separate, isolated prototype evaluates official Unicode text + official font rendering. No canonical reader switch until the full Quran payload, exact glyph coverage, RTL shaping, page/ayah mapping, basmala rules, and all visual regression tests pass.
