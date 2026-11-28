#!/usr/bin/env python3
"""Generate and validate Athaar launcher icons for Android, Windows, and iOS."""
from pathlib import Path
import json
import xml.etree.ElementTree as ET

import cairosvg
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
MASTER_SOURCE = ROOT / "assets/branding/athaar-master.svg"
ANDROID_FOREGROUND_SOURCE = ROOT / "assets/branding/athaar-foreground.svg"
ANDROID_RES = ROOT / "android/app/src/main/res"
WINDOWS_PNG = ROOT / "windows/runner/resources/app_icon.png"
WINDOWS_ICO = ROOT / "windows/runner/resources/app_icon.ico"
IOS_DIR = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"

ANDROID_LEGACY_SIZES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}
ANDROID_ADAPTIVE_SIZES = {
    "mipmap-mdpi": 108,
    "mipmap-hdpi": 162,
    "mipmap-xhdpi": 216,
    "mipmap-xxhdpi": 324,
    "mipmap-xxxhdpi": 432,
}
WINDOWS_ICO_SIZES = (16, 24, 32, 48, 64, 128, 256)
IOS_SPECS = [
    ("iphone", "20x20", "2x", 40),
    ("iphone", "20x20", "3x", 60),
    ("iphone", "29x29", "1x", 29),
    ("iphone", "29x29", "2x", 58),
    ("iphone", "29x29", "3x", 87),
    ("iphone", "40x40", "2x", 80),
    ("iphone", "40x40", "3x", 120),
    ("iphone", "60x60", "2x", 120),
    ("iphone", "60x60", "3x", 180),
    ("ipad", "20x20", "1x", 20),
    ("ipad", "20x20", "2x", 40),
    ("ipad", "29x29", "1x", 29),
    ("ipad", "29x29", "2x", 58),
    ("ipad", "40x40", "1x", 40),
    ("ipad", "40x40", "2x", 80),
    ("ipad", "76x76", "1x", 76),
    ("ipad", "76x76", "2x", 152),
    ("ipad", "83.5x83.5", "2x", 167),
    ("ios-marketing", "1024x1024", "1x", 1024),
]
ANDROID_XML_NS = "http://schemas.android.com/apk/res/android"


def require_square_svg(path: Path) -> None:
    if not path.is_file():
        raise SystemExit(f"Missing SVG source: {path}")
    try:
        root = ET.parse(path).getroot()
    except ET.ParseError as error:
        raise SystemExit(f"Invalid SVG source {path}: {error}") from error
    view_box = root.attrib.get("viewBox", "").replace(",", " ").split()
    if len(view_box) != 4:
        raise SystemExit(f"SVG must declare a square viewBox: {path}")
    try:
        width = float(view_box[2])
        height = float(view_box[3])
    except ValueError as error:
        raise SystemExit(f"Invalid SVG viewBox dimensions in {path}") from error
    if width <= 0 or height <= 0 or width != height:
        raise SystemExit(f"SVG viewBox must be positive and square: {path}")


def render_png(source: Path, destination: Path, size: int, require_transparency: bool = False) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    cairosvg.svg2png(
        url=str(source),
        write_to=str(destination),
        output_width=size,
        output_height=size,
    )
    with Image.open(destination) as image:
        if image.format != "PNG" or image.size != (size, size):
            raise SystemExit(
                f"Generated image has wrong format/dimensions: {destination} "
                f"(found {image.format} {image.size}, expected PNG {(size, size)})"
            )
        if require_transparency:
            if "A" not in image.getbands() or image.getchannel("A").getextrema()[0] != 0:
                raise SystemExit(f"Adaptive foreground must retain transparent padding: {destination}")


def validate_png(path: Path, size: int, require_transparency: bool = False) -> None:
    if not path.is_file():
        raise SystemExit(f"Missing generated PNG: {path}")
    with Image.open(path) as image:
        if image.format != "PNG" or image.size != (size, size):
            raise SystemExit(
                f"PNG dimensions failed validation: {path} "
                f"(found {image.format} {image.size}, expected {(size, size)})"
            )
        if require_transparency:
            if "A" not in image.getbands() or image.getchannel("A").getextrema()[0] != 0:
                raise SystemExit(f"Adaptive foreground is not transparent: {path}")


def write_adaptive_android_resources() -> None:
    adaptive_dir = ANDROID_RES / "mipmap-anydpi-v26"
    adaptive_dir.mkdir(parents=True, exist_ok=True)
    values_dir = ANDROID_RES / "values"
    values_dir.mkdir(parents=True, exist_ok=True)

    icon_xml = f"""<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="{ANDROID_XML_NS}">
    <background android:drawable="@color/athaar_icon_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
"""
    for name in ("ic_launcher.xml", "ic_launcher_round.xml"):
        (adaptive_dir / name).write_text(icon_xml, encoding="utf-8")

    colors_xml = """<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="athaar_icon_background">#073F3A</color>
</resources>
"""
    (values_dir / "athaar_icon_colors.xml").write_text(colors_xml, encoding="utf-8")


