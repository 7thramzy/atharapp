# Local Quran ASR evaluation (isolated from Athaar)

This directory contains a reproducible local-only harness for evaluating
Abdou/quran-asr-small. It is not imported by Flutter and does not upload
recordings.

## Candidate model

- Model: https://huggingface.co/Abdou/quran-asr-small
- Expected local files: model.int8.onnx and tokens.txt
- Model revision pinned by default:
  5d36fbd7934f9d9a10ab0cc67df07065e35f6871
- Runtime: sherpa-onnx Zipformer CTC, CPU.

The candidate's published metrics are author-reported, not reproduced by Athaar.
The candidate is not integrated into the app.

## Dataset gate

The evaluator intentionally refuses to run unless every row contains:

- qiraat=Hafs (the first benchmark is Hafs-only),
- complete_ayah=true (partial phonetic clips do not receive an invented full-ayah reference),
- speaker_split=held-out,
- a reciter ID absent from the supplied model-training reciter roster,
- rights_cleared=true and a non-empty source_license,
- a full, human-checked reference text and an existing local audio file.

The model card does not publish a complete, independently auditable list of its
training reciter IDs in the information reviewed for this assessment. Obtain
that roster from the model maintainer before claiming a speaker-disjoint test.
Do not mark rights_cleared=true unless the exact dataset release, audio
provenance, and licence have been reviewed.

AQQD is a potentially useful CC0 dataset, but its paper says the release has no
separate transcripts or phonetic alignments. Its filename metadata alone does
not prove that an audio clip contains a complete Hafs ayah. AQQD clips must be
audited and curated before they enter the manifest.

## Manifest

Create a UTF-8 CSV with these columns:

clip_id,reciter_id,qiraat,complete_ayah,speaker_split,rights_cleared,source_license,reference,audio_path

Paths may be absolute or relative to the manifest file. The reference must
be the exact full ayah text reviewed against the recording. The training
reciter roster is a UTF-8 text file with one reciter identifier per line.

## Run

Install the optional inference dependencies in a virtual environment:

python -m pip install -r tooling/audio_evaluation/requirements.txt

Place the pinned model files in a local directory, then run:

python tooling/audio_evaluation/run_candidate.py --manifest /path/to/test.csv --training-reciters /path/to/training-reciters.txt --model-dir /path/to/quran-asr-small --output /path/to/results.csv

The script writes:
- a transcript CSV with each reference and model hypothesis,
- a JSON metrics file with WER, CER, exact-ayah transcript match rate,
  mean/p95 CPU latency, and real-time factor.

No audio is uploaded or sent to a service. Results are valid only for the
provided manifest and model revision.

## What this does not prove

- It does not measure Android latency, memory, battery, or thermal impact.
- It does not score tajweed, makharij, or vowel/diacritic correctness.
- It cannot issue religious judgments or automatically certify a recitation.
- A wrong or uncertain transcript must be labelled "غير متأكد"; do not silently
  mark a user's recitation as correct.
- A phone-device benchmark and qualified human review are still required
  before integrating the model into Athaar.
