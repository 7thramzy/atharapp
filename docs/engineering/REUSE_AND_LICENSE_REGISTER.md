# Reuse and License Register

This register is mandatory whenever code or assets are copied, adapted, or bundled into Athaar.

## Current upstream references

| Source | Code license | Permitted plan | Required handling |
|---|---|---|---|
| [Quran Offline Mobile](https://github.com/hndrwn-dk/quran-offline-mobile) | MIT (copyright Hendrawan, 2025) | Selective code adaptation | Preserve the MIT copyright and permission notice for copied/substantial portions; record exact commit and file paths |
| [Flutter Boilerplate](https://github.com/aazirani/flutter_boilerplate) | MIT (copyright Amin Azirani, 2026) | Architectural patterns and selective code adaptation | Preserve the MIT notice for copied/substantial portions; record exact commit and file paths |
| [Sanad](https://github.com/harounRhim/sanad) | AGPL-3.0 | Research reference only | Do not copy or link its code into the app without a separate licensing decision |

## Important separation: code vs. content

A source repository's MIT license does not automatically license the data or assets mentioned in its README.

The Quran Offline Mobile documentation names multiple independent sources:

| Asset/content | Named source in upstream documentation | Athaar rule |
|---|---|---|
| Uthmani Quran text and translations | Quran Foundation / Quran.com Content API | Review current content/API and redistribution terms before bundling |
| Tafsir and surah information | Quranic Universal Library (QUL) / Tarteel | Review QUL terms and each underlying work's permissions |
| Transliteration and Mushaf QPC V2 resources | QUL | Do not copy until explicit terms are documented |
| Recitation audio | EveryAyah | Review provider terms, attribution, caching and redistribution rules |
| Uthmanic/KFGQPC fonts | King Fahd Complex | Review font-specific usage and redistribution terms |
| Scheherazade New | SIL | Verify the exact font file and include its OFL notice where required |
| Surah-name font | QUL | Review its separate terms |
| Icons and illustrations | Asset credits in upstream repository | Do not copy without checking the icon-specific source/terms |

The upstream DATA_SOURCES.md and assets/README.md are useful provenance references, not blanket redistribution grants.

## Athaar reuse workflow

For every reused item, record:

- Item name and purpose.
- Type: source code, font, icon, dataset, audio, translation, or documentation.
- Original repository/provider and exact URL.
- Commit, release, or dataset version.
- SPDX license identifier or the provider's terms URL.
- Copyright/attribution text required.
- Modifications made.
- Athaar file paths where it is used.
- Date and reviewer of the license check.

No binary font, Quran dataset, tafsir database, audio file, or icon pack from an upstream project is approved for copying by this audit.

## Repository licensing decision

Athaar's own project license has not been selected. Do not add an MIT or other blanket license to the whole Athaar repository until the owner chooses the intended distribution and commercial/open-source model.

For any MIT source that is actually incorporated, retain the required notice in THIRD_PARTY_NOTICES.md and include the upstream MIT license text. This does not change the license of Athaar's own original code.
