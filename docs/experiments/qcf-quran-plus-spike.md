# qcf_quran_plus Hafs renderer spike

**Tracking issue:** [#15](https://github.com/7thramzy/atharapp/issues/15)  
**Review date:** 2026-11-24  
**Spike branch:** `agent/quran/15-qcf-hafs-spike`  
**Decision record:** [D-015](../DECISIONS.md#d-015--isolated-qcf-hafs-renderer-evaluation)

## Scope

This branch contains the first integrated Athaar Hafs reader. It adds a dedicated `HafsRendererAdapter`, initializes QCF page metadata once, loads the current and following page fonts on demand, exposes the reader at `/quran/mushaf`, restores the last reading page from Drift, persists page changes, and stores verse bookmarks in Drift. The dependency is pinned to `qcf_quran_plus: 0.1.1` because the adapter isolates one internal QCF page-repository import.

## Package metadata checked

- Pub package: https://pub.dev/packages/qcf_quran_plus
- Upstream repository: https://github.com/hussein12347/qcf_quran_plus
- Package version reviewed: `0.1.1`.
- Upstream package `pubspec.yaml` declares Dart `^3.11.0` and Flutter `>=1.17.0`. These declared lower bounds do not conflict on paper with Athaar's Dart `>=3.14.0` and Flutter `>=3.50.0`; only CI resolution/build establishes actual compatibility.
- Direct dependencies declared upstream: `archive`, `path_provider`, and `scrollable_positioned_list`.
- Upstream code `LICENSE`: MIT, copyright 2026 Hussein. The package uploader is marked unverified on pub.dev.

## API smoke coverage

`test/quran/qcf_public_api_test.dart` verifies that the dependency exposes:

- `totalPagesCount == 604`.
- `QuranPageView` with the 604-page default and two-page option.
- `WordHighlight`.
- The typed `onWordTap(int, int, int, String)` callback.

The API smoke test checks the exposed contract. Additional adapter tests check page 1 and page 2 page-start mappings and invalid ranges; a widget test checks that the integrated screen and controls mount. CI platform builds check compilation. Visual rendering, word-tap behavior on a physical device, and page-map comparison to the Tanzil canonical dataset remain manual/release QA.

## Font asset inventory and rights status

The reviewed upstream Git tree contains 607 font files:

| Asset group | File count | Source-tree bytes |
|---|---:|---:|
| `assets/fonts/qcf_tajweed/*.ttf.gz` | 604 | 68,711,812 |
| Other TTF files (`HafsSmart_08.ttf`, `QCF4_BSML.ttf`, `arsura.ttf`) | 3 | 1,898,988 |
| **Total font files** | **607** | **70,610,800** |

The upstream package's `pubspec.yaml` declares both the fonts directory and the Tajweed fonts directory as package assets. The figures above match the repository's CI Pub-cache measurement (604 Tajweed files: 65.53 MiB; all fonts: 67.34 MiB). They are source-tree/Pub-cache payload sizes, not a measured APK/AAB size delta. The Flutter package declares these font files as assets, so builds include the declared resources.

The upstream repository tree reviewed for this spike contains a package-level `LICENSE` (MIT), but no separate font license, attribution/notice file, or resource-level Quran/page-data license. Therefore:

- **Code:** MIT identified; preserve the package's required notice if code is copied or redistributed as a substantial portion.
- **Fonts:** **RESEARCH REQUIRED / BLOCKED FOR PRODUCTION BUNDLING** until exact provenance, rights holder, version, redistribution/app-embedding permission, commercial-use scope, and required attribution are documented for every font family.
- **Page layout/Quran data:** **RESEARCH REQUIRED**. The package exposes an internal QCF dataset and 604-page mappings. Their source and rights are not established by the package's MIT code license. Do not treat this data as a replacement for Tanzil.

No font binaries have been copied into Athaar's source tree. They are still package assets resolved from Pub and therefore become part of application builds. The dependency is isolated to this branch; do not publish/distribute resulting application binaries while the resource-rights gate is unresolved.

## Startup and storage behavior observed in source

The upstream `QcfFontLoader.setupFontsAtStartup` method loops through page numbers 1 to 604 and awaits `ensureFontLoaded` for each page when it performs its startup path. Its default storage mode is `permanentDisk`, which uses the application documents directory for extracted fonts.

**Athaar does not call this helper from app bootstrap or the splash screen.** Instead, the adapter initializes the package's page metadata once and calls `QcfFontLoader.ensureFontLoaded` for the current page and next page only. Each visited page's base font is extracted to the app documents cache; first-open latency, cache growth, and memory still need device measurement.

## Required results before the next phase

- [x] Flutter 3.50.0 `flutter pub get` succeeds.
- [x] Static analysis, existing tests, QCF API smoke test, adapter page-map tests, and reader widget test pass on the latest CI head.
- [x] Android debug APK builds; measured output: **251,830,435 bytes (240.16 MiB)**.
- [x] iOS simulator unsigned build succeeds.
- [x] Windows release build and installer/portable packaging succeed.
- [ ] Resolved direct/transitive dependencies are reviewed.
- [ ] Font/data rights are documented or the package is rejected for production use.
- [ ] Page map is compared with the approved Tanzil reference without altering Tanzil text.
- [ ] Word-index base and callback mapping are verified with deterministic examples.
- [ ] A visual/on-device QA pass verifies RTL, Material 3, light/dark, two-page width, font scaling, and small screens.
- [ ] Startup/font loading and cache growth are benchmarked on a physical device without eager loading all 604 page fonts.

## Current disposition

**TECHNICAL INTEGRATION COMPLETE ON PR #16 — NOT MERGED TO MAIN.** CI run [45471585911](https://github.com/7thramzy/atharapp/actions/runs/45471585911) passed all jobs: Tanzil acquisition, format/analyze/tests (including the QCF reader/adapter tests), Android debug APK, iOS simulator build, Windows release/installer, and generated-source persistence. The Android debug APK measured 251,830,435 bytes (240.16 MiB). Physical-device rendering/performance QA and release packaging review remain outstanding.

Next work: physical-device checks for text shaping, RTL, word selection/highlighting, two-page layout, accessibility/font scaling, page-flip performance, and cache growth; evaluate reducing the 240.16 MiB debug APK footprint before a public release.
