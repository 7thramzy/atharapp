# Approved product audit and execution plan

**Status:** APPROVED PRODUCT DIRECTION — implementation not implied  
**Approved by:** Project owner  
**Prepared:** 2026-11-28  
**Target:** Athaar Android/iOS application and supported desktop preview  
**Authority:** This document records the approved product direction from the comparative review of Quran.com and the Athaar audit discussion. It supplements (and does not override) AGENTS.md, DECISIONS.md, CONTENT_SOURCES.md, SECURITY.md, and the QCF spike.

## 1. Product direction

Athaar should not become a visual clone of Quran.com. Its direction is an integrated, Arabic-first, offline-first Quran reading and learning experience:

1. A trustworthy, correctly rendered Hafs Mushaf and text reader.
2. Study tools attached directly to the ayah and word being read.
3. A unified recitation player that works online and offline.
4. Memorization, revision, and carefully validated recitation-assistance workflows.
5. Adhkar and a configurable personal daily wird.
6. Private-by-default progress, transparent content provenance, and user control over local data.

The Quran reader and integrity of its content take priority over cosmetic redesign or feature count.

## 2. Canonical Quran text and rendering integrity — P0 release blocker

### Approved requirements

- Preserve the canonical Arabic text verbatim from the approved, versioned source recorded in docs/CONTENT_SOURCES.md. Do not normalize, reorder, rewrite, strip diacritics, or reconstruct Quran text for presentation.
- Hafs 'an Asim is the target recitation/script convention for the current Mushaf experience, as documented in the source records.
- Keep canonical text, search-normalized text, page-layout metadata, word indexes, and rendered glyph assets as distinct concepts.
- QCF rendering assets must never silently replace or mutate the canonical Tanzil text.
- The UI must preserve correct Arabic shaping, RTL reading order, ayah numbering, verse markers, line order, page order, surah boundaries, and page starts/ends.
- Verify all 604 pages, not only Al-Fatiha and Al-Baqarah.
- Any mismatch in text, ayah order, page mapping, or rendering is a release blocker until resolved and independently checked.

### Current reported symptom to investigate

The owner supplied screenshots of the first two Mushaf pages. The displayed Al-Baqarah page appears to place the opening ayah marker/text in an order that is confusing or inconsistent with the reference display. Treat this as a reproducible defect report requiring investigation, not as a confirmed root cause.

Do not assume the problem is RTL alone, do not reverse arrays speculatively, and do not change source text to make the screenshot look right. Inspect the exact QCF package version, its line/word parsing and text direction behavior, Athaar's adapter, and the source page mapping. Determine whether the mismatch is in source data, parser order, widget bidi layout, or screenshot/page navigation.

### Required QA

- Deterministic fixtures for page 1 (Al-Fatiha 1:1) and page 2 (Al-Baqarah 2:1), including line-level ordering and multiple ayahs on a line.
- Automated checks for all 604 page mappings, populated pages, contiguous page boundaries, and full canonical ayah coverage (1:1 through 114:6).
- Golden/reference comparisons for representative pages with multiple ayahs, surah transitions, basmala behavior, and long lines.
- RTL/LTR isolation tests: Arabic Quran content must render in its intended order even when surrounded by controls, numbers, Latin text, or metadata.
- Physical-device checks at common phone/tablet widths, single/two-page modes, font scaling, light/dark themes, and supported platforms.
- A human reviewer compares representative and boundary pages against an approved Mushaf reference before release.
- Record the exact test commands, results, device/browser, app commit, and unresolved differences.

Do not mark this gate complete merely because the page count or structural mapping tests pass.

## 3. Arabic text and study experience

### Approved

- Use correctly vowelled Arabic text from the approved canonical source.
- Provide a word-level interaction: tapping a word opens its meaning and available study information, with exact word-to-ayah indexing.
- Provide ayah-level actions: listen, open tafsir, choose translation, bookmark, add private note, and add to memorization/revision.
- Support surah information and a translation-reading mode.
- Allow users to report a possible text, translation, or content error. Reports must retain the exact resource/version and ayah/word reference.
- Offer readable Arabic typography, adjustable text size, contrast, light/dark themes, and accessibility semantics.

### Word-by-word meaning requirements

- Show the selected Arabic word, its transliteration only if a reviewed source provides it, and its meaning/translation from a specific identified resource.
- Show source name, edition/version, language, attribution, and rights status.
- Preserve the word's exact position and diacritics; do not generate or infer lexical meanings with AI as if authoritative.
- If no approved word-level resource exists, show a clear unavailable state rather than invented meaning.
- Support caching/offline access only where the resource's rights allow it.

### Tafsir and translation requirements

- Allow selecting among multiple approved tafsir/translation resources when available.
- Each resource requires its own review of exact edition, rights holder, licence/terms, attribution, offline use, commercial use, and version.
- Display the source clearly and distinguish translation from tafsir.
- Do not bundle or cache a resource until its record is approved in docs/CONTENT_SOURCES.md and relevant review dossier.
- Do not present AI-generated explanation as tafsir or a religious ruling.