def validate_adaptive_android_resources() -> None:
    for name in ("ic_launcher.xml", "ic_launcher_round.xml"):
        path = ANDROID_RES / "mipmap-anydpi-v26" / name
        if not path.is_file():
            raise SystemExit(f"Missing adaptive icon resource: {path}")
        root = ET.parse(path).getroot()
        if not root.tag.endswith("adaptive-icon"):
            raise SystemExit(f"Invalid adaptive icon root element: {path}")
        children = {child.tag.split("}")[-1]: child for child in root}
        if "background" not in children or "foreground" not in children:
            raise SystemExit(f"Adaptive icon must define background and foreground: {path}")
        if children["background"].attrib.get(f"{{{ANDROID_XML_NS}}}drawable") != "@color/athaar_icon_background":
            raise SystemExit(f"Adaptive icon background reference is invalid: {path}")
        if children["foreground"].attrib.get(f"{{{ANDROID_XML_NS}}}drawable") != "@mipmap/ic_launcher_foreground":
            raise SystemExit(f"Adaptive icon foreground reference is invalid: {path}")

    color_path = ANDROID_RES / "values" / "athaar_icon_colors.xml"
    if not color_path.is_file():
        raise SystemExit(f"Missing adaptive icon color resource: {color_path}")
    colors = ET.parse(color_path).getroot()
    color_entries = {
        item.attrib.get("name"): (item.text or "").strip()
        for item in colors.findall("color")
    }
    if color_entries.get("athaar_icon_background") != "#073F3A":
        raise SystemExit("Adaptive icon background color resource is incorrect")


def generate_android_icons() -> None:
    for folder, size in ANDROID_LEGACY_SIZES.items():
        render_png(MASTER_SOURCE, ANDROID_RES / folder / "ic_launcher.png", size)
        validate_png(ANDROID_RES / folder / "ic_launcher.png", size)

    round_path = ANDROID_RES / "mipmap-xxxhdpi" / "ic_launcher_round.png"
    render_png(MASTER_SOURCE, round_path, 192)
    validate_png(round_path, 192)

    for folder, size in ANDROID_ADAPTIVE_SIZES.items():
        path = ANDROID_RES / folder / "ic_launcher_foreground.png"
        render_png(ANDROID_FOREGROUND_SOURCE, path, size, require_transparency=True)
        validate_png(path, size, require_transparency=True)

    write_adaptive_android_resources()
    validate_adaptive_android_resources()


def generate_windows_icon() -> None:
    render_png(MASTER_SOURCE, WINDOWS_PNG, 256)
    validate_png(WINDOWS_PNG, 256)
    WINDOWS_ICO.parent.mkdir(parents=True, exist_ok=True)
    with Image.open(WINDOWS_PNG).convert("RGBA") as icon:
        icon.save(
            WINDOWS_ICO,
            format="ICO",
            sizes=[(size, size) for size in WINDOWS_ICO_SIZES],
        )
    with Image.open(WINDOWS_ICO) as icon:
        actual_sizes = icon.ico.sizes()
        expected_sizes = {(size, size) for size in WINDOWS_ICO_SIZES}
        if not expected_sizes.issubset(actual_sizes):
            raise SystemExit(
                f"Windows ICO is missing required sizes: {expected_sizes - actual_sizes}"
            )


def generate_ios_icons() -> None:
    IOS_DIR.mkdir(parents=True, exist_ok=True)
    images = []
    for idiom, logical_size, scale, pixels in IOS_SPECS:
        filename = f"athaar-{idiom}-{pixels}.png"
        path = IOS_DIR / filename
        render_png(MASTER_SOURCE, path, pixels)
        validate_png(path, pixels)
        images.append(
            {
                "size": logical_size,
                "idiom": idiom,
                "filename": filename,
                "scale": scale,
            }
        )

    contents_path = IOS_DIR / "Contents.json"
    contents_path.write_text(
        json.dumps(
            {"images": images, "info": {"version": 1, "author": "xcode"}},
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )

    contents = json.loads(contents_path.read_text(encoding="utf-8"))
    if len(contents.get("images", [])) != len(IOS_SPECS):
        raise SystemExit("iOS AppIcon Contents.json has an unexpected image count")
    for entry in contents["images"]:
        filename = entry.get("filename")
        if not filename:
            raise SystemExit("iOS AppIcon entry is missing its filename")
        logical_width = float(entry["size"].split("x")[0])
        scale = float(entry["scale"].removesuffix("x"))
        expected_pixels = round(logical_width * scale)
        validate_png(IOS_DIR / filename, expected_pixels)


def main() -> None:
    require_square_svg(MASTER_SOURCE)
    require_square_svg(ANDROID_FOREGROUND_SOURCE)
    generate_android_icons()
    generate_windows_icon()
    generate_ios_icons()
    print(
        "Generated and validated Android legacy/adaptive, Windows, and iOS icons: "
        f"{len(ANDROID_LEGACY_SIZES) + 1} Android legacy PNGs, "
        f"{len(ANDROID_ADAPTIVE_SIZES)} adaptive foreground PNGs, "
        f"{len(IOS_SPECS)} iOS PNGs, and Windows ICO ({len(WINDOWS_ICO_SIZES)} sizes)."
    )


if __name__ == "__main__":
    main()
