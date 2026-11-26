#!/usr/bin/env python3
"""Run the isolated quran-asr-small ONNX candidate on a local licensed test set.

The runner is deliberately separate from the Flutter app. It reads local WAV
files and a reviewer-prepared CSV, and never uploads audio or contacts a server.
"""

from __future__ import annotations

import argparse
import csv
import json
import math
import statistics
import sys
import time
import unicodedata
from pathlib import Path
from typing import Any

from score_transcripts import score_rows

DEFAULT_MODEL_ID = "Abdou/quran-asr-small"
DEFAULT_MODEL_REVISION = "5d36fbd7934f9d9a10ab0cc67df07065e35f6871"
SAMPLE_RATE = 16_000

REQUIRED_COLUMNS = {
    "clip_id",
    "reciter_id",
    "qiraat",
    "complete_ayah",
    "speaker_split",
    "rights_cleared",
    "source_license",
    "reference",
    "audio_path",
}


def _is_true(value: str) -> bool:
    return value.strip().lower() in {"1", "true", "yes", "y"}


def _normalise_qiraat(value: str) -> str:
    folded = unicodedata.normalize("NFKD", value).casefold()
    return "".join(char for char in folded if char.isalnum())


def read_training_reciters(path: Path) -> set[str]:
    if not path.is_file():
        raise FileNotFoundError(
            "A training-reciter roster is required to prove speaker separation: "
            + str(path)
        )
    return {
        line.strip().casefold()
        for line in path.read_text(encoding="utf-8").splitlines()
        if line.strip() and not line.lstrip().startswith("#")
    }


def load_manifest(
    manifest_path: Path,
    training_reciters_path: Path,
) -> list[dict[str, str]]:
    if not manifest_path.is_file():
        raise FileNotFoundError("Manifest not found: " + str(manifest_path))

    training_reciters = read_training_reciters(training_reciters_path)
    rows: list[dict[str, str]] = []
    seen_clip_ids: set[str] = set()

    with manifest_path.open("r", encoding="utf-8-sig", newline="") as handle:
        reader = csv.DictReader(handle)
        columns = set(reader.fieldnames or [])
        missing = sorted(REQUIRED_COLUMNS - columns)
        if missing:
            raise ValueError(
                "Manifest is missing required columns: " + ", ".join(missing)
            )

        for line_number, raw in enumerate(reader, start=2):
            row = {key: (value or "").strip() for key, value in raw.items() if key}
            clip_id = row["clip_id"]
            reciter_id = row["reciter_id"]
            if not clip_id:
                raise ValueError("Empty clip_id on manifest line " + str(line_number))
            if clip_id in seen_clip_ids:
                raise ValueError("Duplicate clip_id: " + clip_id)
            seen_clip_ids.add(clip_id)

            if not reciter_id:
                raise ValueError("Missing reciter_id for clip " + clip_id)
            if reciter_id.casefold() in training_reciters:
                raise ValueError(
                    "Speaker leakage: test reciter " + reciter_id
                    + " is listed in the model training roster."
                )

            if _normalise_qiraat(row["qiraat"]) not in {"hafs", "hafsanasim"}:
                raise ValueError(
                    "The first evaluation is Hafs-only; invalid qiraat for clip "
                    + clip_id + ": " + row["qiraat"]
                )
            if not _is_true(row["complete_ayah"]):
                raise ValueError(
                    "Partial or unverified ayah clips cannot enter WER/CER: "
                    + clip_id
                )
            if row["speaker_split"].casefold() not in {"test", "heldout", "held-out"}:
                raise ValueError("Clip is not assigned to the held-out test split: " + clip_id)
            if not _is_true(row["rights_cleared"]) or not row["source_license"]:
                raise ValueError(
                    "Rights review and source_license are required for clip " + clip_id
                )
            if not row["reference"]:
                raise ValueError("Missing full-ayah reference for clip " + clip_id)

            audio_path = Path(row["audio_path"])
            if not audio_path.is_absolute():
                audio_path = (manifest_path.parent / audio_path).resolve()
            if not audio_path.is_file():
                raise FileNotFoundError(
                    "Audio file not found for clip " + clip_id + ": " + str(audio_path)
                )
            row["audio_path"] = str(audio_path)
            rows.append(row)

    if not rows:
        raise ValueError("The manifest has no eligible clips.")
    return rows


def load_audio_16khz(path: Path) -> Any:
    try:
        import numpy as np
        import soundfile as sf
        from scipy.signal import resample_poly
    except ImportError as error:
        raise RuntimeError(
            "Install the evaluation dependencies from tooling/audio_evaluation/requirements.txt."
        ) from error

    audio, sample_rate = sf.read(
        str(path),
        dtype="float32",
        always_2d=True,
    )
    if audio.size == 0 or sample_rate <= 0:
        raise ValueError("Empty or invalid audio file: " + str(path))

    mono = audio.mean(axis=1, dtype=np.float32)
    if not np.isfinite(mono).all():
        raise ValueError("Audio contains NaN or infinite samples: " + str(path))
    if float(np.max(np.abs(mono))) < 1e-6:
        raise ValueError("Audio is silent: " + str(path))

    if sample_rate != SAMPLE_RATE:
        divisor = math.gcd(int(sample_rate), SAMPLE_RATE)
        mono = resample_poly(
            mono,
            SAMPLE_RATE // divisor,
            int(sample_rate) // divisor,
        ).astype(np.float32)
    return mono


