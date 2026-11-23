#!/usr/bin/env python3
"""Acquire the verbatim Tanzil Uthmani v1.1 source from Tanzil's official endpoint."""
from datetime import datetime, timezone
from hashlib import sha256
from pathlib import Path
from urllib.request import Request, urlopen
import json

URL = (
    "https://tanzil.net/pub/download/index.php"
    "?quranType=uthmani&outType=txt-2&agree=true"
    "&marks=true&sajdah=true&rub=true&stanween=true"
)
ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "build/tanzil-acquisition"
OUT.mkdir(parents=True, exist_ok=True)
raw_path = OUT / "quran-uthmani-v1.1.txt"
request = Request(URL, headers={"User-Agent": "Athaar-Quran-Source-Acquisition/1.0"})
with urlopen(request, timeout=60) as response:
    raw = response.read()
    final_url = response.geturl()
    content_type = response.headers.get("Content-Type", "")
if not raw or b"<html" in raw[:512].lower():
    raise SystemExit("Official Tanzil endpoint did not return a plain text Quran file.")
text = raw.decode("utf-8-sig")
required_notice = (
    "Tanzil Quran Text",
    "Copyright (C) 2007-2021 Tanzil Project",
    "CHANGING IT IS NOT ALLOWED",
)
missing = [part for part in required_notice if part not in text]
if missing:
    raise SystemExit("Downloaded file is missing required Tanzil notice text: " + ", ".join(missing))
raw_path.write_bytes(raw)
metadata = {
    "source": "Tanzil Project",
    "source_url": final_url,
    "requested_url": URL,
    "edition": "Uthmani",
    "version": "1.1",
    "retrieved_at_utc": datetime.now(timezone.utc).isoformat(),
    "content_type": content_type,
    "filename": raw_path.name,
    "byte_count": len(raw),
    "sha256": sha256(raw).hexdigest(),
    "download_options": {
        "pause_marks": True,
        "sajdah_signs": True,
        "rub_el_hizb_signs": True,
        "tatweel_below_superscript_alefs": False,
        "sequential_tanweens": True,
    },
    "license_notice_preserved": True,
    "raw_file_line_count": len(text.splitlines()),
}
(OUT / "source-manifest.json").write_text(
    json.dumps(metadata, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
)
print(json.dumps(metadata, ensure_ascii=False, indent=2))
