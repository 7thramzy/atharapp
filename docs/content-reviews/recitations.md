# Athaar recitation audio rights review

**Review date:** 2026-11-28  
**Product scope reviewed:** non-commercial, personal and educational listening  
**Current app behavior:** online ayah streaming and user-initiated private full-surah downloads  
**Decision:** conditionally permitted for AlQuran Cloud service use under its current terms; not a blanket commercial or redistribution license.

## Provider terms reviewed

AlQuran Cloud terms: https://alquran.cloud/terms-and-conditions  
Terms page last updated: 2026-11-13 (checked 2026-11-28).

The terms state that recitations remain copyrighted by their reciters, while streaming, embedding and downloading are permitted for personal and educational use. They also state that reciters may request removal when recordings are placed in a commercial product and ask clients to cache audio on their side.

This is not a transfer of copyright to Athaar. The permission is limited by the stated personal/educational scope and underlying reciter copyright.

## Use matrix

| Provider / recording set | Stream | Private on-device download/cache | Bundle in installer | Re-host / mirror | Commercial product | AI training/evaluation |
|---|---|---|---|---|---|---|
| AlQuran Cloud catalogue editions | Conditionally allowed for personal/educational listening | Conditionally allowed; user initiated; private app storage | Not approved | Not approved | Blocked pending direct rights review; reciter may request removal | Blocked absent separate recording/dataset permission |
| EveryAyah recordings | Blocked pending recording-specific terms and rights evidence | Blocked | Blocked | Blocked | Blocked | Blocked |
| QUL audio resources | Research required per exact resource record | Research required per exact resource record | Blocked pending rights | Blocked pending rights | Blocked pending rights | Blocked pending rights |

## Reciter / edition controls

The AlQuran Cloud API returns a dynamic edition catalogue. Athaar selects an edition by its provider identifier and shows the provider's Arabic/English reciter name. Downloads are stored under the edition identifier in app-private storage.

For each selected edition, Athaar must retain and display the provider, exact edition identifier, reciter name and source. It must support disabling unavailable/withdrawn editions and deleting the relevant downloaded files. Public catalogue availability is not a separate license grant from each reciter.

## Athaar implementation constraints

- Online playback is user-initiated.
- Full-surah downloads are user-initiated and stored in app-private storage.
- Do not export downloaded MP3s, upload them to Athaar servers, mirror/re-host them, or place them in the installer/repository.
- Do not use playback audio for model training, ASR evaluation, voice identification, or biometric processing.
- Do not represent a recording as public domain or owned by Athaar.
- Recheck terms at each release and before any monetization.
- Provide a removal/disable path if the provider or reciter withdraws a recording.

## Engineering QA status

Automated tests cover mocked download responses, bitrate fallback, empty-file rejection, edition/path validation, file listing and deletion. They do not prove real MP3 decoding, offline playback after process restart, or background/lock-screen/Bluetooth/audio-focus behavior on hardware.

See `docs/qa/audio-device-test-plan.md`. Physical-device QA remains NOT RUN until real devices are available and evidence is attached.

## Sources

- AlQuran Cloud terms: https://alquran.cloud/terms-and-conditions
- AlQuran Cloud API: https://alquran.cloud/api
- EveryAyah: https://everyayah.com/
- QUL resource catalogue: https://qul.tarteel.ai/resources
