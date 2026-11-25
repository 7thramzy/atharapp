import csv
import tempfile
import unittest
from pathlib import Path

from run_candidate import load_manifest


class CandidateManifestTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.audio = self.root / "sample.wav"
        self.audio.write_bytes(b"placeholder")
        self.training = self.root / "training_reciters.txt"
        self.training.write_text("training_reciter\n", encoding="utf-8")
        self.manifest = self.root / "test.csv"

    def tearDown(self):
        self.temp.cleanup()

    def _write_manifest(self, **overrides):
        columns = [
            "clip_id",
            "reciter_id",
            "qiraat",
            "complete_ayah",
            "speaker_split",
            "rights_cleared",
            "source_license",
            "reference",
            "audio_path",
        ]
        row = {
            "clip_id": "sample-001",
            "reciter_id": "heldout_reciter",
            "qiraat": "Hafs",
            "complete_ayah": "true",
            "speaker_split": "held-out",
            "rights_cleared": "true",
            "source_license": "CC0-1.0",
            "reference": "بسم الله الرحمن الرحيم",
            "audio_path": "sample.wav",
        }
        row.update(overrides)
        with self.manifest.open("w", encoding="utf-8", newline="") as handle:
            writer = csv.DictWriter(handle, fieldnames=columns)
            writer.writeheader()
            writer.writerow(row)

    def test_accepts_licensed_complete_hafs_ayah_from_heldout_reciter(self):
        self._write_manifest()
        rows = load_manifest(self.manifest, self.training)
        self.assertEqual(len(rows), 1)
        self.assertEqual(rows[0]["qiraat"], "Hafs")
        self.assertEqual(Path(rows[0]["audio_path"]), self.audio)

    def test_rejects_reciter_in_training_roster(self):
        self._write_manifest(reciter_id="training_reciter")
        with self.assertRaisesRegex(ValueError, "Speaker leakage"):
            load_manifest(self.manifest, self.training)

    def test_rejects_non_hafs_reading(self):
        self._write_manifest(qiraat="Warsh")
        with self.assertRaisesRegex(ValueError, "Hafs-only"):
            load_manifest(self.manifest, self.training)

    def test_rejects_partial_ayahs(self):
        self._write_manifest(complete_ayah="false")
        with self.assertRaisesRegex(ValueError, "Partial or unverified"):
            load_manifest(self.manifest, self.training)

    def test_rejects_samples_without_cleared_rights(self):
        self._write_manifest(rights_cleared="false")
        with self.assertRaisesRegex(ValueError, "Rights review"):
            load_manifest(self.manifest, self.training)

    def test_requires_a_training_reciter_roster(self):
        self._write_manifest()
        with self.assertRaisesRegex(FileNotFoundError, "training-reciter roster"):
            load_manifest(self.manifest, self.root / "missing.txt")


if __name__ == "__main__":
    unittest.main()
