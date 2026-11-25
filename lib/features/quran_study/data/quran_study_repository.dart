import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final quranStudyRepositoryProvider = Provider<QuranStudyRepository>((ref) {
  final repository = QuranStudyRepository();
  ref.onDispose(repository.close);
  return repository;
});

class QuranStudyRepository {
  QuranStudyRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _quranEncHost = 'quranenc.com';
  static const _audioHost = 'api.alquran.cloud';
  static const _tafsirVersion = 'v1.2.3';
  static const _tafsirEdition = 'ar-tafsir-al-jami-al-wajiz';

  void close() => _client.close();

  Future<List<QuranTranslationEdition>> getTranslations({
    String? language,
    String localization = 'ar',
  }) async {
    final path = language == null
        ? '/api/v1/translations/list/'
        : '/api/v1/translations/list/$language/';
    final response = await _client.get(
      Uri.https(_quranEncHost, path, {'localization': localization}),
      headers: const {'Accept': 'application/json'},
    );
    final decoded = _decodeMap(response, 'translation catalogue');
    final rows = decoded['translations'];
    if (rows is! List) {
      throw const FormatException('QuranEnc returned an invalid translation catalogue.');
    }
    return rows
        .whereType<Map<dynamic, dynamic>>()
        .map((row) => QuranTranslationEdition.fromJson(
              Map<String, dynamic>.from(row),
            ))
        .where((edition) => edition.key.isNotEmpty)
        .toList(growable: false);
  }

  Future<QuranTranslationText> getTranslation({
    required String key,
    required int surah,
    required int ayah,
  }) async {
    _validateAyah(surah, ayah);
    if (key.trim().isEmpty) {
      throw ArgumentError.value(key, 'key');
    }
    final response = await _client.get(
      Uri.https(
        _quranEncHost,
        '/api/v1/translation/aya/$key/$surah/$ayah',
      ),
      headers: const {'Accept': 'application/json'},
    );
    final decoded = _decodeMap(response, 'translation');
    final result = decoded['result'];
    if (result is! Map) {
      throw const FormatException('QuranEnc returned an invalid ayah translation.');
    }
    return QuranTranslationText.fromJson(
      Map<String, dynamic>.from(result),
    );
  }

  Future<QuranTafsirText> getTafsir({
    required int surah,
    required int ayah,
  }) async {
    _validateAyah(surah, ayah);
    final response = await _client.get(
      Uri.https(
        'cdn.jsdelivr.net',
        '/gh/spa5k/tafsir_api@$_tafsirVersion/tafsir/$_tafsirEdition/$surah/$ayah.json',
      ),
      headers: const {'Accept': 'application/json'},
    );
    final decoded = _decodeMap(response, 'tafsir');
    final tafsir = QuranTafsirText.fromJson(decoded);
    if (tafsir.text.isEmpty) {
      throw const FormatException('The selected edition returned empty tafsir text.');
    }
    if (tafsir.surahNumber != surah || tafsir.ayahNumber != ayah) {
      throw const FormatException('The tafsir source returned a mismatched ayah reference.');
    }
    return tafsir;
  }

  Future<List<QuranAudioEdition>> getAudioEditions() async {
    final response = await _client.get(
      Uri.https(_audioHost, '/v1/edition', {
        'format': 'audio',
        'language': 'ar',
        'type': 'versebyverse',
      }),
      headers: const {'Accept': 'application/json'},
    );
    final decoded = _decodeMap(response, 'recitation catalogue');
    final rows = decoded['data'];
    if (rows is! List) {
      throw const FormatException('AlQuran Cloud returned an invalid recitation catalogue.');
    }
    return rows
        .whereType<Map<dynamic, dynamic>>()
        .map((row) => QuranAudioEdition.fromJson(
              Map<String, dynamic>.from(row),
            ))
        .where((edition) => edition.identifier.isNotEmpty)
        .toList(growable: false);
  }

