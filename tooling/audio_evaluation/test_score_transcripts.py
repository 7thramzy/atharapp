import unittest

from score_transcripts import edit_distance, normalize_text, score_rows


class TranscriptScoringTests(unittest.TestCase):
    def test_normalization_removes_tashkeel_and_tatweel_only(self):
        self.assertEqual(normalize_text("بِسْمِ اللّٰهِ"), "بسم الله")
        self.assertEqual(normalize_text("الرَّحْمَٰن"), "الرحمن")

    def test_edit_distance_counts_substitution_insertion_and_deletion(self):
        self.assertEqual(edit_distance("كتاب", "كتابه"), 1)
        self.assertEqual(edit_distance("abc", "ac"), 1)
        self.assertEqual(edit_distance("abc", "axc"), 1)

    def test_score_rows_reports_exact_match_rate_and_error_rates(self):
        result = score_rows([
            {
                "clip_id": "a",
                "reference": "بِسْمِ اللَّهِ",
                "hypothesis": "بسم الله",
            },
            {
                "clip_id": "b",
                "reference": "الحمد لله",
                "hypothesis": "الحمد",
            },
        ])
        self.assertEqual(result["clips"], 2)
        self.assertEqual(result["exact_match_rate"], 0.5)
        self.assertAlmostEqual(result["wer"], 1 / 3)

    def test_duplicate_clip_ids_are_rejected(self):
        with self.assertRaisesRegex(ValueError, "Duplicate"):
            score_rows([
                {"clip_id": "same", "reference": "آية", "hypothesis": "آية"},
                {"clip_id": "same", "reference": "آية", "hypothesis": "آية"},
            ])

    def test_empty_reference_is_rejected(self):
        with self.assertRaisesRegex(ValueError, "Empty reference"):
            score_rows([
                {"clip_id": "empty", "reference": " ", "hypothesis": ""}
            ])


if __name__ == "__main__":
    unittest.main()
