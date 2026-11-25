/// Hafs word-level sequence used for on-device memorization follow-along.
class QuranExpectedWord {
  const QuranExpectedWord({
    required this.surahNumber,
    required this.ayahNumber,
    required this.wordIndex,
    required this.text,
  });

  final int surahNumber;
  final int ayahNumber;

  /// One-based word index inside this ayah.
  final int wordIndex;

  /// Original canonical display text. Never normalized for rendering.
  final String text;
}

enum QuranRecitationMatchState {
  noSpeech,
  matched,
  uncertain,
  complete,
}

class QuranRecitationAlignment {
  const QuranRecitationAlignment({
    required this.state,
    required this.confirmedThroughExclusive,
    required this.heardWords,
    this.activeExpectedWord,
    this.matchedNewWords = 0,
    this.exactMatchRatio = 0,
  });

  final QuranRecitationMatchState state;

  /// Prefix length of the expected word sequence that is confirmed.
  final int confirmedThroughExclusive;

  /// The next expected word to display as active / needing confirmation.
  final QuranExpectedWord? activeExpectedWord;

  final List<String> heardWords;
  final int matchedNewWords;
  final double exactMatchRatio;

  bool get hasConfirmedProgress => confirmedThroughExclusive > 0;
}

/// Conservative text aligner for chunked, on-device Quran ASR.
///
/// The ASR transcript is not considered a source of Quran text. The UI reveals
/// the original Hafs words only when the normalized recognizer word exactly
/// matches the expected local Quran word in order. Fuzzy matches are marked
/// uncertain and never advance progress.
class QuranRecitationAligner {
  const QuranRecitationAligner({
    this.overlapWindowWords = 8,
    this.maxLookAheadWords = 8,
    this.maxUnmatchedPrefixWords = 6,
  });

  final int overlapWindowWords;
  final int maxLookAheadWords;
  final int maxUnmatchedPrefixWords;

  QuranRecitationAlignment align({
    required String transcript,
    required List<QuranExpectedWord> expectedWords,
    int previousConfirmedThrough = 0,
  }) {
    final heard = tokenize(transcript);
    if (heard.isEmpty || expectedWords.isEmpty) {
      return QuranRecitationAlignment(
        state: QuranRecitationMatchState.noSpeech,
        confirmedThroughExclusive: previousConfirmedThrough
            .clamp(0, expectedWords.length),
        heardWords: heard,
      );
    }

    final initialProgress = previousConfirmedThrough.clamp(
      0,
      expectedWords.length,
    );
    var confirmed = initialProgress;
    var searchCursor = (initialProgress - overlapWindowWords).clamp(
      0,
      expectedWords.length,
    );
    var ignoredPrefixWords = 0;
    var matchedNew = 0;
    var exactSeen = 0;
    int? uncertainExpectedIndex;
    var uncertain = false;

    for (final heardWord in heard) {
      final searchEnd = (searchCursor + maxLookAheadWords + 1).clamp(
        0,
        expectedWords.length,
      );
      var exactIndex = -1;
      var bestFuzzyIndex = -1;
      var bestSimilarity = 0.0;

      for (var expectedIndex = searchCursor;
          expectedIndex < searchEnd;
          expectedIndex++) {
        final expectedWord = normalizeWord(expectedWords[expectedIndex].text);
        if (expectedWord.isEmpty) continue;
        if (expectedWord == heardWord) {
          exactIndex = expectedIndex;
          break;
        }
        final similarity = _similarity(heardWord, expectedWord);
        if (similarity > bestSimilarity) {
          bestSimilarity = similarity;
          bestFuzzyIndex = expectedIndex;
        }
      }

      if (exactIndex >= 0) {
        exactSeen++;
        searchCursor = exactIndex + 1;
        if (exactIndex < confirmed) {
          // Sliding-window overlap: this word was already revealed.
          continue;
        }
        if (exactIndex > confirmed) {
          // One or more expected words were not heard; do not skip them.
          uncertain = true;
          uncertainExpectedIndex = confirmed;
          break;
        }
        confirmed++;
        matchedNew++;
        continue;
      }

      if (bestFuzzyIndex >= 0 && bestSimilarity >= 0.70) {
        uncertain = true;
        uncertainExpectedIndex = bestFuzzyIndex < confirmed
            ? confirmed
            : bestFuzzyIndex;
        break;
      }

      if (matchedNew == 0 && ignoredPrefixWords < maxUnmatchedPrefixWords) {
        ignoredPrefixWords++;
        continue;
      }
      uncertain = true;
      uncertainExpectedIndex = confirmed;
      break;
    }

    final ratio = heard.isEmpty ? 0.0 : exactSeen / heard.length;
    final activeIndex = uncertainExpectedIndex ??
        (confirmed < expectedWords.length ? confirmed : null);

    final state = confirmed >= expectedWords.length
        ? QuranRecitationMatchState.complete
        : uncertain
            ? QuranRecitationMatchState.uncertain
            : matchedNew > 0
                ? QuranRecitationMatchState.matched
                : QuranRecitationMatchState.noSpeech;

    return QuranRecitationAlignment(
      state: state,
      confirmedThroughExclusive: confirmed,
      activeExpectedWord: activeIndex == null
          ? null
          : expectedWords[activeIndex],
      heardWords: List.unmodifiable(heard),
      matchedNewWords: matchedNew,
      exactMatchRatio: ratio,
    );
  }

