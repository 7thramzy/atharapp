import 'package:athaar/features/quran_study/domain/quran_playback_timeline.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuranPlaybackTimeline', () {
    late QuranPlaybackTimeline timeline;

    setUp(() {
      timeline = QuranPlaybackTimeline([
        QuranAudioVerseTiming(
          surahNumber: 1,
          ayahNumber: 1,
          startMs: 100,
          endMs: 1000,
          words: const [
            QuranAudioWordTiming(wordIndex: 1, startMs: 100, endMs: 450),
            QuranAudioWordTiming(wordIndex: 2, startMs: 450, endMs: 1000),
          ],
        ),
        QuranAudioVerseTiming(
          surahNumber: 1,
          ayahNumber: 2,
          startMs: 1200,
          endMs: 2100,
          words: const [
            QuranAudioWordTiming(wordIndex: 1, startMs: 1200, endMs: 1600),
            QuranAudioWordTiming(wordIndex: 2, startMs: 1600, endMs: 2100),
          ],
        ),
      ]);
    });

    test('does not reveal any ayah before the first timestamp', () {
      final snapshot = timeline.resolve(Duration.zero);

      expect(snapshot.activeAyahNumber, isNull);
      expect(snapshot.completedThroughAyah, 0);
      expect(
        timeline.revealState(1, snapshot),
        QuranVerseRevealState.upcoming,
      );
      expect(
        timeline.revealState(2, snapshot).opacity,
        closeTo(0.26, 0.001),
      );
    });

    test('resolves active ayah and one-based word boundaries', () {
      final firstWord = timeline.resolve(
        const Duration(milliseconds: 449),
      );
      final secondWord = timeline.resolve(
        const Duration(milliseconds: 450),
      );

      expect(firstWord.activeAyahNumber, 1);
      expect(firstWord.activeWordIndex, 1);
      expect(secondWord.activeAyahNumber, 1);
      expect(secondWord.activeWordIndex, 2);
      expect(
        timeline.revealState(1, secondWord),
        QuranVerseRevealState.active,
      );
    });

    test('returns to normal opacity after an ayah ends in a pause', () {
      final snapshot = timeline.resolve(
        const Duration(milliseconds: 1100),
      );

      expect(snapshot.activeAyahNumber, isNull);
      expect(snapshot.completedThroughAyah, 1);
      expect(
        timeline.revealState(1, snapshot),
        QuranVerseRevealState.completed,
      );
      expect(
        timeline.revealState(2, snapshot),
        QuranVerseRevealState.upcoming,
      );
    });

    test('marks previous, current, and future ayat distinctly', () {
      final snapshot = timeline.resolve(
        const Duration(milliseconds: 1700),
      );

      expect(
        timeline.revealState(1, snapshot),
        QuranVerseRevealState.completed,
      );
      expect(
        timeline.revealState(2, snapshot),
        QuranVerseRevealState.active,
      );
      expect(
        timeline.revealState(3, snapshot),
        QuranVerseRevealState.upcoming,
      );
    });

    test('supports ayah-only highlight when word times are unavailable', () {
      final noWordTiming = QuranPlaybackTimeline([
        QuranAudioVerseTiming(
          surahNumber: 2,
          ayahNumber: 255,
          startMs: 0,
          endMs: 5000,
        ),
      ]);

      final snapshot = noWordTiming.resolve(
        const Duration(milliseconds: 900),
      );

      expect(snapshot.activeAyahNumber, 255);
      expect(snapshot.activeWordIndex, isNull);
      expect(
        noWordTiming.revealState(255, snapshot),
        QuranVerseRevealState.active,
      );
    });

    test('marks all ayat complete when playback ends', () {
      final snapshot = timeline.resolve(
        const Duration(milliseconds: 800),
      );

      expect(
        timeline.revealState(2, snapshot, playbackCompleted: true),
        QuranVerseRevealState.completed,
      );
    });

    test('rejects duplicate ayah timing records', () {
      expect(
        () => QuranPlaybackTimeline([
          QuranAudioVerseTiming(
            surahNumber: 1,
            ayahNumber: 1,
            startMs: 0,
            endMs: 100,
          ),
          QuranAudioVerseTiming(
            surahNumber: 1,
            ayahNumber: 1,
            startMs: 100,
            endMs: 200,
          ),
        ]),
        throwsArgumentError,
      );
    });

    test('rejects word timings outside their ayah range', () {
      expect(
        () => QuranPlaybackTimeline([
          QuranAudioVerseTiming(
            surahNumber: 1,
            ayahNumber: 1,
            startMs: 100,
            endMs: 200,
            words: const [
              QuranAudioWordTiming(
                wordIndex: 1,
                startMs: 80,
                endMs: 150,
              ),
            ],
          ),
        ]),
        throwsArgumentError,
      );
    });

    test('resolves overlapping verse timings to the latest starting verse', () {
      final overlapping = QuranPlaybackTimeline([
        QuranAudioVerseTiming(
          surahNumber: 1,
          ayahNumber: 1,
          startMs: 0,
          endMs: 1500,
        ),
        QuranAudioVerseTiming(
          surahNumber: 1,
          ayahNumber: 2,
          startMs: 1000,
          endMs: 2000,
        ),
      ]);

      final snapshot = overlapping.resolve(
        const Duration(milliseconds: 1200),
      );

      expect(snapshot.activeAyahNumber, 2);
      expect(snapshot.completedThroughAyah, 1);
    });
  });
}
