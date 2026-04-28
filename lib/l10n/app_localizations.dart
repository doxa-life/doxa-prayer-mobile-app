import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en', 'US'),
    Locale('es'),
    Locale('es', 'ES'),
    Locale('fr'),
    Locale('fr', 'FR'),
    Locale('pt'),
    Locale('pt', 'PT'),
    Locale('ru'),
    Locale('ru', 'RU'),
  ];

  /// The name of the app
  ///
  /// In en, this message translates to:
  /// **'Doxa Prayer'**
  String get appName;

  /// The home screen
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// The pray screen
  ///
  /// In en, this message translates to:
  /// **'Pray'**
  String get pray;

  /// The people groups screen
  ///
  /// In en, this message translates to:
  /// **'People Groups'**
  String get peopleGroups;

  /// A plural message for the number of people groups
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No People Groups} =1{1 People Group} other{{count} People Groups}}'**
  String nPeopleGroups(num count);

  /// The search people groups input
  ///
  /// In en, this message translates to:
  /// **'Search People Groups'**
  String get searchPeopleGroups;

  /// The profile button
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// The reminders screen
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// The settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// The language selector
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// The retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// The message displayed when the people groups cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Could not load people groups.'**
  String get couldNotLoadPeopleGroupsMessage;

  /// The select people group button
  ///
  /// In en, this message translates to:
  /// **'Select a people group'**
  String get selectPeopleGroup;

  /// The message displayed when the user should pause and pray
  ///
  /// In en, this message translates to:
  /// **'Pause & Pray'**
  String get pauseAndPray;

  /// The select people group button
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// The disabled label shown on the currently selected people group
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// The yes confirmation button
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// The no/cancel button
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Confirmation prompt when selecting a people group for the first time
  ///
  /// In en, this message translates to:
  /// **'Do you want to select this people group?'**
  String get selectPeopleGroupConfirm;

  /// Confirmation prompt when switching from a currently selected people group to a new one
  ///
  /// In en, this message translates to:
  /// **'Do you want to stop praying for {currentName} and start praying for {newName}?'**
  String switchPeopleGroupConfirm(String currentName, String newName);

  /// The Amen button shown at the bottom of the prayer screen to log a prayer session
  ///
  /// In en, this message translates to:
  /// **'Amen'**
  String get amen;

  /// Message shown on the pray screen when the user has not yet selected a people group
  ///
  /// In en, this message translates to:
  /// **'Choose a people group to start praying.'**
  String get noPeopleGroupSelected;

  /// Error message shown when the prayer-content API call fails
  ///
  /// In en, this message translates to:
  /// **'Could not load prayer content.'**
  String get couldNotLoadPrayerContent;

  /// Message shown when the API returns hasContent=false or an empty content list
  ///
  /// In en, this message translates to:
  /// **'No prayer content for today.'**
  String get noPrayerContentAvailable;

  /// Snackbar shown after a prayer session has been recorded
  ///
  /// In en, this message translates to:
  /// **'Your prayer has been logged.'**
  String get prayerLogged;

  /// Snackbar shown when the prayer-session POST fails
  ///
  /// In en, this message translates to:
  /// **'Could not log your prayer session.'**
  String get couldNotLogPrayerSession;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'en',
    'es',
    'fr',
    'pt',
    'ru',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'US':
            return AppLocalizationsEnUs();
        }
        break;
      }
    case 'es':
      {
        switch (locale.countryCode) {
          case 'ES':
            return AppLocalizationsEsEs();
        }
        break;
      }
    case 'fr':
      {
        switch (locale.countryCode) {
          case 'FR':
            return AppLocalizationsFrFr();
        }
        break;
      }
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'PT':
            return AppLocalizationsPtPt();
        }
        break;
      }
    case 'ru':
      {
        switch (locale.countryCode) {
          case 'RU':
            return AppLocalizationsRuRu();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
