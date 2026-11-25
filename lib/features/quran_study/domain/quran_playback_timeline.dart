/// Deterministic mapping from a licensed chapter recording's timestamps
/// to the Hafs ayah and word currently being heard.
class QuranAudioWordTiming {
  const QuranAudioWordTiming({
    required this.wordIndex,
    required this.startMs,
    required this.endMs,
  });

  /// One-based word index within the containing ayah.
  final int wordIndex;
  final int startMs;
  final int endMs;

  bool contains(int positionMs) =>
      positionMs >= startMs && positionMs < endMs;
}

class QuranAudioVerseTiming {
  QuranAudioVerseTiming({
    required this.surahNumber,
    required this.ayahNumber,
    required this.startMs,
    required this.endMs,
    List<QuranAudioWordTiming> words = const [],
  }) : words = List.unmodifiable(words);

  final int surahNumber;
  final int ayahNumber;
  final int startMs;
  final int endMs;
  final List<QuranAudioWordTiming> words;

  bool contains(int positionMs) =>
      positionMs >= startMs && positionMs < endMs;
}

class QuranPlaybackSnapshot {
  const QuranPlaybackSnapshot({
    required this.surahNumber,
    required this.completedThroughAyah,
    this.activeAyahNumber,
    this.activeWordIndex,
  });

  final int surahNumber;

  /// All ayat up to this number have finished in the current recording.
  /// Zero means that no ayah has completed yet.
  final int completedThroughAyah;

  /// Null while playback is before the first verse, between verse segments,
  /// or after the last verse.
  final int? activeAyahNumber;

  /// Null when the current verse has no usable word timing at this position.
  final int? activeWordIndex;

  bool get hasActiveAyah => activeAyahNumber != null;
}

enum QuranVerseRevealState {
  upcoming,
  active,
  completed,
}

extension QuranVerseRevealStyle on QuranVerseRevealState {
  double get opacity => switch (this) {
        QuranVerseRevealState.upcoming => 0.26,
        QuranVerseRevealState.active => 1,
        QuranVerseRevealState.completed => 1,
      };
}

/// Resolves chapter audio position to verse / word and reveal states.
///
/// The timestamps must refer to the exact audio edition being played. Word
/// indexes are one-based within each ayah, as returned by Quran Foundation.
class QuranPlaybackTimeline {
  QuranPlaybackTimeline(Iterable<QuranAudioVerseTiming> timings)
      : verses = List.unmodifiable(
          timings.toList()
            ..sort((a, b) => a.startMs.compareTo(b.startMs)),
        ) {
    if (verses.isEmpty) {
      throw ArgumentError.value(timings, 'timings', 'must not be empty');
    }

    final firstSurah = verses.first.surahNumber;
    final seenAyat = <int>{};
    var previousStart = -1;

    for (final verse in verses) {
      if (verse.surahNumber != firstSurah) {
        throw ArgumentError('A chapter timeline cannot mix surahs.');
      }
      if (verse.surahNumber < 1 ||
          verse.surahNumber > 114 ||
          verse.ayahNumber < 1) {
        throw ArgumentError('Invalid Quran reference in audio timings.');
      }
      if (!seenAyat.add(verse.ayahNumber)) {
        throw ArgumentError('Duplicate ayah timing: ${verse.ayahNumber}.');
      }
      if (verse.startMs < 0 || verse.endMs <= verse.startMs) {
        throw ArgumentError('Invalid verse time range for ${verse.ayahNumber}.');
      }
      if (verse.startMs < previousStart) {
        throw ArgumentError('Verse timings must be ordered.');
      }
      previousStart = verse.startMs;

      final seenWords = <int>{};
      for (final word in verse.words) {
        if (word.wordIndex < 1 ||
            word.startMs < verse.startMs ||
            word.endMs > verse.endMs ||
            word.endMs <= word.startMs ||
            !seenWords.add(word.wordIndex)) {
          throw ArgumentError(
            'Invalid or duplicate word timing in ${verse.ayahNumber}.',
          );
        }
      }
    }
  }

  final List<QuranAudioVerseTiming> verses;

  int get surahNumber => verses.first.surahNumber;

  QuranPlaybackSnapshot resolve(Duration position) {
    final positionMs = position.inMilliseconds < 0 ? 0 : position.inMilliseconds;
    QuranAudioVerseTiming? active;

    // If source timestamps overlap, use the segment that starts latest.
    for (final verse in verses) {
      if (verse.startMs > positionMs) break;
      if (verse.contains(positionMs)) active = verse;
    }

    if (active != null) {
      int? activeWord;
      for (final word in active.words) {
        if (word.contains(positionMs)) {
          activeWord = word.wordIndex;
          break;
        }
      }
      return QuranPlaybackSnapshot(
        surahNumber: surahNumber,
        completedThroughAyah: _previousAyahNumber(active!.ayahNumber),
        activeAyahNumber: active.ayahNumber,
        activeWordIndex: activeWord,
      );
    }

    // In a pause between ayat, the last ayah whose end has passed is
    // completed. The next ayah remains upcoming until its own start.
    var completedThrough = 0;
    for (final verse in verses) {
      if (verse.endMs <= positionMs && verse.ayahNumber > completedThrough) {
        completedThrough = verse.ayahNumber;
      }
    }

    return QuranPlaybackSnapshot(
      surahNumber: surahNumber,
      completedThroughAyah: completedThrough,
    );
  }

  int _previousAyahNumber(int activeAyah) {
    var previous = 0;
    for (final verse in verses) {
      if (verse.ayahNumber >= activeAyah) break;
      if (verse.ayahNumber > previous) previous = verse.ayahNumber;
    }
    return previous;
  }

  QuranVerseRevealState revealState(
    int ayahNumber,
    QuranPlaybackSnapshot snapshot, {
    bool playbackCompleted = false,
  }) {
    if (playbackCompleted) return QuranVerseRevealState.completed;
    if (snapshot.activeAyahNumber == ayahNumber) {
      return QuranVerseRevealState.active;
    }
    if (ayahNumber <= snapshot.completedThroughAyah) {
      return QuranVerseRevealState.completed;
    }
    return QuranVerseRevealState.upcoming;
  }
}
