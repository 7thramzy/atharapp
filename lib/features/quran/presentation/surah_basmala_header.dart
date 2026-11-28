import 'package:material_ui/material_ui.dart';

/// Displays the opening basmala as a separate surah heading.
///
/// Al-Fatihah keeps its basmala within its canonical ayah numbering, while
/// At-Tawbah has no opening basmala. All other surahs display this heading
/// separately from the canonical ayah text.
class SurahBasmalaHeader extends StatelessWidget {
  const SurahBasmalaHeader({super.key});

  static const text = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';

  static bool shouldDisplay(int surahNumber) =>
      surahNumber >= 1 &&
      surahNumber <= 114 &&
      surahNumber != 1 &&
      surahNumber != 9;

  /// Removes a basmala prefix from the displayed first ayah only.
  ///
  /// The canonical stored ayah is never modified. Some surah-opening ayahs
  /// contain the basmala in the imported Tanzil text; when it is rendered as
  /// a separate heading, remove that exact prefix from the presentation copy
  /// to avoid showing it twice. Surah 27 and other ayahs without the prefix
  /// remain unchanged.
  static String displayAyahText({
    required int surahNumber,
    required int ayahNumber,
    required String text,
  }) {
    if (!shouldDisplay(surahNumber) || ayahNumber != 1) return text;
    if (!text.startsWith(SurahBasmalaHeader.text)) return text;
    return text.substring(SurahBasmalaHeader.text.length).trimLeft();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Center(
        child: Text(
          text,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(height: 2, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
