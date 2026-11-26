# Recitation audio source review

**Review date:** 2026-11-27  
**Provider:** AlQuran Cloud / Islamic Network

## Decision

**APPROVED WITH CONDITIONS for user-initiated online streaming and private offline listening in the current free/personal educational app.**

The provider's current terms permit streaming, embedding and downloads for personal and educational use. The recordings remain copyrighted by their reciters/rightsholders, and a rights holder may request removal. Do not interpret the provider's permission as a transfer of ownership or as blanket permission for redistribution by Athaar.

### Allowed in the current app

- User-initiated streaming over HTTPS.
- User-requested download of an individual surah for offline personal listening.
- Store the downloaded tracks only under Athaar's private application-support folder on the user's device.
- Use a saved local track first; otherwise stream the selected ayah when the device is online.
- Allow the user to delete the saved surah from the app.
- Resume an interrupted download by retaining only completed tracks; incomplete temporary files are removed.
- Show the reciter name, edition identifier, provider attribution, and link to the current terms.
- Disable a reciter/edition when access is withdrawn or the provider/rightsholder asks for removal.

### Not allowed in Athaar's implementation

- No upload, sync, sharing, exporting, re-hosting, mirroring, or bundling of the recordings in the APK/AAB/IPA/Windows installer.
- No public link to the app-private audio files.
- No training, fine-tuning, evaluation, voice identity, or speech-recognition use of playback recordings.
- No sale or commercial redistribution of audio.
- No assumption that a publicly reachable file means unrestricted redistribution rights.

Before introducing subscriptions, advertisements, donations linked to access, or any commercial distribution model, re-confirm the provider's current terms and the selected reciter's rights. The provider may change availability or withdraw a recording.

## API and playback implementation

- Edition catalogue: `GET https://api.alquran.cloud/v1/edition?format=audio&language=ar&type=versebyverse`
- Ayah audio metadata: `GET https://api.alquran.cloud/v1/ayah/{surah}:{ayah}/{edition}`
- Surah ayah catalogue: `GET https://api.alquran.cloud/v1/surah/{surah}/{edition}`
- Audio CDN by ayah: `https://cdn.islamic.network/quran/audio/{bitrate}/{edition}/{number}.mp3`

The study screen exposes streaming and a separate user-triggered whole-surah download. Native builds save complete ayah tracks under the app-private support directory. Web does not claim offline-file support and continues to stream online. The source host is allow-listed as `cdn.islamic.network`; non-HTTPS or unexpected hosts are rejected.

## Required verification before public release

- [ ] CI tests pass for edition parsing, complete surah track ordering, duplicate/missing ayah rejection and unsafe URL rejection.
- [ ] Physical Android, iOS and Windows test confirms download, playback with airplane mode enabled, resume, cancellation and deletion.
- [ ] Check app storage usage for a full surah and handle insufficient storage.
- [ ] Confirm provider terms still allow personal/educational offline downloads on launch date.
- [ ] Record the exact reciter edition and any provider/rightsholder notice applicable to that edition.
- [ ] Confirm no recording is copied into the app bundle or exported through Android share/file picker.
- [ ] Test unavailable/withdrawn edition behavior and disable path.

## Sources

- API documentation: https://alquran.cloud/api
- CDN documentation: https://alquran.cloud/cdn
- Terms: https://alquran.cloud/terms-and-conditions
