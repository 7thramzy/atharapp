# Feature plan: Admin notifications, Adhkar, and sharing

Tracking issue: https://github.com/7thramzy/atharapp/issues/38

## Product scope

### Admin notifications
- A protected admin surface with server-side role checks; no admin credentials or provider secrets in the client.
- Draft, preview, immediate send, scheduled send, audience selection, delivery log, and failure reporting.
- Categories: daily wird reminders, morning/evening reminders, product announcements, and administrative notices.
- User controls for optional reminders, quiet hours, and local-time scheduling.
- Use a trusted server integration for push delivery (FCM/APNs); request OS permission in context and never assume it is granted.

### Offline adhkar and daily wird
- Categories: morning, evening, after salah, sleep/waking, home, mosque, food, wudu, travel, distress, and Quranic/Prophetic supplications.
- Each record carries Arabic text, repetition count, occasion, source citation, hadith grading when verifiably available, and source/license metadata.
- Bundle reviewed core data for offline use; optional data updates must be versioned and integrity-checked.
- Search, favorites, progress, and per-category completion.
- Never infer a hadith grading or attribution. Preserve variant morning/evening wording as separate reviewed forms.
- Dataset selection must be license-first. Retain required notices and review text against primary hadith references. Do not bundle third-party translations, audio, or editorial arrangement without separate rights clearance.

### Share an ayah
- Select one ayah or a range from the reader and render a high-resolution image card.
- Elegant Islamic visual templates; correct RTL, shaping, diacritics, waqf signs, and licensed Quran fonts.
- Modes: ayah only; ayah plus a user-selected licensed translation; ayah plus a short licensed tafsir excerpt with attribution.
- Preview before save/share; support common portrait and square aspect ratios.
- Never clip or silently omit any part of the selected ayah/range. Long selections must flow to additional cards or a readable multi-card layout.

### Share reading/recitation progress
- Separate templates for reading and recitation achievements.
- Show only selected metrics: reading amount, completed wird, recitation sessions, progress, and points.
- Points must be computed from trusted, auditable events with idempotency and anti-duplication controls.
- Do not award points merely for opening a screen or replaying a network request.
- Recording a recitation is not proof of correctness; no automated correctness score unless a separately validated and approved assessment system exists.
- Sharing is always user-initiated. Hide personal identifiers by default and allow each metric to be toggled off.

## Implementation sequence
1. Inspect current architecture and identify notification/backend readiness, existing adhkar models/screens, progress event sources, and image export dependencies.
2. Select and document an adhkar dataset only after license and attribution review; validate Arabic text and references before bundling.
3. Implement local-first adhkar repository, database migration, search/favorites/progress, and offline tests.
4. Implement share-card rendering and export for ayah/translation/tafsir and achievement variants.
5. Implement secure admin notification backend and user notification preferences; add client UI only after a trusted server path exists.
6. Add points ledger and event deduplication; keep scoring rules transparent and versioned.
7. Run unit, integration, RTL/visual regression, offline, permission, and device tests.

## Acceptance gates
- All core adhkar work offline and each entry has verifiable source metadata.
- License/attribution notices ship with all bundled datasets.
- No admin send capability can be invoked by an ordinary client.
- Scheduling respects local timezone, user preferences, and OS permissions.
- Image cards pass Arabic shaping/RTL/diacritics tests on long and short ayat and do not clip text.
- Points are reproducible from the event ledger and duplicate submissions cannot inflate totals.
- No user progress is shared without an explicit share action and preview.
