import 'dart:async';

import 'package:athaar/app/athaar_app.dart';
import 'package:athaar/core/database/app_database.dart';
import 'package:athaar/core/database/database_providers.dart';
import 'package:athaar/core/design_system/theme_mode_controller.dart';
import 'package:athaar/core/localization/locale_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();
  await database.initializeDefaults();
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
