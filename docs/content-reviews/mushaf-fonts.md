# Quran and UI font rights dossier

**Review date:** 2026-11-24  
**GitHub issue:** #2  
**Scope:** Official KFGQPC Quran-font resources and Cairo UI font. No font binaries were downloaded or committed in this task.

## 1. King Fahd Glorious Quran Printing Complex (KFGQPC)

### Decision

**CONDITIONALLY APPROVED in principle for an exact official digital asset; current asset acquisition is BLOCKED.** Do not bundle a font or Mushaf-layout asset until the exact file, official rights statement, version, and checksum have been captured.

### Official source review

- Official Complex website: https://qurancomplex.gov.sa/
- Official computer-fonts section: https://qurancomplex.gov.sa/ (navigate to “الخطوط الحاسوبية”).
- Official digital developer-platform announcement: https://qurancomplex.gov.sa/مجمع-الملك-فهد-لطباعة-المصحف-الشريف-يتيح-منصة-لخدمة-مطوري-برمجيات-القرآن-الكريم-وعلومه/

The official website describes Unicode computer fonts for Quranic text and lists a digital Quran developer platform intended for application/software development. However, the live official website currently labels the font and digital-service sections “قريباً” (coming soon); it does not expose a downloadable exact font file or a resource-specific license/notice in the reviewed page.

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
| Exact downloadable file identified and acquired | BLOCKED — official page currently says coming soon |
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

## Overall font decision

- **Cairo:** rights approved; binary acquisition and implementation remain separate tasks.
- **KFGQPC:** conditionally approved in principle; exact official asset and rights statement are not currently downloadable from the reviewed official portal, so integration is blocked.