## 4. Unified recitation player and offline audio

### Approved player behavior

Create one player experience shared by the Mushaf and text reader:

- Select a reciter from the currently approved provider/reciter catalogue.
- Play a selected ayah or surah.
- Set an ayah range (start/end).
- Repeat one ayah, a selected range, or a surah; support a configurable repeat count or continuous repeat.
- Playback speed controls where supported by the audio engine and where speed changes do not imply a change to the source recording.
- Automatic transition to the next ayah and clear current-ayah highlighting when reliable alignment metadata exists.
- Previous/next ayah and resume from last position.
- Show loading, buffering, offline, missing-file, download, and error states clearly.
- Persist playback preferences locally.

### Online/offline source selection

- If the exact selected reciter/ayah or surah file is present and validated in app-private storage, prefer the local file.
- Otherwise, if online and provider terms allow it, stream from the approved provider.
- If neither is available, show a clear unavailable/offline state; never silently play a different reciter or source.
- Downloads are user-initiated. Explain approximate storage use and provide Wi-Fi-only preference.
- Support per-surah/per-reciter progress, retry, interruption recovery where supported, integrity/length validation, cancellation, and deletion.
- Do not report a download as complete until the file is fully received and validated.
- Keep audio in app-private storage. Respect D-016: no exporting, sharing, uploading, mirroring, re-hosting, bundling in installers, or model training/evaluation unless a new explicit rights decision permits a use.
- Online streaming and offline playback are distinct modes. The current implementation must be inspected and tested on each supported native platform; web preview limitations must be documented.

### Audio acceptance tests

Test online stream, already-downloaded local playback, automatic local-first selection, no-network fallback, partial/failed download, retry/resume, deletion, storage-full, app restart, and switching reciters. Test background/lock-screen behavior and platform-specific just_audio implementations. Report separately what is implemented, CI-tested, and device-verified.

## 5. Memorization and recitation assistance

### Memorization/revision

- Track per-ayah memorization state and revision sessions locally.
- Let the user define a range, repeat it, mark progress, and resume later.
- Include a hide/reveal mode to support recall without replacing the canonical text.
- Provide personal progress and reminders as optional, private tools; avoid shame, streak pressure, public worship rankings, or competitive scoring.
- Allow edit, reset, export, and deletion of personal progress.

### Recitation assessment

- Treat speech recognition/recitation assessment as a separate feature and release gate, not as an already completed player capability.
- Start with a clearly scoped, consented, labelled evaluation protocol and qualified human review.
- Expose uncertainty and false-positive/false-negative limitations.
- Never claim Tajweed correctness without validation by qualified reviewers.
- Recordings are ephemeral by default. Do not upload, retain, or use recordings for training without explicit consent and approved privacy/rights design.
- AI output is assistive only, not a religious judgement or substitute for a qualified teacher.

## 6. Navigation and core product structure

Adopt the following primary navigation proposal, subject to checking the current router and existing screens before implementation:

1. **الرئيسية** — continue reading, today's configurable wird, quick access to recent activity.
2. **القرآن** — Mushaf, surah/ayah reader, search, tafsir/translation and audio entry points.
3. **وردي** — adhkar and the user's configurable reading/memorization plan.
4. **أثري** — private progress, memorization/revision summary, saved items and personal activity.

Settings should be accessible from a clear secondary action rather than occupying a primary tab solely as a profile/account destination when no account system exists. Do not imply cloud account/sync functionality before it exists.

Home screen requirements:
- A prominent "continue reading" action restoring the last valid Quran position.
- A configurable daily wird; no fixed religious obligation or pressure-based default.
- Quick access to last-read location, saved items, and current revision session.
- Show only data actually stored and calculated; no fabricated streaks, achievements, or activity.

## 7. Local data control, privacy, and security

- Validate surah and ayah identifiers at every import, repository, and persistence boundary.
- Reject invalid ranges, malformed IDs, out-of-bounds page/word indexes, and stale references safely.
- Provide user controls to edit/delete bookmarks, notes, adhkar entries, memorization records, and other personal data.
- Provide export of user-owned data in a documented portable format (JSON is the initial candidate); include schema/version metadata and avoid exporting licensed source content that the user does not own.
- Provide a clear delete-all-personal-data action with confirmation and explain what is removed versus retained.
- Keep personal progress local by default. Cloud sync is deferred until a separate reviewed design for identity, encryption, RLS/authorization, conflict handling, backup, export, deletion, and incident response is approved.
- No second local database or competing state store. Drift + SQLite remains authoritative for local domain persistence.
- Avoid collecting unnecessary personal information. No recording upload or analytics payload containing sacred text/user recordings without separate approval.
- Test data deletion/export, malformed input, migration safety, offline operation, and app restart.

## 8. Accessibility, visual quality, and usability

