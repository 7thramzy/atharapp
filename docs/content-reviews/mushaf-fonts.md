# Quran and UI font rights dossier

**Review date:** 2026-11-27  
**GitHub issue:** #2  
**Scope:** Official KFGQPC Quran-font resources and Cairo UI font. No font binaries were downloaded or committed in this task.

## 1. King Fahd Glorious Quran Printing Complex (KFGQPC)

### Decision

**Official digital edition: approved for software use under the published grant. qcf_quran_plus embedded font/page asset mapping: pending verification.** Do not bundle a font or Mushaf-layout asset until the exact file, official rights statement, version, and checksum have been captured.

### Official source review

- Official Complex website: https://qurancomplex.gov.sa/
- Official computer-fonts section: https://qurancomplex.gov.sa/ (navigate to “الخطوط الحاسوبية”).
- Official digital developer-platform announcement: https://qurancomplex.gov.sa/مجمع-الملك-فهد-لطباعة-المصحف-الشريف-يتيح-منصة-لخدمة-مطوري-برمجيات-القرآن-الكريم-وعلومه/

The official KFGQPC digital developer platform announcement describes Unicode Quranic text and computer fonts for application/software development. Its current live page still marks the developer platform as “قريباً”. Separately, the official digital Hafs Madinah Mushaf page expressly permits use of that exact digital edition in computer programs, websites and digital publishing, free of charge in and outside Saudi Arabia. The published digital-edition asset on that page is an AI vector file with SHA-256 C2FA8D93A7C4F689B58EB32756E1AE56CD1B7CE4826F63E09723BE8B092224FB. Athaar has not downloaded or integrated that AI file. We have not yet verified that each embedded file in qcf_quran_plus 0.1.1 (HafsSmart_08.ttf, QCF4_BSML, arsura.ttf and the 604 files in qcf_tajweed) is byte-identical to, derived from, or separately covered by that specific official grant.

### Conditions before bundling

- Obtain the exact font from an official KFGQPC distribution, not an unofficial mirror or an unrelated QUL package.
- Preserve the original file unchanged unless the exact official license permits a transformation.
- Save the complete official Arabic/English usage-rights statement with the asset.
- Record filename, version/edition, source URL, retrieval date, SHA-256, and all required attribution.
- Confirm that the exact asset is permitted for distribution inside Android/iOS apps and any future monetized version.
- Test Arabic shaping, Unicode mapping, glyph coverage, fallback behavior, and Quran line rendering on real devices.
- Keep the Quran font separate from the UI font and never use font conversion as a reason to alter Quran text.

### Verification record

| Check | Result |
|---|---|
| Official KFGQPC site reviewed | PASS |
| Official site identifies Quran computer-font resources | PASS |
| Exact official digital Hafs edition download identified | PASS — separate official AI vector edition is published with a checksum |
| qcf_quran_plus embedded files matched to the official edition and covered by the grant | PENDING — no per-file provenance/rights manifest supplied by the package |
| Exact file/version/hash recorded | PENDING |
| Exact asset rights notice captured | PENDING |
| App redistribution and commercial-use terms confirmed for exact file | PENDING |

**Current disposition:** do not add a KFGQPC binary to the repository or app yet.

## 2. Cairo interface font

### Decision

**APPROVED for bundling and embedding in Athaar as an interface font under SIL Open Font License 1.1**, subject to preserving the license and copyright notices. This approval does not make Cairo a Quran-script font; do not use it as the canonical Mushaf font without separate rendering validation.

### Exact upstream source

- Upstream project: https://github.com/Gue3bara/Cairo
- Upstream license: https://github.com/Gue3bara/Cairo/blob/master/OFL.txt
- Google Fonts metadata: https://github.com/google/fonts/blob/main/ofl/cairo/METADATA.pb
- Font family: Cairo.
- Font designer/project: Mohamed Gaber / The Cairo Project Authors.
- License: SIL Open Font License 1.1.
- Google Fonts metadata identifies the variable TTF as `Cairo[slnt,wght].ttf`, with Arabic and Latin subsets, sourced from the upstream Cairo project.
- Exact binary version, commit pinned for Athaar, byte count, retrieval date, and SHA-256: **PENDING acquisition**. No font binary was downloaded in this research-only issue.

