import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Athaar'**
  String get appName;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Athaar'**
  String get homeGreeting;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A calm space for reading, learning, and doing good.'**
  String get homeSubtitle;

  /// No description provided for @heroTitle.
  ///
  /// In en, this message translates to:
  /// **'Begin with one small step'**
  String get heroTitle;

  /// No description provided for @heroDescription.
  ///
  /// In en, this message translates to:
  /// **'Make room for reading and learning in your day, and let that effort grow into lasting impact.'**
  String get heroDescription;

  /// No description provided for @exploreSettings.
  ///
  /// In en, this message translates to:
  /// **'Personalize your experience'**
  String get exploreSettings;

  /// No description provided for @yourPath.
  ///
  /// In en, this message translates to:
  /// **'Your path in Athaar'**
  String get yourPath;

  /// No description provided for @quranTitle.
  ///
  /// In en, this message translates to:
  /// **'The Quran'**
  String get quranTitle;

  /// No description provided for @quranDescription.
  ///
  /// In en, this message translates to:
  /// **'A focused reading space for memorization and revision.'**
  String get quranDescription;

  /// No description provided for @adhkarTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily adhkar'**
  String get adhkarTitle;

  /// No description provided for @adhkarDescription.
  ///
  /// In en, this message translates to:
  /// **'Daily remembrances with reminders scheduled by you.'**
  String get adhkarDescription;

  /// No description provided for @memorizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Memorization and revision'**
  String get memorizationTitle;

  /// No description provided for @memorizationDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow your own progress without ranking or comparison.'**
  String get memorizationDescription;

  /// No description provided for @inPreparation.
  ///
  /// In en, this message translates to:
  /// **'In preparation'**
  String get inPreparation;

  /// No description provided for @privacyNote.
  ///
  /// In en, this message translates to:
  /// **'The first version works locally. Your settings and progress stay on this device; account and server connections are not enabled in this stage.'**
  String get privacyNote;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @localPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Athaar does not require an account for its core experience. Local storage comes first; cloud synchronization will be considered after offline behavior is complete and tested.'**
  String get localPrivacy;

  /// No description provided for @audioCaptureEntry.
  ///
  /// In en, this message translates to:
  /// **'Private voice recording'**
  String get audioCaptureEntry;

  /// No description provided for @audioCaptureTitle.
  ///
  /// In en, this message translates to:
  /// **'Local voice recording'**
  String get audioCaptureTitle;

  /// No description provided for @audioPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your voice stays on this device'**
  String get audioPrivacyTitle;

  /// No description provided for @audioPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'The recording is not uploaded or kept in a permanent history. It remains temporary while this screen is open and is deleted when you leave. This feature does not stream recitations or provide automated assessment. Microphone permission is requested only after you tap Start, and is used only for this recording.'**
  String get audioPrivacyBody;

  /// No description provided for @audioPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing temporary recording space…'**
  String get audioPreparing;

  /// No description provided for @audioReadyToRecord.
  ///
  /// In en, this message translates to:
  /// **'Ready when you choose to record'**
  String get audioReadyToRecord;

  /// No description provided for @audioRequestingPermission.
  ///
  /// In en, this message translates to:
  /// **'Waiting for microphone permission…'**
  String get audioRequestingPermission;

  /// No description provided for @audioRecordingIndicator.
  ///
  /// In en, this message translates to:
  /// **'Recording is active'**
  String get audioRecordingIndicator;

  /// No description provided for @audioStopping.
  ///
  /// In en, this message translates to:
  /// **'Stopping the recording…'**
  String get audioStopping;

  /// No description provided for @audioRecordingReady.
  ///
  /// In en, this message translates to:
  /// **'Temporary recording complete. You can play it or delete it.'**
  String get audioRecordingReady;

  /// No description provided for @audioPlaying.
  ///
  /// In en, this message translates to:
  /// **'Playing the recording locally'**
  String get audioPlaying;

  /// No description provided for @audioDeleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting the recording…'**
  String get audioDeleting;

  /// No description provided for @audioStart.
  ///
  /// In en, this message translates to:
  /// **'Start recording'**
  String get audioStart;

  /// No description provided for @audioStopRecording.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get audioStopRecording;

  /// No description provided for @audioPlay.
  ///
  /// In en, this message translates to:
  /// **'Play recording'**
  String get audioPlay;

  /// No description provided for @audioStopPlayback.
  ///
  /// In en, this message translates to:
  /// **'Stop playback'**
  String get audioStopPlayback;

  /// No description provided for @audioDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete recording'**
  String get audioDelete;

  /// No description provided for @audioPreparationError.
  ///
  /// In en, this message translates to:
  /// **'Temporary recording space could not be prepared. Leave this screen and try again.'**
  String get audioPreparationError;

  /// No description provided for @audioPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission was not granted. Allow it in device settings, then try again.'**
  String get audioPermissionDenied;

  /// No description provided for @audioRecordingError.
  ///
  /// In en, this message translates to:
  /// **'Recording could not start or be saved. No audio was sent.'**
  String get audioRecordingError;

  /// No description provided for @audioPlaybackError.
  ///
  /// In en, this message translates to:
  /// **'The local recording could not be played. No audio was sent.'**
  String get audioPlaybackError;

  /// No description provided for @audioDeletionError.
  ///
  /// In en, this message translates to:
  /// **'The recording could not be deleted right now. Temporary files will be cleaned when you open this feature again.'**
  String get audioDeletionError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
