# Athaar physical-device audio QA plan

**Status:** NOT RUN — requires physical Android devices  
**Scope:** online ayah playback, private offline surah download/playback, lifecycle and audio routing  
**Do not mark complete from mocked tests, emulator-only runs, or CI builds.**

## Test environment record

For each run, record device manufacturer/model and hardware revision, Android version/API level/security patch, Athaar commit/version and APK SHA-256, audio edition identifier and reciter name, available storage, network state, Bluetooth device, test date, tester, results and evidence.

Minimum matrix:
1. One current Android phone representative of a common mid-range device.
2. One additional Android phone on a different API level/vendor.
3. iOS device testing only after a signed device build exists; iOS Simulator does not satisfy this matrix.

## Test cases

| ID | Scenario | Procedure | Pass criteria |
|---|---|---|---|
| AUD-01 | Online ayah playback | Choose a reciter and play an ayah | Correct audio loads; clear loading/error state; no crash |
| AUD-02 | Controls | Pause, resume, seek, speed, repeat and stop | Player state and UI remain synchronized |
| AUD-03 | Download one surah | Download over stable Wi-Fi | File saved privately; progress/completion accurate |
| AUD-04 | Offline playback | Complete download, enable airplane mode, play | Audio decodes and plays fully without network |
| AUD-05 | Process restart | Force-stop/reopen offline and play downloaded surah | Download is rediscovered and plays after restart |
| AUD-06 | Interrupted download | Interrupt network, restore and retry | Partial file is not treated as complete; retry succeeds |
| AUD-07 | Empty/invalid response | Use controlled test response | Invalid payload rejected; no false downloaded state |
| AUD-08 | Missing edition/surah | Request unavailable recording | Clear unavailable message; no corrupt file |
| AUD-09 | Storage pressure | Test with low free storage | Graceful error; partial file cleaned |
| AUD-10 | Delete one surah | Delete current download | File removed and no longer listed |
| AUD-11 | Delete edition | Delete all files for reciter | Edition files and partials removed |
| AUD-12 | Background playback | Background app and lock screen | Playback and controls behave consistently |
| AUD-13 | Audio focus | Interrupt with call/other media/notification | Pause/duck/resume is stable |
| AUD-14 | Bluetooth | Connect/disconnect headset during playback | Route changes without crash or stuck state |
| AUD-15 | Route changes | Switch speaker/wired/Bluetooth | Playback remains controlled |
| AUD-16 | App lifecycle | Rotate, background, resume, navigate away/back | No leaked player, stale UI or unexpected playback |
| AUD-17 | Network transition | Switch Wi-Fi/mobile/offline during online playback | Recoverable error; offline path works when file exists |
| AUD-18 | Long playback | Play a long surah to completion | No unexpected stop or repeat |
| AUD-19 | Data/privacy | Inspect requests during playback/download | Only required provider requests; no local notes/progress in payload |
| AUD-20 | Storage audit | Inspect storage before/after delete/uninstall | Files remain app-private and deletion behavior matches notice |

## Existing automated coverage

Current store unit tests use a mocked HTTP client and temporary directory. They verify bitrate fallback, successful non-empty save, empty response rejection, edition/surah validation, listing and deletion. They do not validate actual MP3 decoding, Android media-session integration, audio focus, Bluetooth, background service behavior or device storage constraints.

## Release gate

The feature must not be described as fully device-verified until all mandatory cases pass on the minimum device matrix, failures are fixed and retested, evidence is attached to the release issue, and rights/reciter attribution are rechecked.
