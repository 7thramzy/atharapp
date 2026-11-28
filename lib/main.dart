import 'dart:async';
import 'dart:convert';

import 'package:athaar/app/athaar_app.dart';
import 'package:athaar/core/database/app_database.dart';
import 'package:athaar/core/database/athaar_feature_store.dart';
import 'package:athaar/core/database/database_providers.dart';
import 'package:athaar/core/design_system/theme_mode_controller.dart';
import 'package:athaar/core/localization/locale_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();
  await database.initializeDefaults();
  await _ensureBundledQuran(database);
  await _ensureBundledAdhkar(database);
  final storedSettings = await database.getLocalSettings();

  final initialLocale = Locale(storedSettings?.locale ?? 'ar');
  final initialThemeMode = ThemeMode.values.firstWhere(
    (mode) => mode.name == storedSettings?.themeMode,
    orElse: () => ThemeMode.system,
  );

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWith((ref) {
          ref.onDispose(() => unawaited(database.close()));
          return database;
        }),
        localeProvider.overrideWith(
          () => LocaleController(initialLocale: initialLocale),
        ),
        themeModeProvider.overrideWith(
          () => ThemeModeController(initialThemeMode: initialThemeMode),
        ),
      ],
      child: const AthaarApp(),
    ),
  );
}

/// Imports the bundled, checksum-verified Quran dataset once per dataset version.
Future<void> _ensureBundledQuran(AppDatabase database) async {
  const assetPath = 'assets/content/quran/tanzil-uthmani-v1.1.json';
  final sourceJson = await rootBundle.loadString(assetPath);
  final decoded = jsonDecode(sourceJson) as Map<String, dynamic>;
  final manifest = decoded['manifest'] as Map<String, dynamic>;
  final expectedSha = manifest['sha256'] as String;
  final store = AthaarFeatureStore(database);
  final storedManifest = await store.quranManifest;
  final storedSurahCount = await store.surahCount;
  final storedAyahCount = await store.ayahCount;
  if (storedManifest?['sha256'] == expectedSha &&
      storedSurahCount == 114 &&
      storedAyahCount == 6236) {
    return;
  }
  await store.importQuranJson(sourceJson);
}


/// Seeds a small offline Quranic recitation collection from the already
/// checksum-verified local Quran dataset. Hadith-based items are not inferred.
Future<void> _ensureBundledAdhkar(AppDatabase database) async {
  const assetPath = 'assets/content/adhkar/seed-v1.json';
  final sourceJson = await rootBundle.loadString(assetPath);
  await AthaarFeatureStore(database).importBundledAdhkar(sourceJson);
}
