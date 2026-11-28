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
