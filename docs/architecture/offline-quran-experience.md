# Offline Quran, synchronized listening, and local recitation

**Status:** Architecture accepted for implementation planning; not a claim that the feature is already shipped.
**Target:** Android and iOS first. Browser preview remains network-dependent where browser storage or model support differs.
**Canonical reading:** QCF 604-page Hafs 'an Asim. The Tanzil text dataset remains a secondary local text source and is not presented as a second riwayah.

## Product behavior

Athaar has two synchronized follow modes:

1. **Listen and follow.** The selected reciter's chapter audio plays from a local file. The audio position resolves to a verse and, when licensed timing metadata is available, a one-based word index. Future ayat are dimmed, the active ayah is brought into focus, the active word is highlighted, and completed ayat return to normal opacity. Scrolling follows the active ayah. If word timing is unavailable or invalid, highlight the complete ayah rather than inventing word timing.
2. **Recite from memory.** Microphone audio is processed on-device. Partial recognition is aligned to the selected Hafs ayah range. Confirmed words are revealed in reading order, the current candidate word is highlighted, and not-yet-reached words remain dimmed. Ambiguous audio is shown as "غير متأكد" and never silently marked correct. A completed phrase can be replayed and reviewed. This is a reading-progress aid, not a Tajweed judge or religious ruling.

Reveal states are deterministic:
- completed: previous ayat; normal opacity (1.0).
- active: current ayah; normal opacity plus current-word highlight when a trusted cursor exists.
- upcoming: future ayat; reduced opacity (target 0.22–0.28).
- Before the first valid timing or while paused before audio begins, do not mark any ayah completed.
- On playback completion, all ayat in the selected range return to normal opacity.

## Audio: permitted local storage path

Use Quran Foundation / QuranicAudio chapter recordings and their chapter-recitation metadata. The Content API can return a single chapter file with file_size, format, audio_url, verse-level timestamps, and optional word-level segments tuples [oneBasedWordIndex, startMs, endMs].

Downloads are explicitly user-triggered (or enabled in settings) and kept only in Athaar's private app storage. Do not bundle recitations in APK/IPA, mirror them on Athaar's backend, export the files, expose them to other apps, or transcode/re-encode them without separate permission. Display Quran Foundation and reciter attribution. Let the user delete every downloaded file. Keep the associated Content Sync metadata current at least every seven days when online; when a source/file is removed, delete the related local audio, and replace it if its URL changes. Keep no more than one temporary .part file for a download and atomically rename only after length/metadata validation.

### Storage strategy

- Download a selected surah, not the entire Quran by default.
- Show source-reported file size before download; require explicit confirmation.
- Default cap: 512 MiB for recitation files, configurable by the user; never silently exceed it.
- Do not transcode provider audio. Save the provider's original format to avoid changing licensed media.
- Store only metadata and audio files in application-private storage. Never make the recording URL itself a local file identifier.
- Provide downloaded / available / failed / removed states, retry/resume where HTTP range support is verified, and a per-reciter / per-surah delete action.
- A full-Quran download is an explicit multi-selection with a size total and a second confirmation, never an automatic install step.

Quran Foundation's current Developer Terms (updated 2026-11-20) permit indefinite offline copies on the end user's device only under those conditions. Content Sync metadata is separate from the audio files. Do not cache the same audio on Athaar servers.

## Tafsir and translations: local text packs

### Arabic tafsir

Use the pinned ar-tafsir-al-jami-al-wajiz edition from spa5k/tafsir_api v1.2.3. The repository identifies the Al-Jami' Al-Wajiz text as CC BY-ND 4.0 and its source script preserves the wording. Fetch one surah JSON pack, validate every row's surah/ayah reference, and store the text unchanged in the local database. Keep author, edition, pinned version, source URL, and CC BY-ND 4.0 attribution alongside the pack. Never normalize, edit, summarize, or alter the tafsir text itself.

### Translations

Use QuranEnc's official translation catalogue. Prefer its per-translation SQLite download when available; otherwise download one complete surah using the documented surah translation endpoint. Save the publisher's title, translator, edition/version, direction, footnotes, source, and last-update value with the local pack. Preserve the translation and footnotes verbatim. QuranEnc's conditions require publisher/source attribution, version number, transcript information, no additions/deletions/modifications, and updates to the latest issued version.

### Offline and updates

- Local DB is the read path. The network is only the download/update path.
- A user can download one tafsir edition and one or more translation editions by surah, or queue the full edition if storage permits.
- Download into a temporary pack; validate expected ayah count, references, non-empty required fields, version metadata and checksum if provided; then publish the pack in one DB transaction.
- Failed or interrupted downloads never replace a working local pack.
- At next connection, compare source version / last-update metadata and offer an update. Keep the old pack until the new one has passed validation.
- Keep source text verbatim; only presentation metadata and indexes may be normalized.

## Local memorization recognition

