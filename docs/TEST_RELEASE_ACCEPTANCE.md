# Athaar Test Release — Acceptance and Go/No-Go Checklist

**Status:** PREPARATION — NOT A RELEASE APPROVAL  
**Last checked:** 2026-11-28  
**Target:** private test builds for owner/device QA, not store publication.

## 1. Source and integration

- [ ] Confirm the latest main commit and ensure every intended feature PR is based on current main.
- [ ] Resolve the dependency order and overlapping changes in PRs #28, #29, #30, #33, and #35.
- [ ] Obtain successful CI runs on the exact final commit; a prior successful run on an older head is insufficient.
- [ ] Review all changed files and generated platform files before merging.
- [ ] Keep source text immutable; verify Tanzil manifest/hash and canonical 114 surah / 6,236 ayah counts.

## 2. GitHub Actions approval

The latest workflow runs inspected on 2026-11-28 for PR heads #28, #29, #30, #33, and #35 ended with conclusion action_required and returned no runnable jobs. This is not a test pass or code failure.

- [ ] A repository owner/maintainer must review and approve the pending GitHub Actions workflow runs in the repository's Actions interface, if GitHub presents the approval control.
- [ ] Re-run or dispatch CI after approval and record the exact commit SHA and run URL.
- [ ] Confirm all required quality and platform jobs completed successfully.

## 3. Quran integrity and display

- [ ] Verify the standalone basmala behavior in text reader and Hafs Mushaf.
- [ ] Verify Al-Fatihah's numbering convention and the At-Tawbah exception.
- [ ] Verify Ar-Ra'd 13:1 begins with الٓمٓر as part of ayah 1, not a separate numbered ayah.
- [ ] Verify page 2 line order and representative surah/page boundaries.
- [ ] Confirm the 604-page structural mapping test covers all 6,236 ayahs without gaps or duplicates.
- [ ] Compare rendered pages visually with an approved reference on physical Android hardware.

## 4. Audio and offline behavior

- [ ] Verify reciter catalogue and online ayah playback.
- [ ] Verify stop, pause, seek, speed, repeat, and selected ayah/range behavior.
- [ ] Verify full-surah download, interrupted-download cleanup/retry, duplicate download handling, deletion, and re-download.
- [ ] Verify local playback with network disabled after download.
- [ ] Verify background/lock-screen behavior, audio focus interruptions, Bluetooth routing, and app lifecycle on physical devices.
- [ ] Verify storage usage and user-visible download progress/errors.
- [ ] Reconfirm the exact provider and reciter use conditions before public distribution.

## 5. Privacy, security, and accessibility

- [ ] Review docs/PRIVACY_POLICY_DRAFT.md; fill owner identity/contact and obtain legal review.
- [ ] Confirm all outbound requests and data flows against the final source and platform builds.
- [ ] Confirm no private notes, bookmarks, memorization progress, or adhkar data are sent to content providers.
- [ ] Confirm app permissions are minimal and justified on every platform.
- [ ] Verify Arabic RTL, font scaling, contrast, keyboard navigation, screen readers, and light/dark modes.
- [ ] Verify database migration from the prior app version and preservation of local data.
- [ ] Verify local-data deletion/reset behavior and uninstall/reinstall expectations.

## 6. Asset rights and release contents

- [ ] Obtain exact asset-level redistribution evidence for every QCF font/page-data file included by qcf_quran_plus 0.1.1, or replace it with an asset set whose rights are verified.
- [ ] Include the complete Tanzil notice and all required source attributions.
- [ ] Acquire and include the exact Cairo font binary plus the OFL notice if it is bundled.
- [ ] Verify that no unapproved tafsir/translation corpus, audio recording, or model is bundled.
- [ ] Generate a third-party notices inventory from the actual packaged artifacts.

## 7. Build artifacts

