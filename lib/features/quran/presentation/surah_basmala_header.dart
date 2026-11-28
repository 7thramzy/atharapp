import 'package:material_ui/material_ui.dart';

/// Displays the opening basmala as a separate surah heading.
///
/// Al-Fatihah keeps its basmala within its canonical ayah numbering, while
/// At-Tawbah has no opening basmala. All other surahs display this heading
/// separately from the canonical ayah text.
class SurahBasmalaHeader extends StatelessWidget {
  const SurahBasmalaHeader({super.key});

  static const text = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';

  static bool shouldDisplay(int surahNumber) =>
      surahNumber >= 1 && surahNumber <= 114 &&
      surahNumber != 1 && surahNumber != 9;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Center(
        child: Text(
          text,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                height: 2,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
