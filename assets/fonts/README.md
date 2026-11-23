# Athaar font assets

The interface typography is designed for Cairo. The exact Cairo font files are not bundled in this foundation commit.

Before adding font binaries:
1. Acquire the font from its official upstream distribution.
2. Record the exact file name, version, SHA-256, and SIL Open Font License notice.
3. Include the full OFL text and copyright attribution in the application bundle.
4. Add the font family and files to pubspec.yaml, then test Arabic shaping, weights, text scaling, and RTL on Android and iOS.

The Quran script font is separate from the interface font. Add it only after the exact KFGQPC asset and its official digital-use notice have been recorded in docs/CONTENT_SOURCES.md.

Do not use runtime font downloads. The app must keep its core text rendering available offline.