- [ ] Android debug APK builds and installs.
- [ ] Android ARM64 test-release APK builds, signature verifies, and checksum is recorded.
- [ ] Windows release directory and installer build; clean-install and upgrade paths pass.
- [ ] iOS simulator build passes.
- [ ] iOS device archive/IPA is not considered ready until Apple signing and provisioning are configured and the artifact is validated.
- [ ] Record artifact size, SHA-256, commit SHA, toolchain versions, and build run for every package.
- [ ] Do not use a CI debug/test signing identity for public store distribution.

## 8. Owner-provided actions and credentials

These items cannot be fabricated or safely supplied by an automation agent:

- [ ] Approve GitHub Actions runs if the repository requires owner approval.
- [ ] Provide a physical Android test device (and iOS device if iOS is in scope) for hands-on QA.
- [ ] If production signing is desired later, create platform signing material locally and store it only in the appropriate GitHub Environment secrets. Never paste passwords, keystores, private keys, or certificates into chat or commit them to Git.
- [ ] Complete legal operator identity and privacy contact details.

## 9. Go/no-go decision

A private test build may be prepared only after the exact final commit passes CI and its build artifacts are verified. Physical-device findings must be recorded separately.

A public/store release remains blocked until all applicable rights, privacy, physical-device, signing, support-contact, and store-policy gates are closed. A successful CI run alone is not public-release approval.

## 10. Additional evidence-based gates (2026-11-28)

### QCF asset provenance
- [ ] Obtain exact file-by-file provenance and permission for the 604 QCF Tajweed fonts, three additional TTF files, and surah banner embedded by qcf_quran_plus 0.1.1; the package's root MIT code license is insufficient.
- [ ] If provenance cannot be demonstrated, replace embedded assets with direct official KFGQPC distribution files and retain original rights notices/checksums.
- [ ] Do not distribute public builds while this gate is open.

### Audio provider and physical playback
- [x] Review current AlQuran Cloud terms: personal/educational streaming, embedding and downloading are permitted; reciters retain copyright; commercial use may be withdrawn at a reciter's request.
- [ ] Confirm the app remains within non-commercial personal/educational use and supports takedown/disablement for an unavailable recording.
- [ ] Run the device test matrix in `docs/qa/audio-device-test-plan.md` on at least one current Android phone and one additional Android device with a different OS/API level.
- [ ] Verify actual MP3 decode and playback after a clean app restart with network disabled.
- [ ] Verify lock-screen/background controls, Bluetooth route changes, audio focus/interruption recovery, download interruption, storage exhaustion, and deletion on physical hardware.
- [ ] Attach device model, OS build, app commit, test date, results, and screen/log evidence. Simulator and mocked HTTP tests do not satisfy this section.

### Automated tasmee
- [ ] Obtain rights-cleared, full-ayah, Hafs audio and verified human references.
- [ ] Obtain the candidate model's auditable training-reciter roster and construct a speaker-disjoint test set.
- [ ] Reproduce WER/CER, exact-ayah identification, omission/repetition/substitution errors, uncertainty rate, and device performance on physical Android hardware.
- [ ] Complete qualified human review of false positives and error cases.
- [ ] Keep ASR out of production until all above gates pass. No Tajweed scoring or religious correctness claims are approved.

### Privacy
- [x] Correct the in-app settings disclosure to state that opening the study screen automatically contacts jsDelivr, QuranEnc, and AlQuran Cloud for study content/catalogues.
- [x] Inspect current Android manifest and iOS Info.plist: INTERNET permission exists on Android; no microphone permission/usage description was found in these files.
- [ ] Audit final merged release artifacts and all transitive SDKs for network endpoints, permissions, analytics, crash reporting, advertising and backup behavior.
- [ ] Verify local-data deletion/reset and OS backup behavior on each supported platform.
- [ ] Complete legal operator identity, country, privacy contact and support URL; obtain jurisdiction-specific review; publish a stable HTTPS policy and link it in-app and in store listings.

A checked documentation/code review item is not evidence that an external legal approval or a physical-device test has occurred.
