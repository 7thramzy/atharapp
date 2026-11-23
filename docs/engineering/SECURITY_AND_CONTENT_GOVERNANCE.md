# Security and Content Governance

Trust is a core product requirement for Athaar. This document applies before any community, AI, or financial feature is released.

## Personal data and audio

- Collect only information required for a clearly stated feature.
- Keep worship and memorization records private by default.
- Do not expose a user's activity to a group, family member, teacher, or public profile without an explicit user action.
- Audio capture must show an obvious recording state and provide clear stop/delete controls.
- Do not retain recordings or upload them for model training by default.
- Before any audio upload, obtain explicit informed consent and disclose purpose, destination, retention period, and deletion pathway.
- Do not use a recording for a different purpose than the user approved.
- Protect local databases and future credentials using platform security facilities where appropriate.

## Quran and religious content

- Use a named and documented source for Quran text, translations, tafsir, hadith, adhkar, and recitation audio.
- Keep Quran Arabic text immutable in storage and display. Any search-normalized form is separate.
- Treat translations as translations of meaning, not as the Arabic Quran.
- Keep citation/source metadata with reflection content.
- Do not let a language model invent a verse, hadith attribution, legal ruling, or scholarly position.
- AI-assisted reflections must be labelled and reviewed under a defined editorial process before being promoted as authoritative material.
- Provide a correction/report path for inaccurate content.

## Recitation assessment

- A speech-to-text result is not proof of Tajweed correctness.
- The system should distinguish missing/repeated/substituted words from pronunciation and Tajweed evaluation.
- Show confidence and uncertainty; avoid presenting uncertain matches as definite mistakes.
- Provide a route to a qualified human teacher when needed.
- Evaluate across different voices, accents, devices, environments, speeds, and recitation styles.
- Do not score or rank worshippers publicly.

## Mentorship, groups, and safeguarding

Before release, define:
- Teacher identity and qualification checks.
- Clear distinction between verified and unverified profiles.
- Reporting, blocking, and moderation workflows.
- Safe session design and communication boundaries.
- Additional safeguards where minors may use the platform.
- Data visibility and parental/guardian controls where legally required.

## Donations and financial controls

Donations remain disabled until a separate compliance review is approved.

Required controls:
- Verified legal operator and eligible payment provider.
- Documented case intake and independent approval.
- Separation between case creation, approval, and disbursement.
- Server-side verification of payment-provider webhooks.
- Idempotency keys and duplicate-payment protection.
- Immutable double-entry ledger; corrections by reversal, not destructive edits.
- Reconciliation against provider statements and actual payouts.
- Refund, failed-payment, chargeback, and incident procedures.
- Auditable public reporting that does not reveal beneficiary-sensitive data.

A progress bar is not evidence of money received or paid out. The user interface must distinguish pledges, confirmed payments, refunds, and disbursements.

## Security baseline

- Validate all input at the application and future server boundaries.
- Avoid storing secrets in the app bundle or repository.
- Use least privilege and explicit authorization.
- Future exposed backend tables must use row-level access control and be tested against unauthorized cross-user access.
- Log security-relevant administrative actions without leaking personal or secret data.
- Define data export/deletion, backup, and incident-response procedures before cloud accounts are introduced.