- Arabic-first RTL layout must be verified, not assumed from setting Directionality.
- Support dynamic text scaling and practical font-size controls (target up to 200% where layout permits without clipping or loss of content).
- Provide sufficient contrast in both themes and do not communicate meaning only through color.
- Add semantic labels and screen-reader navigation for Quran controls, audio controls, page navigation, and study actions.
- Ensure touch targets and focus order are usable.
- Keep the Mushaf page itself uncluttered; place secondary controls in predictable toolbars/sheets.
- Offer paper/background preferences only if they preserve contrast and readability.
- Test narrow phones, large phones, tablets, landscape, two-page layout, keyboard/focus behavior, and screen readers.
- Visual polish must not compromise Quran text size, shaping, or reading order.

## 9. Delivery phases and dependencies

### Phase P0 — Quran integrity and release safety (BLOCKING)
1. Reproduce and diagnose the reported page/ayah ordering issue.
2. Add/fix deterministic parser, adapter, bidi, page-map, and golden tests.
3. Verify all 604 pages against the approved canonical text/page reference.
4. Complete physical-device visual QA.
5. Reconfirm QCF font/page-data rights and the public-distribution gate in D-015.
6. Measure release artifact size, startup latency, memory, and font-cache growth.

**Exit:** no known text/order/page mismatch; automated structural and representative golden tests pass; human review recorded; resource rights are approved or the affected renderer/assets are replaced.

### Phase P1 — Study tools and content governance
1. Resource-level research for word meanings, tafsir, and translations.
2. Add source/version/attribution display and error-report flow.
3. Implement word-level meanings only after an exact resource is approved.
4. Add tafsir/translation selector and translation-reading mode.
5. Add surah information and ayah action sheet.

**Exit:** every displayed religious resource is source-attributed, versioned, rights-reviewed, and tested against correct ayah/word references.

### Phase P2 — Unified audio and offline reliability
1. Audit current streaming and local-download code paths.
2. Implement one local-first/online-fallback player contract.
3. Add range, repeat, speed, auto-next, resume, and highlighting.
4. Harden downloads (timeouts, retry/resume, integrity validation, progress, storage handling, deletion).
5. Add provider/reciter rights and platform implementation tests.

**Exit:** online/offline selection and failure paths pass automated tests and real-device QA; rights constraints are enforced.

### Phase P3 — Memorization and personal daily experience
1. Improve revision sessions and hide/reveal mode.
2. Add configurable daily wird and home continuation.
3. Add private progress summary and saved-item groups.
4. Add optional local reminders after permission and scheduling QA.
5. Validate every reset/delete/export path.

**Exit:** all progress remains private/local by default and can be reviewed, exported, and deleted.

### Phase P4 — Accessibility, integration, and release
1. Finish responsive layout and Arabic accessibility checks.
2. Run migration, offline, audio, permissions, and regression suites.
3. Complete physical-device QA on supported Android/iOS devices and desktop preview where applicable.
4. Complete privacy policy, source attribution, rights, store metadata, signing, and release checklists.
5. Publish only after all release gates are satisfied.

### Deferred / separate decisions
- Cloud account, Supabase, and sync: deferred until local MVP and privacy/sync design are approved.
- Recitation assessment/ASR: separate validated workstream, not a prerequisite for the audio player.
- Donations/payments: out of MVP and require separate legal/financial go/no-go.
- Public social/community features: not part of this approved immediate roadmap; safeguarding and moderation design required first.

## 10. Agent execution contract

The next coding agent must:

1. Read AGENTS.md and the mandatory project documents, this plan, docs/DECISIONS.md, docs/CONTENT_SOURCES.md, docs/SECURITY.md, docs/experiments/qcf-quran-plus-spike.md, and the current GitHub issue/handoff.
2. Inspect latest main, current CI, existing code, and open PRs/issues before editing. Do not assume previous assistant statements describe the current code accurately.
3. Create a unique branch from latest main and reserve exact paths on the work board. Do not edit main directly.
4. Work on one bounded phase/issue. Do not attempt the entire roadmap in one PR.
5. Start with P0. Reproduce the screenshot defect before modifying parser/layout code. If not reproducible, record evidence and test other plausible failure points rather than inventing a fix.
6. Keep canonical Quran text immutable. Any proposed source/page/font change requires a content-rights and integrity review.
7. Keep shared files, router, pubspec, Drift root/migrations, content registry, CI, STATUS, and WORK_BOARD under their designated owners.
8. Add automated tests for every fix and report exact commands/results. Physical-device checks must be labelled separately.
9. Update the issue-specific handoff with changed files, commit, validation, remaining risks, and next action.
10. Open a PR; do not self-merge or claim deployed/device-verified status without evidence.

## 11. Definition of done and status vocabulary

Use these labels precisely:
- **Planned:** documented only.
- **Implemented:** code exists in the branch/repository.
- **Tested:** named automated/manual test passed; include evidence.
- **Merged:** PR is in main.
- **Deployed:** exact artifact/service deployment is confirmed.
- **Device-verified:** tested on an identified physical device.
- **Blocked:** a rights, privacy, technical, or owner decision prevents progress.

A phase is not complete because its checklist was written or its CI workflow exists. The coordinator updates docs/STATUS.md only after verifying repository state and evidence.
