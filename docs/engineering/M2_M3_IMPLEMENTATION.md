# M2 + M3 implementation notes

## M2 — Quran reader foundation
- Added Drift v2 tables for immutable Quran reference text, source manifest, bookmarks, and private verse notes.
- Added an atomic JSON import contract requiring 114 surahs, matching verse totals, unique/non-empty ayahs, source metadata, license notice, and a 64-character SHA-256 manifest value.
- Added surah navigation, verse display, search, bookmark, note, and last-reading persistence UI.
- The application deliberately ships no Quran text payload until the exact Tanzil Uthmani v1.1 download, its checksum, and the required notice are checked and recorded. The reader displays a clear import-pending state rather than fabricated content.
- Search uses a separate normalized field; canonical Uthmani text is never rewritten.

## M3 — Adhkar, memorization, personal impact
- Added local adhkar entries with required source-reference field, daily counters, and atomic increments.
- New user-entered entries are marked unverified; this UI does not claim that a source was independently authenticated.
- Added per-ayah memorization states and range-based revision sessions.
- Added a private impact summary derived from saved local activity, not a public score or ranking.
- No account, server sync, audio upload, AI religious judgement, or public worship leaderboard is introduced.

## Known acceptance gates
- Import a licensed and hash-verified Quran dataset before the Quran screen can show actual text.
- Complete independent review of every adhkar source before shipping a pre-populated curated catalog.
- Run CI on the merged main commit and resolve any analyzer/build/test findings.
- Validate Arabic shaping, RTL, accessibility, and persistence on physical Android/iOS devices.
