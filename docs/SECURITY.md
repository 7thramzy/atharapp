# Athaar security, privacy and content governance

## Data minimization

- The initial app works without a user account.
- Store bookmarks, notes, memorization progress, adhkar counts, and settings locally.
- Keep worship and learning data private by default.
- Do not expose personal progress to teachers, family groups, or communities without explicit opt-in.
- Provide local data export and deletion design before cloud sync.

## Audio and biometric privacy

- Show an explicit recording indicator and accessible stop/delete controls.
- Recordings are ephemeral by default.
- No upload, long-term retention, transcription service, or training use without explicit informed consent and an approved privacy design.
- A voice recording must not be treated as a biometric identity record.
- Do not use Quran Foundation content or user recordings for model training without a separate rights/consent decision; Quran Foundation's developer terms prohibit ML/AI training use of its content.

## Religious content safety

- Quran Arabic text is immutable.
- Translations are clearly labelled as translations of meanings.
- Every tafsir, translation, hadith, adhkar, and recitation record has source/edition/rights metadata.
- AI may not invent religious text, hadith attribution, or a legal ruling.
- AI-generated reflections must cite approved references and remain visibly distinct from reviewed material.
- Users can report incorrect content; disputed material can be disabled without deleting the source audit trail.

## Recitation assessment

- Speech recognition is not a proof of Tajweed correctness.
- Differentiate word alignment, memorization mismatch, pronunciation, and Tajweed.
- Show confidence and uncertainty. Do not present an uncertain model output as a definite Quranic reading error.
- Provide human teacher review for uncertain cases.
- Do not score or rank users' worship publicly.

## Mentorship and safeguarding

Before release of mentorship or group features:
- verify teacher identity and qualifications, and display what was actually verified;
- add report/block/moderation tools;
- establish safe session and messaging boundaries;
- define extra safeguards for minors and parental/guardian requirements where applicable;
- make user visibility and group sharing opt-in.

## Donations and financial controls

Donations are out of the MVP. Before any real collection:
- verify legal operating entity and jurisdiction;
- verify provider support for the operator's country, collection, holding and payout;
- separate case creation, verification, approval and disbursement;
- verify payment-provider webhooks server-side and make them idempotent;
- use an immutable double-entry ledger; corrections use reversal entries;
- reconcile provider statements and actual payouts;
- support refunds, failed payments and chargebacks;
- maintain audit logs and publish privacy-preserving reports.

A local button press or a payment redirect is not proof that a donation succeeded.

## App and supply-chain security

- No secrets, tokens, signing keys, keystores, private certificates, or service-role credentials in the repository.
- Pin dependencies and commit lockfiles.
- Use least privilege for future backend policies.
- Review every third-party package and asset.
- Do not install AGPL/GPL modules into the app without an explicit licensing decision.
- Check dependency advisories and secret scans in CI before release.
- No user recordings or private notes in logs, analytics, or test fixtures.
