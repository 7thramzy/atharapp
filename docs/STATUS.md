# Athaar project status

**Last verified:** 2026-11-28  
**Default branch:** `main`  
**Current phase:** Integration and release-gate closure. Core local-first Flutter workflows are on `main`; the latest Quran/audio/memorization integration is under review in PR #37 and is not yet merged.

## Completed on main

- Flutter foundation, Arabic-first UI, Riverpod, GoRouter, Drift/SQLite and local-first workflows.
- Reader/search/bookmark/note/import foundation and local adhkar/memorization/personal-impact workflows.
- Drift schema v2 and migration coverage.
- PR #36 merged: privacy-policy draft and release acceptance checklist. The privacy policy is an internal draft only; it is not published or legally approved.
- Official Tanzil Uthmani v1.1 source acquisition/provenance work is maintained with a source manifest. Canonical Quran payload must remain verbatim.

## Current integration candidate — PR #37

PR: https://github.com/7thramzy/atharapp/pull/37  
Branch: `agent/release/integrated-quran-audio-candidate`  
Current head: `0a0ed45e398508b47ce4ac7bdbc53086fee39691`

The integration candidate consolidates:
- QCF Hafs renderer ayah-order correction and regression coverage across cached parsed lines.
- Standalone basmala in the local text reader, preserving Al-Fatihah and At-Tawbah exceptions and canonical source text.
- Audio playback controls, reciter identifier validation, trusted HTTPS audio-host validation, and Quran reference bounds.
- Memorization range validation and local-store safeguards.
- Structural Hafs Mushaf and boundary regression tests.

### Exact-head CI status

- CI run `46154459793` passed on parent commit `fac079d07d21c467f54d7e21b7499f687671ecf8`: Tanzil acquisition, format/analyze/tests, Android debug and ARM64 test-release builds, Windows release/installer, and unsigned iOS simulator build.
- The Android ARM64 test APK was signed with a CI Debug certificate, not a production key. It is not a public release.
- The current PR head `0a0ed45e398508b47ce4ac7bdbc53086fee39691` changes only `retrieved_at_utc` metadata in the Tanzil source manifest; the Quran payload is unchanged.
- Workflow run `46155196272` for the current head is `action_required` and returned no jobs. Exact-head CI is therefore NOT green. A repository owner must approve/allow the workflow in GitHub Actions or otherwise resolve the required approval; do not merge until the current head has a successful run.
- PR #37 remains Draft and unmerged. Do not distribute its CI artifacts as a finished release.

## Release blockers — do not mark complete without evidence

1. **QCF assets:** the package's MIT code licence does not establish redistribution rights for its bundled font/page-data assets. Exact provenance and applicable official permissions must be demonstrated, or the assets replaced with a rights-cleared alternative.
2. **Physical Mushaf QA:** compare representative pages, RTL ordering, glyph shaping, basmala and navigation on real Android hardware against an approved reference. CI structural tests are not visual QA.
3. **Full page verification:** complete independent 604-page boundary/content mapping checks and a documented human review sample.
4. **Audio rights and offline behavior:** verify the exact reciter/recording permissions for streaming, caching and offline downloads. Exercise background playback, lock screen, Bluetooth, audio focus, interruptions and offline transitions on physical devices.
5. **Automated tasmee / ASR:** no production ASR-based verse recognition, omission/repetition detection, or Tajweed assessment is approved. The current candidate is research-only; local recording/playback is not automated tasmee.
6. **Word-by-word Arabic meanings:** no Arabic lexical edition is approved for bundling. Do not invent meanings or treat an English morphology/gloss resource as an Arabic dictionary.
7. **Privacy:** complete owner/legal identity, jurisdiction, support contact, public HTTPS policy, actual data flows, retention/deletion behavior and legal review. PR #36 only added a draft and checklist.
8. **Production signing:** configure Android production signing and produce a signed AAB; configure Apple signing and a device IPA/archive; decide and verify Windows Authenticode or Store distribution. Never commit signing secrets.
9. **Store and device acceptance:** complete clean-device install/upgrade, accessibility, localization, offline/network failure, performance, backup/deletion and store metadata checks.

## Current product scope boundary

Do not advertise features as shipped unless they are merged and tested. In particular, automated tasmee/Tajweed scoring, family/community groups, cloud sync, donations, and unlicensed offline recitation bundles are not approved for the first public release.

## Related tracking

- PR #36 — merged privacy draft and release acceptance checklist.
- PR #37 — current integrated Quran/audio/memorization candidate; Draft, exact-head CI blocked by `action_required`.
- Issue #21 — public release readiness master checklist.
- Issue #26 — Mushaf ordering and 604-page integrity / physical QA.
- Issue #31 — standalone basmala behavior.
- Issue #34 — Arabic word-by-word meaning rights and alignment.
- Issue #4 — recitation audio licensing.
- Issue #23 — privacy disclosures, source/license screen and removal of stale test download links.
- PR #13 / issue #6 — local recording foundation only; not an ASR/tasmee engine.

**Release rule:** no APK/EXE/IPA handoff or public release until the integration is merged after exact-head CI, rights and privacy gates are closed, physical-device QA passes, and production signing is verified.
