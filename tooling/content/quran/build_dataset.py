#!/usr/bin/env python3
"""Build Athaar's deterministic offline import JSON from official Tanzil files."""
from bisect import bisect_right
from hashlib import sha256
from pathlib import Path
import json
import re
import xml.etree.ElementTree as ET
import unicodedata

ROOT = Path(__file__).resolve().parents[3]
DATA_DIR = ROOT / "build/tanzil-acquisition"
TEXT_PATH = DATA_DIR / "quran-uthmani-v1.1.txt"
XML_PATH = DATA_DIR / "quran-data.xml"
SOURCE_MANIFEST_PATH = DATA_DIR / "source-manifest.json"
OUTPUT_PATH = DATA_DIR / "tanzil-uthmani-v1.1.json"

source_manifest = json.loads(SOURCE_MANIFEST_PATH.read_text(encoding="utf-8"))
raw_bytes = TEXT_PATH.read_bytes()
raw_text = raw_bytes.decode("utf-8-sig")
metadata_bytes = XML_PATH.read_bytes()
metadata_root = ET.fromstring(metadata_bytes)

notice_marker = "# PLEASE DO NOT REMOVE OR CHANGE THIS COPYRIGHT BLOCK"
notice_offset = raw_text.find(notice_marker)
if notice_offset < 0:
    raise SystemExit("The exact Tanzil copyright block is missing from the source file.")
license_notice = raw_text[notice_offset:].rstrip("\r\n")
for required in ("Tanzil Quran Text", "Copyright", "Creative Commons Attribution 3.0",
                 "CHANGING IT IS NOT ALLOWED", "tanzil.net"):
    if required.lower() not in license_notice.lower():
        raise SystemExit(f"The embedded Tanzil notice is missing: {required}")

records = []
for line_number, line in enumerate(raw_text.splitlines(), start=1):
    parts = line.split("|", 2)
    if len(parts) != 3 or not parts[0].isdigit() or not parts[1].isdigit():
        continue
    surah_number, ayah_number = int(parts[0]), int(parts[1])
    text_uthmani = parts[2]
    if not text_uthmani:
        raise SystemExit(f"Empty canonical text at source line {line_number}.")
    records.append((surah_number, ayah_number, text_uthmani))

sura_elements = metadata_root.find("suras")
if sura_elements is None:
    raise SystemExit("Official Tanzil metadata has no suras section.")
surah_meta = []
for element in sura_elements.findall("sura"):
    surah_meta.append({
        "surahNumber": int(element.attrib["index"]),
        "nameArabic": element.attrib["name"],
        "nameTransliteration": element.attrib["tname"],
        "ayahCount": int(element.attrib["ayas"]),
    })
if len(surah_meta) != 114 or len(records) != 6236:
    raise SystemExit(f"Unexpected Quran structure: {len(surah_meta)} surahs, {len(records)} ayahs.")

counts = [0] * 115
expected_next = [1] * 115
for surah_number, ayah_number, _ in records:
    if not 1 <= surah_number <= 114 or ayah_number != expected_next[surah_number]:
        raise SystemExit(f"Duplicate or unordered source ayah: {surah_number}:{ayah_number}")
    expected_next[surah_number] += 1
    counts[surah_number] += 1
for index, surah in enumerate(surah_meta, start=1):
    if surah["surahNumber"] != index or surah["ayahCount"] != counts[index]:
        raise SystemExit(f"Official metadata mismatch for surah {index}.")

def boundaries(section_name: str, item_name: str):
    section = metadata_root.find(section_name)
    if section is None:
        raise SystemExit(f"Official metadata is missing {section_name}.")
    values = []
    for item in section.findall(item_name):
        values.append((
            int(item.attrib["sura"]),
            int(item.attrib["aya"]),
            int(item.attrib["index"]),
        ))
    values.sort()
    if not values or values[0][:2] != (1, 1):
        raise SystemExit(f"Invalid {section_name} boundaries.")
    return values

juz_boundaries = boundaries("juzs", "juz")
page_boundaries = boundaries("pages", "page")
juz_keys = [(s, a) for s, a, _ in juz_boundaries]
page_keys = [(s, a) for s, a, _ in page_boundaries]

def boundary_value(keys, values, surah_number, ayah_number):
    position = bisect_right(keys, (surah_number, ayah_number)) - 1
    if position < 0:
        raise SystemExit(f"No metadata boundary for {surah_number}:{ayah_number}")
    return values[position][2]

def normalize_for_search(text: str) -> str:
    # Derived search-only representation. textUthmani remains byte-for-byte
    # unchanged from the official source field.
    output = []
    for char in unicodedata.normalize("NFKC", text):
        if char == "\u0640" or unicodedata.category(char) in ("Mn", "Me"):
            continue
        if char in ("أ", "إ", "آ", "ٱ"):
            char = "ا"
        elif char == "ى":
            char = "ي"
        output.append(char)
    return "".join(output)

ayahs = []
for surah_number, ayah_number, text_uthmani in records:
    ayahs.append({
        "surahNumber": surah_number,
        "ayahNumber": ayah_number,
        "textUthmani": text_uthmani,
        "normalizedText": normalize_for_search(text_uthmani),
        "juzNumber": boundary_value(juz_keys, juz_boundaries, surah_number, ayah_number),
        "pageNumber": boundary_value(page_keys, page_boundaries, surah_number, ayah_number),
    })

payload = {"surahs": surah_meta, "ayahs": ayahs}
payload_bytes = json.dumps(payload, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
manifest = {
    "source": "Tanzil Project",
    "sourceUrl": source_manifest["source_url"],
    "edition": "Uthmani",
    "version": "1.1",
    "sha256": sha256(payload_bytes).hexdigest(),
    "sourceSha256": sha256(raw_bytes).hexdigest(),
    "metadataSourceUrl": source_manifest["metadata_source_url"],
    "metadataSha256": sha256(metadata_bytes).hexdigest(),
    "retrievedAtUtc": source_manifest["retrieved_at_utc"],
    "downloadOptions": source_manifest["download_options"],
    "licenseNotice": license_notice,
}
document = {"manifest": manifest, **payload}
OUTPUT_PATH.write_text(
    json.dumps(document, ensure_ascii=False, separators=(",", ":")) + "\n",
    encoding="utf-8",
)
# Re-read and verify the exact payload serialization expected by Dart jsonEncode.
round_trip = json.loads(OUTPUT_PATH.read_text(encoding="utf-8"))
round_trip_payload = {
    "surahs": round_trip["surahs"],
    "ayahs": round_trip["ayahs"],
}
round_trip_bytes = json.dumps(
    round_trip_payload, ensure_ascii=False, separators=(",", ":")
).encode("utf-8")
if sha256(round_trip_bytes).hexdigest() != manifest["sha256"]:
    raise SystemExit("Generated import payload checksum failed its round-trip check.")
if len(round_trip["surahs"]) != 114 or len(round_trip["ayahs"]) != 6236:
    raise SystemExit("Generated import JSON has incorrect canonical counts.")
print(json.dumps({
    "output": str(OUTPUT_PATH),
    "surah_count": len(round_trip["surahs"]),
    "ayah_count": len(round_trip["ayahs"]),
    "source_sha256": manifest["sourceSha256"],
    "payload_sha256": manifest["sha256"],
    "metadata_sha256": manifest["metadataSha256"],
    "json_bytes": OUTPUT_PATH.stat().st_size,
    "license_notice_preserved": True,
}, ensure_ascii=False, indent=2))
