# Agent handoff — issue 2

## Identity

- Date: 2026-11-24
- Agent role/ID: ChatGPT integration coordinator — content review
- GitHub issue: #2
- Branch: agent/content/2-quran-font-rights
- Base commit: fe6ed64463db096ab8eb5f21c245bc3901590572
- Head commit: pending PR commit
- Reserved paths:
  - docs/content-reviews/quran-text.md
  - docs/content-reviews/mushaf-fonts.md
  - docs/agents/handoffs/issue-2.md

## Result

- Status: PARTIAL
- Summary: Completed official-source rights review. Tanzil Uthmani v1.1 is approved for verbatim in-app/offline redistribution subject to strict no-modification, attribution, source-link, and notice-preservation requirements. Cairo is approved for software bundling under OFL 1.1 with notices. KFGQPC is conditionally approved in principle, but the current official portal does not expose the exact font binary or resource-specific notice and marks the relevant resources as coming soon.
- Exact paths changed: the two resource dossiers and this handoff.
- Decisions made: no content/font binaries were downloaded or committed because issue #2 explicitly prohibits binary acquisition.

## Validation

| Command or check | Result | Notes |
|---|---|---|
| Official Tanzil text license reviewed | PASS | https://tanzil.net/docs/Text_License |
| Official Tanzil version history reviewed | PASS | https://tanzil.net/docs/text_updates |
| Official KFGQPC website reviewed | PASS | Relevant asset section currently says coming soon |
| Cairo upstream and OFL 1.1 reviewed | PASS | https://github.com/Gue3bara/Cairo |
| Flutter tests | NOT RUN | Documentation-only research task |
| Physical-device font rendering | NOT RUN | No font binary integrated |

## Source and safety review

- New dependency/assets: none.
- Source URL and exact version: Tanzil Uthmani v1.1; Cairo upstream font family; KFGQPC exact asset pending.
- License/attribution: documented in both dossiers.
- Privacy/security impact: none.
- Data migration impact: none.
- Secrets/media included: NO.

## Known gaps and blockers

- Tanzil exact file, options, embedded notice, byte count, retrieval timestamp, and SHA-256 must be recorded when the separate importer task acquires the data.
- KFGQPC exact font asset and its exact official usage-rights statement remain unavailable from the current official portal.
- Cairo exact binary and SHA-256 have not been acquired; its full OFL notice must accompany the eventual binary.

## Next recommended action

Create a bounded Quran-data acquisition/import issue: obtain the official Tanzil Uthmani v1.1 file, preserve its embedded notice verbatim, record its SHA-256 and retrieval metadata, then run the existing importer and integrity tests without modifying canonical text.

## Instructions for the next agent

- Relevant files/contracts: docs/content-reviews/quran-text.md; docs/content-reviews/mushaf-fonts.md; docs/CONTENT_SOURCES.md; existing Quran importer and manifest contract.
- Do not change: canonical Quran text, shared source registry, Drift schema, or pubspec without coordinator approval.
- Required prerequisite: use the exact Tanzil Uthmani v1.1 source and retain all source notices; do not substitute mirrors or Quran Foundation static data.