  List<String> tokenize(String transcript) {
    return transcript
        .split(RegExp(r'\s+'))
        .map(normalizeWord)
        .where((word) => word.isNotEmpty)
        .toList(growable: false);
  }

  /// Only comparison text is normalized; Quran display text remains intact.
  String normalizeWord(String value) {
    final normalized = StringBuffer();
    for (final rune in value.runes) {
      if (_isArabicMark(rune) ||
          rune == 0x0640 ||
          _isPunctuation(rune)) {
        continue;
      }
      switch (rune) {
        case 0x0622: // آ
        case 0x0623: // أ
        case 0x0625: // إ
        case 0x0671: // ٱ
          normalized.writeCharCode(0x0627); // ا
          break;
        case 0x0649: // ى
          normalized.writeCharCode(0x064A); // ي
          break;
        case 0x0629: // ة is preserved (not equated with ه)
          normalized.writeCharCode(rune);
          break;
        default:
          normalized.writeCharCode(rune);
      }
    }
    return normalized.toString();
  }

  bool _isArabicMark(int rune) =>
      (rune >= 0x064B && rune <= 0x065F) ||
      rune == 0x0670 ||
      (rune >= 0x06D6 && rune <= 0x06ED);

  bool _isPunctuation(int rune) =>
      rune == 0x060C || // Arabic comma
      rune == 0x061B ||
      rune == 0x061F ||
      rune == 0x06D4 ||
      rune == 0x002C ||
      rune == 0x002E ||
      rune == 0x003B ||
      rune == 0x003A ||
      rune == 0x0021 ||
      rune == 0x003F;

  double _similarity(String left, String right) {
    if (left.isEmpty || right.isEmpty) return 0;
    final leftRunes = left.runes.toList(growable: false);
    final rightRunes = right.runes.toList(growable: false);
    final previous = List<int>.generate(
      rightRunes.length + 1,
      (index) => index,
    );
    for (var i = 1; i <= leftRunes.length; i++) {
      var diagonal = previous[0];
      previous[0] = i;
      for (var j = 1; j <= rightRunes.length; j++) {
        final old = previous[j];
        final cost = leftRunes[i - 1] == rightRunes[j - 1] ? 0 : 1;
        previous[j] = [
          previous[j] + 1,
          previous[j - 1] + 1,
          diagonal + cost,
        ].reduce((a, b) => a < b ? a : b);
        diagonal = old;
      }
    }
    final distance = previous[rightRunes.length];
    final denominator = leftRunes.length > rightRunes.length
        ? leftRunes.length
        : rightRunes.length;
    return 1 - distance / denominator;
  }
}
