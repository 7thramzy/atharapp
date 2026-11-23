import 'package:athaar/core/database/database_providers.dart';
import 'package:athaar/core/database/local_settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localSettingsRepositoryProvider = Provider<LocalSettingsRepository>((
  ref,
) {
  return LocalSettingsRepository(ref.watch(appDatabaseProvider));
});
