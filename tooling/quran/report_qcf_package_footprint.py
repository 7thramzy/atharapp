#!/usr/bin/env python3
"""Report the pinned qcf_quran_plus font asset footprint in the Pub cache."""

from __future__ import annotations

import os
import sys
from pathlib import Path

EXPECTED_VERSION = "0.1.1"
EXPECTED_TAJWEED_FONTS = 604


def main() -> int:
    pub_cache = Path(
        os.environ.get("PUB_CACHE", Path.home() / ".pub-cache")
    ).expanduser()
    package_dir = pub_cache / "hosted" / "pub.dev" / (
        f"qcf_quran_plus-{EXPECTED_VERSION}"
    )
    font_root = package_dir / "assets" / "fonts"

    if not package_dir.is_dir():
        print(f"ERROR: expected package directory not found: {package_dir}")
        return 1

    font_files = [path for path in font_root.rglob("*") if path.is_file()]
    tajweed_files = [
        path
        for path in font_files
        if path.parent.name == "qcf_tajweed" and path.name.endswith(".ttf.gz")
    ]
    tajweed_bytes = sum(path.stat().st_size for path in tajweed_files)
    total_font_bytes = sum(path.stat().st_size for path in font_files)

    print(f"QCF package version: {EXPECTED_VERSION}")
    print(f"Font files: {len(font_files)}")
    print(
        f"Tajweed page-font files: {len(tajweed_files)} "
        f"({tajweed_bytes:,} bytes; {tajweed_bytes / (1024 * 1024):.2f} MiB)"
    )
    print(
        f"All font files: {total_font_bytes:,} bytes "
        f"({total_font_bytes / (1024 * 1024):.2f} MiB)"
    )

    if len(tajweed_files) != EXPECTED_TAJWEED_FONTS:
        print(
            "ERROR: upstream font asset count changed; "
            "review the package before accepting a new asset footprint."
        )
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