def run_inference(
    rows: list[dict[str, str]],
    model_path: Path,
    tokens_path: Path,
    num_threads: int,
) -> tuple[list[dict[str, str]], list[float], float]:
    if not model_path.is_file():
        raise FileNotFoundError("ONNX model not found: " + str(model_path))
    if not tokens_path.is_file():
        raise FileNotFoundError("Tokenizer file not found: " + str(tokens_path))
    try:
        import sherpa_onnx
    except ImportError as error:
        raise RuntimeError(
            "Install sherpa-onnx using the evaluation requirements file."
        ) from error

    recognizer = sherpa_onnx.OfflineRecognizer.from_zipformer_ctc(
        model=str(model_path),
        tokens=str(tokens_path),
        num_threads=num_threads,
    )

    outputs: list[dict[str, str]] = []
    latencies: list[float] = []
    audio_seconds = 0.0

    for row in rows:
        waveform = load_audio_16khz(Path(row["audio_path"]))
        duration = len(waveform) / SAMPLE_RATE
        stream = recognizer.create_stream()

        start = time.perf_counter()
        stream.accept_waveform(SAMPLE_RATE, waveform)
        recognizer.decode_stream(stream)
        elapsed = time.perf_counter() - start

        raw_text = stream.result.text.replace("▁", " ").strip()
        hypothesis = " ".join(raw_text.split())
        outputs.append(
            {
                "clip_id": row["clip_id"],
                "reference": row["reference"],
                "hypothesis": hypothesis,
                "reciter_id": row["reciter_id"],
                "audio_seconds": f"{duration:.6f}",
                "inference_seconds": f"{elapsed:.6f}",
            }
        )
        latencies.append(elapsed)
        audio_seconds += duration

    return outputs, latencies, audio_seconds


def write_results(path: Path, rows: list[dict[str, str]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    columns = [
        "clip_id",
        "reference",
        "hypothesis",
        "reciter_id",
        "audio_seconds",
        "inference_seconds",
    ]
    with path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=columns)
        writer.writeheader()
        writer.writerows(rows)


def build_report(
    rows: list[dict[str, str]],
    outputs: list[dict[str, str]],
    latencies: list[float],
    audio_seconds: float,
    model_id: str,
    model_revision: str,
) -> dict[str, object]:
    metric_rows = [
        {
            "clip_id": item["clip_id"],
            "reference": item["reference"],
            "hypothesis": item["hypothesis"],
        }
        for item in outputs
    ]
    report = score_rows(metric_rows)
    sorted_latencies = sorted(latencies)
    p95_index = max(0, math.ceil(0.95 * len(sorted_latencies)) - 1)
    report.update(
        {
            "model_id": model_id,
            "model_revision": model_revision,
            "test_reciters": len({row["reciter_id"] for row in rows}),
            "audio_hours": audio_seconds / 3600,
            "total_inference_seconds": sum(latencies),
            "mean_inference_seconds_per_clip": statistics.mean(latencies),
            "p95_inference_seconds_per_clip": sorted_latencies[p95_index],
            "real_time_factor": (
                sum(latencies) / audio_seconds if audio_seconds > 0 else None
            ),
            "speaker_split": "held-out; checked against supplied training roster",
            "qiraat": "Hafs only",
            "note": (
                "Desktop CPU result only. This is not an Android latency, "
                "battery, thermal, Tajweed, or religious-accuracy measurement."
            ),
        }
    )
    return report


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", required=True, type=Path)
    parser.add_argument("--training-reciters", required=True, type=Path)
    parser.add_argument("--model-dir", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--model-id", default=DEFAULT_MODEL_ID)
    parser.add_argument("--model-revision", default=DEFAULT_MODEL_REVISION)
    parser.add_argument("--num-threads", type=int, default=2)
    args = parser.parse_args()

    if args.num_threads < 1 or args.num_threads > 32:
        parser.error("--num-threads must be between 1 and 32")

    try:
        rows = load_manifest(args.manifest, args.training_reciters)
        outputs, latencies, audio_seconds = run_inference(
            rows=rows,
            model_path=args.model_dir / "model.int8.onnx",
            tokens_path=args.model_dir / "tokens.txt",
            num_threads=args.num_threads,
        )
        write_results(args.output, outputs)
        report = build_report(
            rows=rows,
            outputs=outputs,
            latencies=latencies,
            audio_seconds=audio_seconds,
            model_id=args.model_id,
            model_revision=args.model_revision,
        )
        report_path = args.output.with_suffix(".metrics.json")
        report_path.write_text(
            json.dumps(report, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
    except (OSError, ValueError, RuntimeError) as error:
        print("Evaluation failed safely: " + str(error), file=sys.stderr)
        return 2

    print(json.dumps(report, ensure_ascii=False, indent=2))
    print("Transcript output: " + str(args.output))
    print("Metrics output: " + str(report_path))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
