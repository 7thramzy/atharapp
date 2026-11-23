import 'dart:async';

import 'package:athaar/core/database/repository_providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends Notifier<ThemeMode> {
  ThemeModeController({this.initialThemeMode = ThemeMode.system});

  final ThemeMode initialThemeMode;

  @override
  ThemeMode build() => initialThemeMode;

  void setThemeMode(ThemeMode mode) {
    state = mode;
    unawaited(
      ref.read(localSettingsRepositoryProvider).setThemeMode(mode.name),
    );
  }
}