  Future<Uri> getAyahAudioUri({
    required int surah,
    required int ayah,
    required String edition,
  }) async {
    _validateAyah(surah, ayah);
    if (edition.trim().isEmpty) {
      throw ArgumentError.value(edition, 'edition');
    }
    final reference = '$surah:$ayah';
    final response = await _client.get(
      Uri.https(_audioHost, '/v1/ayah/$reference/$edition'),
      headers: const {'Accept': 'application/json'},
    );
    final decoded = _decodeMap(response, 'recitation audio');
    final data = decoded['data'];
    if (data is! Map) {
      throw const FormatException('AlQuran Cloud returned an invalid audio response.');
    }
    final audio = data['audio'] ?? data['url'];
    if (audio is! String || audio.isEmpty) {
      throw const FormatException('No audio is available for this ayah and reciter.');
    }
    final uri = Uri.tryParse(audio);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      throw const FormatException('The recitation source returned an unsafe audio URL.');
    }
    return uri;
  }

  Map<String, dynamic> _decodeMap(http.Response response, String label) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw QuranStudyException(
        '$label request failed (HTTP ${response.statusCode}).',
      );
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map) {
      throw FormatException('Invalid $label response.');
    }
    return Map<String, dynamic>.from(decoded);
  }

  static void _validateAyah(int surah, int ayah) {
    if (surah < 1 || surah > 114 || ayah < 1 || ayah > 286) {
      throw RangeError('Invalid Quran reference $surah:$ayah.');
    }
  }
}

class QuranTranslationEdition {
  const QuranTranslationEdition({
    required this.key,
    required this.title,
    required this.languageCode,
    required this.version,
    required this.description,
    required this.direction,
    this.lastUpdated,
  });

  final String key;
  final String title;
  final String languageCode;
  final String version;
  final String description;
  final String direction;
  final int? lastUpdated;

  factory QuranTranslationEdition.fromJson(Map<String, dynamic> json) {
    return QuranTranslationEdition(
      key: _asString(json['key']),
      title: _asString(json['title']),
      languageCode: _asString(json['language_iso_code']),
      version: _asString(json['version']),
      description: _asString(json['description']),
      direction: _asString(json['direction']).isEmpty
          ? 'ltr'
          : _asString(json['direction']),
      lastUpdated: _asInt(json['last_update']),
    );
  }
}

class QuranTranslationText {
  const QuranTranslationText({
    required this.text,
    required this.footnotes,
    required this.surahNumber,
    required this.ayahNumber,
  });

  final String text;
  final String footnotes;
  final int? surahNumber;
  final int? ayahNumber;

  factory QuranTranslationText.fromJson(Map<String, dynamic> json) {
    return QuranTranslationText(
      text: _asString(json['translation']),
      footnotes: _asString(json['footnotes']),
      surahNumber: _asInt(json['sura']),
      ayahNumber: _asInt(json['aya']),
    );
  }
}

class QuranTafsirText {
  const QuranTafsirText({
    required this.text,
    required this.surahNumber,
    required this.ayahNumber,
  });

  final String text;
  final int? surahNumber;
  final int? ayahNumber;

  factory QuranTafsirText.fromJson(Map<String, dynamic> json) {
    return QuranTafsirText(
      text: _asString(json['text']),
      surahNumber: _asInt(json['surah']),
      ayahNumber: _asInt(json['ayah']),
    );
  }
}

class QuranAudioEdition {
  const QuranAudioEdition({
    required this.identifier,
    required this.name,
    required this.englishName,
  });

  final String identifier;
  final String name;
  final String englishName;

  factory QuranAudioEdition.fromJson(Map<String, dynamic> json) {
    return QuranAudioEdition(
      identifier: _asString(json['identifier']),
      name: _asString(json['name']),
      englishName: _asString(json['englishName']),
    );
  }

  String get displayName => name.isNotEmpty ? name : englishName;
}

class QuranStudyException implements Exception {
  const QuranStudyException(this.message);

  final String message;

  @override
  String toString() => message;
}

String _asString(Object? value) => value == null ? '' : value.toString();

int? _asInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}
