// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Athaar';

  @override
  String get settings => 'Settings';

  @override
  String get back => 'Back';

  @override
  String get homeGreeting => 'Welcome to Athaar';

  @override
  String get homeSubtitle =>
      'A calm space for reading, learning, and doing good.';

  @override
  String get heroTitle => 'Begin with one small step';

  @override
  String get heroDescription =>
      'Make room for reading and learning in your day, and let that effort grow into lasting impact.';

  @override
  String get exploreSettings => 'Personalize your experience';

  @override
  String get yourPath => 'Your path in Athaar';

  @override
  String get quranTitle => 'The Quran';

  @override
  String get quranDescription =>
      'A focused reading space for memorization and revision.';

  @override
  String get adhkarTitle => 'Daily adhkar';

  @override
  String get adhkarDescription =>
      'Daily remembrances with reminders scheduled by you.';

  @override
  String get memorizationTitle => 'Memorization and revision';

  @override
  String get memorizationDescription =>
      'Follow your own progress without ranking or comparison.';

  @override
  String get inPreparation => 'In preparation';

  @override
  String get privacyNote =>
      'The first version works locally. Your settings and progress stay on this device; account and server connections are not enabled in this stage.';

  @override
  String get language => 'App language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get localPrivacy =>
      'Athaar does not require an account for its core experience. Local storage comes first; cloud synchronization will be considered after offline behavior is complete and tested.';
}
