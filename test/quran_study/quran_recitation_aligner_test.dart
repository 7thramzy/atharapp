import 'package:athaar/features/quran_study/domain/quran_recitation_aligner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuranRecitationAligner', () {
    const aligner = QuranRecitationAligner();

    final expected = [
      const QuranExpectedWord(
        surahNumber: 1,
        ayahNumber: 1,
        wordIndex: 1,
        text: 'بِسْمِ',
      ),
      const QuranExpectedWord(
        surahNumber: 1,
        ayahNumber: 1,
        wordIndex: 2,
        text: 'اللَّهِ',
      ),
      const QuranExpectedWord(
        surahNumber: 1,
        ayahNumber: 1,
        wordIndex: 3,
        text: 'الرَّحْمَٰنِ',
      ),
      const QuranExpectedWord(
        surahNumber: 1,
        ayahNumber: 1,
        wordIndex: 4,
        text: 'الرَّحِيمِ',
      ),
      const QuranExpectedWord(
        surahNumber: 1,
        ayahNumber: 2,
        wordIndex: 1,
        text: 'الْحَمْدُ',
      ),
      const QuranExpectedWord(
        surahNumber: 1,
        ayahNumber: 2,
        wordIndex: 2,
        text: 'لِلَّهِ',
      ),
    ];

    test('reveals only exact expected Hafs words after Arabic mark removal', () {
      final result = aligner.align(
        transcript: 'بسم الله الرحمن الرحيم',
        expectedWords: expected,
      );

      expect(result.state, QuranRecitationMatchState.matched);
      expect(result.confirmedThroughExclusive, 4);
      expect(result.matchedNewWords, 4);
      expect(result.activeExpectedWord?.ayahNumber, 2);
      expect(result.activeExpectedWord?.wordIndex, 1);
    });

    test('recognizes equivalent alif spellings in comparison only', () {
      final result = aligner.align(
        transcript: 'بسم الله الرحمٰن الرحيم',
        expectedWords: expected,
      );

      expect(result.confirmedThroughExclusive, 4);
      expect(expected[2].text, 'الرَّحْمَٰنِ');
    });

    test('does not jump over a missed word', () {
      final result = aligner.align(
        transcript: 'بسم الله الرحيم',
        expectedWords: expected,
      );

      expect(result.confirmedThroughExclusive, 2);
      expect(result.state, QuranRecitationMatchState.uncertain);
      expect(result.activeExpectedWord?.wordIndex, 3);
    });

    test('retains previous progress when a sliding window overlaps', () {
      final result = aligner.align(
        transcript: 'الله الرحمن الرحيم الحمد',
        expectedWords: expected,
        previousConfirmedThrough: 3,
      );

      expect(result.confirmedThroughExclusive, 5);
      expect(result.matchedNewWords, 2);
      expect(result.activeExpectedWord?.ayahNumber, 2);
      expect(result.activeExpectedWord?.wordIndex, 2);
    });

    test('does not treat a fuzzy word as confirmed', () {
      final result = aligner.align(
        transcript: 'بسم الله الرحمن الرحمان',
        expectedWords: expected,
      );

      expect(result.confirmedThroughExclusive, 3);
      expect(result.state, QuranRecitationMatchState.uncertain);
      expect(result.activeExpectedWord?.wordIndex, 4);
    });

    test('ignores tashkeel but keeps taa marbuta distinct', () {
      expect(aligner.normalizeWord('رَحْمَةٌ'), 'رحمة');
      expect(aligner.normalizeWord('رَحْمَهُ'), 'رحمه');
    });

    test('does not change the Quran text object used for rendering', () {
      final original = expected.first.text;
      aligner.normalizeWord(original);
      expect(expected.first.text, original);
    });

    test('reports no speech without changing confirmed progress', () {
      final result = aligner.align(
        transcript: '   ',
        expectedWords: expected,
        previousConfirmedThrough: 2,
      );

      expect(result.state, QuranRecitationMatchState.noSpeech);
      expect(result.confirmedThroughExclusive, 2);
    });

    test('does not confirm content outside the selected expected range', () {
      final result = aligner.align(
        transcript: 'قل هو الله احد',
        expectedWords: expected,
      );

      expect(result.confirmedThroughExclusive, 0);
      expect(result.state, QuranRecitationMatchState.uncertain);
    });
  });
}
