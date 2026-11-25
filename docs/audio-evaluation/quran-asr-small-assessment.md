# Local Quran recitation recognition — independent evaluation

**Review date:** 2026-11-25  
**Candidate:** `Abdou/quran-asr-small`  
**Status:** Research candidate only; not integrated into Athaar.

## What the candidate claims

The model card describes a Conformer-CTC Arabic Quran-recitation recognizer with approximately 33 million parameters and an int8 ONNX export of roughly 36 MB. It reports 4.49% word error rate and 2.17% character error rate on its stated Quran-Lab test set.

These figures are model-card claims, not an independent Athaar benchmark. They must not be represented as verified accuracy for Athaar users.

## Licensing and dataset gate

The model card identifies MIT for the model repository, but the underlying training sources retain their own terms. A model-code licence does not grant blanket rights over every training recording or benchmark recording.

The candidate references Quran-Lab/TLOG and related recitation datasets. The Quran-Lab evaluation set is gated and requires the evaluator to accept its research/evaluation conditions. The NPL-1.2 terms are not a blanket commercial-use permission and restrict uses that go beyond the permitted scope. Athaar must not redistribute that dataset, use recordings for voice cloning, or reuse the recordings for model training.

No recording from an Athaar user may be uploaded for this assessment. No recording may be retained or used without explicit, informed permission and a documented retention/deletion policy.

## Evaluation plan

The model remains isolated from the production app until the following independent tests pass:

1. Obtain authorised access to the complete evaluation set and keep it in a controlled evaluation environment.
2. Preserve a speaker-disjoint holdout; do not train or tune on the test speakers.
3. Test clean studio audio and realistic phone recordings separately.
4. Score WER and CER, plus exact-ayah identification accuracy.
5. Report omission, repetition, substitution, and wrong-surah errors separately.
6. Measure false alarms and abstention/uncertain rates, not just average accuracy.
7. Measure latency, peak memory, package size, thermal behavior, and battery impact on representative Android devices.
8. Test Arabic diacritics, pauses, repeated phrases, similar ayat, background noise, and recitations from the Hafs reading.
9. Obtain a qualified human review of error examples before any user-facing correction labels are enabled.

The engine may only provide a tentative transcript/alignment and must be able to return “غير متأكد”. It must not judge Tajweed, pronounce a religious ruling, or mark a passage as correct when confidence is low. Tajweed evaluation requires a separate qualified human-led process.

## Current outcome

**Not independently benchmarked and not integrated.** The gated benchmark and its use conditions have not been accepted or provisioned in this repository session, and no licensed, speaker-disjoint evaluation recordings were supplied. Therefore no honest independent WER/CER or Android latency result can be reported yet.

A deterministic WER/CER scoring utility and unit tests are being added under `tooling/audio_evaluation/`. It accepts a local CSV of authorised references and model hypotheses; it is not an inference engine and does not download audio or models.

## Sources

- Model card: https://huggingface.co/Abdou/quran-asr-small
- Quran-Lab benchmark: https://huggingface.co/datasets/quran-lab/quran-lab
- Benchmark terms: https://huggingface.co/datasets/quran-lab/quran-lab/blob/main/LICENSE
