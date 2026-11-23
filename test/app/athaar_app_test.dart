import 'dart:io';

import 'package:athaar/app/athaar_app.dart';
import 'package:athaar/core/database/app_database.dart';
import 'package:athaar/core/database/database_providers.dart';
import 'package:athaar/core/design_system/theme_mode_controller.dart';
import 'package:athaar/core/localization/locale_controller.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('starts in Arabic and allows switching language and theme', (tester) async {
    final temporaryDirectory = await Directory.systemTemp.createTemp('athaar_widget_test_');
    final database = AppDatabase.forTesting(
      NativeDatabase(File('${temporaryDirectory.path}/athaar_widget_test.sqlite')),
    );
    await database.initializeDefaults();

    addTearDown(() async {
      await database.close();
      await temporaryDirectory.delete(recursive: true);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          localeProvider.overrideWith(
            () => LocaleController(initialLocale: const Locale('ar')),
          ),
          themeModeProvider.overrideWith(
            () => ThemeModeController(initialThemeMode: ThemeMode.system),
          ),
        ],
        child: const AthaarApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('مرحباً بك في أثَر'), findsOneWidget);

    await tester.tap(find.byTooltip('الإعدادات'));
    await tester.pumpAndSettle();

    expect(find.text('المظهر'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Athaar'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(find.text('Appearance'), findsOneWidget);
  });
}
