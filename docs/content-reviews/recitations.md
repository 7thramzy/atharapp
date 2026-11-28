# Recitation audio source review

**Review date:** 2026-11-27  
**Selected provider:** AlQuran Cloud / Islamic Network

## Decision

**Decision: user-requested streaming and private offline downloads for personal/educational use, subject to the terms below.**

AlQuran Cloud's public API exposes Arabic ayah-by-ayah recitation editions and an ayah audio endpoint. Its published terms allow audio streaming for personal and educational purposes while stating that recordings remain copyrighted by their reciters/rights holders. Reciters may request removal in commercial products.

The provider's current terms (last updated 13 November 2026) expressly allow streaming, embedding and downloading recitations for personal and educational use, and ask clients to cache audio on their side. Recitations remain copyrighted by their translators/reciters; in commercial products a reciter may ask for removal.

Athaar's permitted implementation:
- Streaming a selected ayah while online through the documented ayah endpoint.
- User-initiated download of one complete surah as an MP3 for personal/educational listening.
- Optional user-initiated download of all 114 surahs for one selected reciter, with progress, retry and delete controls.
- Store the downloaded files only in the app's private support directory on the device. Do not expose an export/share action, upload the files, mirror them, or re-host them.
- Display reciter and AlQuran Cloud / Islamic Network attribution and edition ID.
- Remove a recording if the provider/reciter withdraws it or makes it unavailable.
- Do not use playback recordings for model training or evaluation.
- Re-review the rights before subscriptions, paid features, advertising, commercial distribution or any use beyond personal/educational listening.
- A missing bitrate or unavailable edition is an explicit download failure; do not silently switch to an unreviewed provider.

## API integration

- Edition catalogue: `GET https://api.alquran.cloud/v1/edition?format=audio&language=ar&type=versebyverse`
- Ayah audio metadata: `GET https://api.alquran.cloud/v1/ayah/{surah}:{ayah}/{edition}`

The app calls the catalogue when the user opens the study screen and resolves the selected ayah's HTTPS audio URL only after the user presses play. Ayah playback uses `just_audio`.

The CDN documents a complete-surah file endpoint:
`https://cdn.islamic.network/quran/audio-surah/{bitrate}/{edition}/{surah}.mp3`
The first implementation downloads the surah as one file (rather than 6,236 ayah files) and stores it in the app-private support directory. The UI permits downloading one surah or all 114 for the selected edition. Files are local only and can be deleted by surah or by reciter. No audio file is committed to the repository or the app bundle.

## Verification status

- The provider catalogue was reachable during the source review and returned Arabic verse-by-verse editions, including identifiers such as `ar.husary` and `ar.alafasy`.
- The online ayah endpoint and offline surah CDN endpoint are documented by the provider. Offline file download, private storage, retry/fallback bitrate, and delete paths have automated unit tests.
- CI/device verification remains required for Android, iOS and Windows file playback, storage growth and app reinstall/upgrade behavior.
- Provider availability and content rights are not guaranteed by the app. Every stream/download failure is surfaced to the user instead of pretending playback started.

## Sources

- AlQuran Cloud API: https://alquran.cloud/api
- AlQuran Cloud current terms (last updated 2026-11-13): https://alquran.cloud/terms-and-conditions
- AlQuran Cloud CDN surah audio endpoint: https://alquran.cloud/cdn
- Audio edition catalogue: https://api.alquran.cloud/v1/edition?format=audio&language=ar&type=versebyverse
- Provider terms: https://alquran.cloud/terms-and-conditions
