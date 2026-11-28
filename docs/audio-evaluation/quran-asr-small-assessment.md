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

## Additional open evaluation candidate: AQQD

AQQD (Annotated Quranic Qira'at Dataset), published in 2026, provides 24,183 WAV clips from 309 reciters across 70 surahs under a stated CC0 1.0 licence. The dataset paper says the release includes structured filename metadata for reciter, Qira'at style, surah, ayah, and clip number.

Important limitation: the paper explicitly says that this release contains no separate transcripts, transcript annotations, phonetic alignments, or precomputed features. Therefore AQQD is **not immediately a WER/CER benchmark**. The filename gives a surah/ayah reference but does not, by itself, prove that every clip contains the complete ayah in the Hafs wording. Some samples are selected around phonetic variation points and the dataset covers several canonical Qira'at styles.

Before using AQQD for ASR scoring:

1. Obtain the deposited metadata workbook and README and map every Qira'at code to its actual recitation style.
2. Isolate Hafs samples only for the first Hafs model assessment. Do not compare a Hafs-only recognizer against Warsh or another Qira'a as though it were a recognition error.
3. Confirm whether each chosen clip contains the complete ayah or a partial phonetic segment. Only clips with a verified full text target can contribute to WER/CER.
4. Create a speaker-disjoint holdout by reciter identifier; do not split recordings from the same reciter across development and test sets.
5. Independently audit a stratified subset of the audio-to-ayah labels against the source recording before calculating metrics.
6. Preserve the CC0 dataset citation and exact dataset release/DOI in every benchmark report.

AQQD is a viable rights-cleared **candidate for a controlled audio stress-test and recitation-style subset analysis**, but the current public release's missing transcript/alignment files mean it does not yet close the need for an auditable speaker-disjoint WER/CER benchmark.

## Current outcome

**Not independently benchmarked and not integrated.** The model weights have not been run in this environment, and no authorized speaker-disjoint set with confirmed full-ayah transcripts has yet been prepared. No genuine independent WER/CER, exact-ayah accuracy, latency, memory, thermal, or battery result can be reported.

## Sources

- Model card: https://huggingface.co/Abdou/quran-asr-small
- Quran-Lab benchmark: https://huggingface.co/datasets/quran-lab/quran-lab
- AQQD 2026 dataset paper and CC0 data availability statement: https://doi.org/10.1016/j.dib.2026.112972
- AQQD Harvard Dataverse record: https://doi.org/10.7910/DVN/A8GM5Y
- Benchmark terms: https://huggingface.co/datasets/quran-lab/quran-lab/blob/main/LICENSE

## 2026-11-28 model-card recheck

The current Hugging Face model card describes `Abdou/quran-asr-small` as a 33M-parameter Conformer-CTC recognizer with an approximately 36 MB int8 ONNX model and MIT licensing for the model repository. It reports 4.49% WER / 2.17% CER on a 600-clip Quran-Lab test and 0.46% WER / 0.30% CER on a 1,000-clip unseen-reciter test. These are author-published results, not results reproduced by Athaar.

The model card lists training material from 36 EveryAyah Hafs reciters, 3 Warsh reciters, Tarteel TLOG phone recordings, and Iqra'Eval Quranic sentences. The model card itself says training data retains its own terms. The MIT model license must not be interpreted as a license to redistribute, train on, or benchmark against the underlying audio datasets. Exact recording-level permissions and a fully auditable training-reciter roster remain required.

The model's transcript is not a Tajweed assessment and is not guaranteed to preserve diacritics. Ayah retrieval is a separate approximate matching stage and may be ambiguous when phrases repeat. A recognition hypothesis must never be treated as a definitive religious correctness judgment.

**Updated decision: NOT APPROVED FOR PRODUCTION INTEGRATION.** No model weights have been executed or benchmarked by Athaar, no speaker-disjoint full-ayah dataset with verified rights and references is ready, and no Android device performance or error review has been completed. Keep the candidate isolated in `tooling/audio_evaluation`; do not advertise automated tasmee as available.

Source checked: https://huggingface.co/Abdou/quran-asr-small