Candidate recognizer: Abdou/quran-asr-small, int8 ONNX (about 36 MB; 33M parameters), MIT model repository. Keep model weights out of the APK/IPA and download them once, on the user's explicit request, into private app storage. Run inference entirely on-device using sherpa_onnx; no microphone audio, transcript, or derived personal voice data is sent to a server or saved after the session unless the user explicitly saves a practice session.

Important limitations:
- The model card's WER/CER and exact-ayah retrieval figures are the author's reported results, not Athaar's independently verified measurements.
- Its documented simple path is offline recognition. Until a streaming configuration for this exact checkpoint is proven, process short VAD-bounded speech chunks and update the UI after each chunk; do not claim zero-latency streaming.
- Normalize only temporary comparison strings (remove tashkeel/Quranic marks and normalize alef forms); never alter the displayed Hafs text.
- Constrain alignment to the user-selected surah/range and the previous cursor to reduce repeated-phrase ambiguity.
- Use an abstention state when confidence is low. Never auto-penalize a learner or label Tajweed / makharij.
- Keep a user-visible microphone indicator, explicit start/stop control, permission rationale, and an immediate discard action. The default is no recording retention.

Do not use Quran Foundation recordings or other restricted content to train or evaluate the recognizer. The model runs inference on the user's own live microphone input; evaluate the integration only with separately authorized test recordings and consent.

## Rendering implementation

- The current QCF package supports HighlightVerse and WordHighlight in its Mushaf and vertical Surah readers.
- Its vertical QuranSurahListView exposes ayahBuilder, so Athaar can apply per-ayah opacity while retaining QCF/Hafs word rendering. Use this vertical view for the synchronized follow mode initially.
- The existing 604-page Mushaf remains the official navigation/reading view. It can receive the active ayah/word highlight. Per-ayah opacity in the fixed 604-page canvas requires a package extension or a supported page-level custom builder; do not fake it with a full-page opacity overlay (that would dim the active ayah too).
- Playback cursor updates must be throttled to actual word changes, not every audio position event, to avoid rebuilding the page on each frame.
- Keep the selected surah and ayah coordinate shared when switching between the page Mushaf, follow mode, and the auxiliary text reader.

## Credentials and network boundary

Quran Foundation's Content API / Content Sync documentation currently requires a backend client ID and secret. Keep these credentials only in a server-side secret store (for example, a Vercel Function environment), never in Flutter assets, Dart constants, app preferences, or the APK/IPA. A small metadata/sync gateway may return authorized reciter metadata, file URLs and timestamps; the mobile app downloads the audio directly into private storage. The gateway must not store or proxy the recording files.

This means the playback, reading, tafsir, translations, and recognition paths can work offline after their packs/model/audio have been installed. First-time downloads and periodic source-revocation/version checks still need connectivity. If no credentials are configured yet, show a clear "download service not configured" state; never fall back silently to an API whose terms only permit streaming.

## Acceptance criteria

1. Hafs page reader opens offline with the bundled local Quran assets.
2. A downloaded surah plays fully offline from the private audio file, with attribution and delete control.
3. Timed playback resolves a deterministic ayah and optional word index; no timing means ayah-only highlight.
4. During follow mode, previous ayat are normal, current ayah is highlighted, future ayat are dimmed; states update on seeking, pause, resume, chapter change, and completion.
5. A downloaded tafsir/translation pack opens in airplane mode and keeps full source/version/attribution information.
6. Interrupted downloads leave no corrupt visible pack; storage cap is enforced before and during download.
7. On-device recitation recognition works with the network disabled after the model is installed; recordings remain on device and are discarded by default.
8. Uncertain or mismatched recognition is shown as uncertain, not silently accepted as correct.
9. Automated tests cover timing boundaries, missing/overlapping segments, Arabic normalization, alignment ordering, pack validation, storage quota, and interrupted downloads.
10. Android and iOS native builds pass; device tests measure actual model latency, memory use, battery, and microphone behavior before declaring the recognizer production-ready.

## Sources and rights records

- Quran Foundation Developer Terms: https://api-docs.quran.foundation/legal/developer-terms/
- Quran Foundation offline audio FAQ: https://api-docs.quran.com/docs/tutorials/faq/
- Chapter audio endpoint / timing schema: https://api-docs.quran.foundation/docs/content_apis_versioned/4.0.0/chapter-reciter-audio-file/
- Quran Foundation Content Sync: https://api-docs.quran.foundation/docs/sdk/javascript/resources/
- QuranEnc API and translation downloads: https://quranenc.com/en/home/api
- QuranEnc translation republication conditions: https://quranenc.com/en/home/about/conditions
- Al-Jami' Al-Wajiz dataset release: https://github.com/spa5k/tafsir_api/tree/v1.2.3/tafsir/ar-tafsir-al-jami-al-wajiz
- ASR candidate/model card: https://huggingface.co/Abdou/quran-asr-small
- Sherpa ONNX Flutter package: https://pub.dev/packages/sherpa_onnx
- QCF renderer: https://pub.dev/documentation/qcf_quran_plus/latest/
