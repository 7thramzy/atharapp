import 'package:athaar/core/database/app_database.dart';

class LocalSettingsRepository {
  const LocalSettingsRepository(this._database);

  final AppDatabase _database;

  Future<LocalSetting?> load() => _database.getLocalSettings();

  Future<void> setLocale(String locale) {
    return _database.updateLocalSettings(locale: locale);
  }

  Future<void> setThemeMode(String themeMode) {
    return _database.updateLocalSettings(themeMode: themeMode);
  }
}