### License conditions

The upstream project states that the font software is licensed under SIL OFL 1.1. The OFL permits use, embedding, bundling, and redistribution with software; the font software must not be sold by itself. The copyright and OFL text must accompany the distributed font. Modified font software must remain under the OFL and must respect any Reserved Font Name, if specified by the exact license copy.

### Athaar implementation requirements

1. Acquire a specific Cairo TTF from the upstream project or its verified Google Fonts distribution.
2. Pin the upstream commit or release and record the exact filename and SHA-256.
3. Include the full upstream OFL 1.1 text and copyright attribution in the repository and distributed app notices.
4. Do not sell the font file separately.
5. Declare it in Flutter only after the exact file and notice are committed.
6. Test Arabic shaping, punctuation, numerals, font scaling, accessibility, and RTL on Android and iOS.
7. Keep Quran text font selection separate from Cairo UI typography.

### Verification record

| Check | Result |
|---|---|
| Upstream Cairo project reviewed | PASS |
| Upstream OFL 1.1 identified | PASS |
| OFL allows embedding/bundling with software | PASS |
| Font must not be sold by itself | PASS |
| Exact binary acquired and hashed | PENDING |
| Full license/notice copied into Athaar | PENDING |
| Flutter integration and device rendering QA | NOT RUN |

## 3. Pinned QCF renderer package — qcf_quran_plus 0.1.1

### Exact package record

- Package: `qcf_quran_plus` version `0.1.1`.
- Pub.dev: https://pub.dev/packages/qcf_quran_plus
- Source repository: https://github.com/hussein12347/qcf_quran_plus
- The repository's `pubspec.yaml` declares the font assets under `assets/fonts/` and `assets/fonts/qcf_tajweed/`.
- The package README describes the renderer as powered by the official QCF/Hafs font and its MIT licence covers the package's software.
- The package uploader is marked **unverified** by pub.dev.

### Rights decision

**CODE: MIT. EMBEDDED QCF FONT/PAGE DATA: NOT CLEARED FOR ATHAAR PUBLIC REDISTRIBUTION UNTIL THE ASSET-SPECIFIC NOTICE OR PERMISSION IS OBTAINED.**

The MIT file in the package repository is a software licence. It does not, by itself, establish that the individual page fonts, surah-header fonts, page/glyph data, or other third-party assets may be redistributed in a public application. The package identifies its source as official QCF but does not provide a separately verified per-file rights schedule in the records examined for Athaar.

### Required release gate

1. Obtain from the package maintainer and/or KFGQPC the exact written licence/permission covering the font files and page data packaged by version 0.1.1, including mobile/desktop distribution and any limits on commercial use.
2. Record each asset family, source, version, licence/permission, attribution, and SHA-256; retain the original rights notice in the repository and About screen.
3. If rights cannot be confirmed, do not distribute this package's QCF assets in the public app. Replace the renderer/font set with an alternative whose exact page fonts and layout data have documented redistribution rights, or ship the independently approved Tanzil Arabic text reader without the unresolved QCF bundle.
4. Do not infer rights from a logo, package description, public availability, the MIT software licence, or permission to use a digital Mushaf in general.

**Current disposition:** the code may remain in the release-candidate branch for engineering validation. The QCF binary assets remain a hard public-distribution gate until the exact grant is documented.

## Overall font decision

- **Cairo:** rights approved; binary acquisition and implementation remain separate tasks.
- **KFGQPC:** conditionally approved in principle; exact official asset and rights statement are not currently downloadable from the reviewed official portal, so integration is blocked.
