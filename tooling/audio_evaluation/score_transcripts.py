#!/usr/bin/env python3
"""Score transcripts from an authorised local Quran ASR evaluation set.

Input CSV columns: clip_id,reference,hypothesis.
The script does not download audio, fetch models, or transmit any recording.
"""

from __future__ import annotations

import argparse
import csv
import json
import sys
import unicodedata
from pathlib import Path
from typing import Iterable


ARABIC_DIACRITICS = {
    codepoint
    for codepoint in range(0x0610, 0x061B)
} | {
    codepoint
    for codepoint in range(0x064B, 0x0660)
} | {0x0670}


def normalize_text(value: str) -> str:
    """Remove recitation marks and punctuation without rewriting letters."""
    output: list[str] = []
    for char in unicodedata.normalize("NFC", value):
        codepoint = ord(char)
        if codepoint in ARABIC_DIACRITICS or codepoint == 0x0640:
            continue
        if unicodedata.category(char).startswith("P"):
            output.append(" ")
        else:
            output.append(char)
    return " ".join("".join(output).split())


def edit_distance(reference: Iterable[str], hypothesis: Iterable[str]) -> int:
    """Levenshtein distance using O(min(n, m)) memory."""
    left = list(reference)
    right = list(hypothesis)
    if len(left) < len(right):
        left, right = right, left
    previous = list(range(len(right) + 1))
    for row_index, left_item in enumerate(left, start=1):
        current = [row_index]
        for column_index, right_item in enumerate(right, start=1):
            substitution = previous[column_index - 1] + (left_item != right_item)
            insertion = current[column_index - 1] + 1
            deletion = previous[column_index] + 1
            current.append(min(substitution, insertion, deletion))
        previous = current
    return previous[-1]


def score_rows(rows: list[dict[str, str]]) -> dict[str, object]:
    if not rows:
        raise ValueError("The input contains no transcript rows.")

    total_words = 0
    total_word_errors = 0
    total_chars = 0
    total_char_errors = 0
    exact_matches = 0
    seen_ids: set[str] = set()

    for line_number, row in enumerate(rows, start=2):
        clip_id = (row.get("clip_id") or "").strip()
        reference = normalize_text(row.get("reference") or "")
        hypothesis = normalize_text(row.get("hypothesis") or "")
        if not clip_id:
            raise ValueError("Missing clip_id on CSV line " + str(line_number))
        if clip_id in seen_ids:
            raise ValueError("Duplicate clip_id: " + clip_id)
        seen_ids.add(clip_id)
        if not reference:
            raise ValueError("Empty reference for clip " + clip_id)

        reference_words = reference.split()
        hypothesis_words = hypothesis.split()
        word_errors = edit_distance(reference_words, hypothesis_words)
        char_errors = edit_distance(list(reference), list(hypothesis))
        total_words += len(reference_words)
        total_word_errors += word_errors
        total_chars += len(reference)
        total_char_errors += char_errors
        if reference_words == hypothesis_words:
            exact_matches += 1

    return {
        "clips": len(rows),
        "exact_match_rate": exact_matches / len(rows),
        "wer": total_word_errors / total_words if total_words else 0.0,
        "cer": total_char_errors / total_chars if total_chars else 0.0,
        "word_errors": total_word_errors,
        "reference_words": total_words,
        "character_errors": total_char_errors,
        "reference_characters": total_chars,
        "normalization": "NFC; remove Arabic tashkeel/tatweel and punctuation; preserve letters",
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("csv_file", type=Path, help="Local CSV from an authorised evaluation")
    args = parser.parse_args()

    try:
        with args.csv_file.open("r", encoding="utf-8-sig", newline="") as handle:
            reader = csv.DictReader(handle)
            required = {"clip_id", "reference", "hypothesis"}
            if not required.issubset(set(reader.fieldnames or [])):
                raise ValueError(
                    "CSV must contain columns: clip_id,reference,hypothesis"
                )
            result = score_rows(list(reader))
    except (OSError, csv.Error, ValueError) as error:
        print("Evaluation input error: " + str(error), file=sys.stderr)
        return 2

    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
