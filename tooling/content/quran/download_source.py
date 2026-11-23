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
    "&marks=true&sajdah=true&rub=true"
)
ROOT = Path(__file__).resolve().parents[3]
OUT = ROOT / "build/tanzil-acquisition"
OUT.mkdir(parents=True, exist_ok=True)
raw_path = OUT / "quran-uthmani-v1.1.txt"
metadata_url = "https://tanzil.net/res/text/metadata/quran-data.xml"
metadata_path = OUT / "quran-data.xml"
request = Request(URL, headers={"User-Agent": "Athaar-Quran-Source-Acquisition/1.0"})
with urlopen(request, timeout=60) as response:
    raw = response.read()
    final_url = response.geturl()
    content_type = response.headers.get("Content-Type", "")
if not raw or b"<html" in raw[:512].lower():
    raise SystemExit("Official Tanzil endpoint did not return a plain text Quran file.")
text = raw.decode("utf-8-sig")
raw_path.write_bytes(raw)
metadata_request = Request(metadata_url, headers={"User-Agent": "Athaar-Quran-Source-Acquisition/1.0"})
with urlopen(metadata_request, timeout=60) as response:
    metadata_xml = response.read()
    metadata_content_type = response.headers.get("Content-Type", "")
if not metadata_xml.lstrip().startswith(b"<?xml") and b"<quran" not in metadata_xml[:512].lower():
    raise SystemExit("Official Tanzil metadata endpoint did not return XML.")
metadata_path.write_bytes(metadata_xml)
required_notice = (
    "Tanzil Quran Text",
    "Creative Commons Attribution 3.0",
    "CHANGING IT IS NOT ALLOWED",
    "tanzil.net",
)
missing = [part for part in required_notice if part.lower() not in text.lower()]
if "copyright" not in text.lower():
    missing.append("copyright notice")
if missing:
    print("Downloaded file tail for notice review:", repr(text[-2400:]))
    raise SystemExit("Downloaded file is missing required Tanzil notice text: " + ", ".join(missing))
metadata = {
    "source": "Tanzil Project",
    "source_url": final_url,
    "metadata_source_url": metadata_url,
    "metadata_filename": metadata_path.name,
    "metadata_byte_count": len(metadata_xml),
    "metadata_sha256": sha256(metadata_xml).hexdigest(),
    "metadata_content_type": metadata_content_type,
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
        "sequential_tanweens": False,
    },
    "license_notice_preserved": True,
    "raw_file_line_count": len(text.splitlines()),
}
(OUT / "source-manifest.json").write_text(
    json.dumps(metadata, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
)
print(json.dumps(metadata, ensure_ascii=False, indent=2))
