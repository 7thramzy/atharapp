import 'dart:async';

import 'package:athaar/core/database/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => unawaited(database.close()));
  return database;
});

final localSettingsProvider = FutureProvider((ref) {
  return ref.watch(appDatabaseProvider).getLocalSettings();
});
