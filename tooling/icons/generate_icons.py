#!/usr/bin/env python3
"""Generate consistent Athaar platform icons from the checked-in SVG master."""
from pathlib import Path
import json
import cairosvg
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/branding/athaar-master.svg"
if not SOURCE.is_file():
    raise SystemExit(f"Missing icon master: {SOURCE}")

def render_png(path: Path, size: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    cairosvg.svg2png(url=str(SOURCE), write_to=str(path), output_width=size, output_height=size)

# Android launcher icons (legacy square launcher resource; adaptive-safe composition).
android_sizes = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}
for folder, size in android_sizes.items():
    render_png(ROOT / "android/app/src/main/res" / folder / "ic_launcher.png", size)
render_png(ROOT / "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.png", 192)

# Windows executable icon.
windows_png = ROOT / "windows/runner/resources/app_icon.png"
render_png(windows_png, 256)
with Image.open(windows_png).convert("RGBA") as icon:
    icon.save(ROOT / "windows/runner/resources/app_icon.ico", format="ICO",
              sizes=[(16,16),(24,24),(32,32),(48,48),(64,64),(128,128),(256,256)])

# iOS App Store icon catalog.
ios_dir = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
ios_dir.mkdir(parents=True, exist_ok=True)
images = []
specs = [
    ("iphone","20x20","2x",40), ("iphone","20x20","3x",60),
    ("iphone","29x29","1x",29), ("iphone","29x29","2x",58), ("iphone","29x29","3x",87),
    ("iphone","40x40","2x",80), ("iphone","40x40","3x",120),
    ("iphone","60x60","2x",120), ("iphone","60x60","3x",180),
    ("ipad","20x20","1x",20), ("ipad","20x20","2x",40),
    ("ipad","29x29","1x",29), ("ipad","29x29","2x",58),
    ("ipad","40x40","1x",40), ("ipad","40x40","2x",80),
    ("ipad","76x76","1x",76), ("ipad","76x76","2x",152),
    ("ipad","83.5x83.5","2x",167), ("ios-marketing","1024x1024","1x",1024),
]
for idiom, logical, scale, pixels in specs:
    filename = f"athaar-{idiom}-{pixels}.png"
    render_png(ios_dir / filename, pixels)
    images.append({"size": logical, "idiom": idiom, "filename": filename, "scale": scale})
(ios_dir / "Contents.json").write_text(
    json.dumps({"images": images, "info": {"version": 1, "author": "xcode"}}, indent=2) + "\n",
    encoding="utf-8",
)
print(f"Generated {len(android_sizes)+2} Android, {len(specs)} iOS, and Windows icons.")
