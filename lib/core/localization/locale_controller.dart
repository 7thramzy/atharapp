import 'dart:async';

import 'package:athaar/core/database/repository_providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = NotifierProvider<LocaleController, Locale>(LocaleController.new);

class LocaleController extends Notifier<Locale> {
  LocaleController({this.initialLocale = const Locale('ar')});

  final Locale initialLocale;

  @override
  Locale build() => initialLocale;

  void setLocale(Locale locale) {
    state = locale;
    unawaited(
      ref.read(localSettingsRepositoryProvider).setLocale(locale.languageCode),
    );
  }
}
