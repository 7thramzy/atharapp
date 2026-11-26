# Recitation audio source review

**Review date:** 2026-11-25  
**Selected provider:** AlQuran Cloud / Islamic Network

## Decision

<badge>Online streaming only</badge>

AlQuran Cloud's public API exposes Arabic ayah-by-ayah recitation editions and an ayah audio endpoint. Its published terms allow audio streaming for personal and educational purposes while stating that recordings remain copyrighted by their reciters/rights holders. Reciters may request removal in commercial products.

Athaar may therefore expose user-initiated streaming for its current educational reading experience under the provider's terms, with the following restrictions:

- Do not bundle the audio files in the app or installer.
- Do not download, mirror, or provide an offline audio cache.
- Do not use recitation audio for model training or evaluation.
- Do not claim ownership of any reciter's recording.
- Show the selected reciter, edition identifier, and AlQuran Cloud / Islamic Network attribution.
- If a reciter or rights holder withdraws an edition, remove or disable it promptly.
- Re-review the rights before introducing subscriptions, paid features, advertising, commercial distribution, or another use beyond the current educational stream.

## API integration

- Edition catalogue: `GET https://api.alquran.cloud/v1/edition?format=audio&language=ar&type=versebyverse`
- Ayah audio metadata: `GET https://api.alquran.cloud/v1/ayah/{surah}:{ayah}/{edition}`

The app calls the catalogue when the user opens the study screen and resolves the selected ayah's HTTPS audio URL only after the user presses play. Playback is streamed with `just_audio`; the app does not add an offline download action or ship MP3 assets.

## Verification status

- The provider catalogue was reachable during the source review and returned Arabic verse-by-verse editions, including identifiers such as `ar.husary` and `ar.alafasy`.
- The individual audio endpoints and the playback path still require CI/device verification on supported Android, iOS, and web builds.
- Provider availability and content rights are not guaranteed by the app. Every stream failure is surfaced to the user instead of pretending playback started.

## Sources

- AlQuran Cloud API: https://alquran.cloud/api
- Audio edition catalogue: https://api.alquran.cloud/v1/edition?format=audio&language=ar&type=versebyverse
- Provider terms: https://alquran.cloud/terms-and-conditions
