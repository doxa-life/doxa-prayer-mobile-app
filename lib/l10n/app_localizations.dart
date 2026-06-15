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

  /// The label of the cross-cultural workers present field
  ///
  /// In en, this message translates to:
  /// **'Cross-cultural workers present'**
  String get crossCulturalWorkersPresent;

  /// The label of the work in local language and culture field
  ///
  /// In en, this message translates to:
  /// **'Work in local language & culture'**
  String get workInLocalLanguageAndCulture;

  /// The label of the disciple and church multiplication field
  ///
  /// In en, this message translates to:
  /// **'Disciple & church multiplication'**
  String get discipleAndChurchMultiplication;

  /// The title of the resources section
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get resources;

  /// The label of the bible translation field
  ///
  /// In en, this message translates to:
  /// **'Bible Translation'**
  String get bibleTranslation;

  /// The label of the bible stories field
  ///
  /// In en, this message translates to:
  /// **'Bible Stories'**
  String get bibleStories;

  /// The label of the jesus film field
  ///
  /// In en, this message translates to:
  /// **'Jesus Film'**
  String get jesusFilm;

  /// The label of the radio broadcast field
  ///
  /// In en, this message translates to:
  /// **'Radio broadcast'**
  String get radioBroadcast;

  /// The label of the gospel recordings field
  ///
  /// In en, this message translates to:
  /// **'Gospel recordings'**
  String get gospelRecordings;

  /// The label of the audio scripture field
  ///
  /// In en, this message translates to:
  /// **'Audio scripture'**
  String get audioScripture;

  /// The title of the overview section
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// The title of the prayer status section
  ///
  /// In en, this message translates to:
  /// **'Prayer Status'**
  String get prayerStatus;

  /// The label of the people committed to praying field
  ///
  /// In en, this message translates to:
  /// **'People committed to praying'**
  String get peopleCommittedToPraying;

  /// The label of the prayer coverage 24h field
  ///
  /// In en, this message translates to:
  /// **'24-Hour Prayer Coverage'**
  String get prayerCoverage24h;

  /// The label of the people group field
  ///
  /// In en, this message translates to:
  /// **'People Group'**
  String get peopleGroup;

  /// The message displayed when the people group details cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Could not load people group details.'**
  String get couldNotLoadPeopleGroupDetailsMessage;

  /// The label of the share button
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// The label of the search button
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// The label of the country field
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// The label of the alternate name field
  ///
  /// In en, this message translates to:
  /// **'Alternate name'**
  String get alternateName;

  /// The label of the population field
  ///
  /// In en, this message translates to:
  /// **'Population'**
  String get population;

  /// The label of the primary language field
  ///
  /// In en, this message translates to:
  /// **'Primary language'**
  String get primaryLanguage;

  /// The label of the primary religion field
  ///
  /// In en, this message translates to:
  /// **'Primary religion'**
  String get primaryReligion;

  /// The label of the religious practices field
  ///
  /// In en, this message translates to:
  /// **'Religious practices'**
  String get religiousPractices;

  /// The set reminder button
  ///
  /// In en, this message translates to:
  /// **'Set reminder'**
  String get setReminder;

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

  /// The label of the status field
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// The label of the engagement status field
  ///
  /// In en, this message translates to:
  /// **'Engagement status'**
  String get engagementStatus;

  /// The label of the adoption status field
  ///
  /// In en, this message translates to:
  /// **'Adoption Status'**
  String get adoptionStatus;

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

  /// Title of the create-reminder bottom sheet and label of the create button on the reminders screen
  ///
  /// In en, this message translates to:
  /// **'New reminder'**
  String get newReminder;

  /// Title of the edit-reminder bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get editReminder;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Label for the time-of-day field
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// Label for the weekday selector
  ///
  /// In en, this message translates to:
  /// **'Days of week'**
  String get daysOfWeek;

  /// Days summary shown when a reminder is set for all 7 days
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get everyDay;

  /// Days summary shown when a reminder has no weekdays selected
  ///
  /// In en, this message translates to:
  /// **'No days selected'**
  String get noDaysSelected;

  /// Empty state on the reminders screen
  ///
  /// In en, this message translates to:
  /// **'No reminders yet'**
  String get noRemindersYet;

  /// Title shown on a scheduled reminder notification
  ///
  /// In en, this message translates to:
  /// **'Time to pray'**
  String get reminderNotificationTitle;

  /// Body shown on a scheduled reminder notification
  ///
  /// In en, this message translates to:
  /// **'Open Doxa to start today\'s prayer.'**
  String get reminderNotificationBody;

  /// Snackbar shown after saving a reminder when the OS notification permission is denied
  ///
  /// In en, this message translates to:
  /// **'Notifications are off — enable them in system settings to receive reminders.'**
  String get reminderPermissionDenied;

  /// Header on the home-screen card that previews the next scheduled reminder
  ///
  /// In en, this message translates to:
  /// **'Next reminder'**
  String get nextReminder;

  /// Next-reminder summary when it fires later today
  ///
  /// In en, this message translates to:
  /// **'Today at {time}'**
  String nextReminderToday(String time);

  /// Next-reminder summary when it fires tomorrow
  ///
  /// In en, this message translates to:
  /// **'Tomorrow at {time}'**
  String nextReminderTomorrow(String time);

  /// Next-reminder summary when it fires later this week
  ///
  /// In en, this message translates to:
  /// **'{weekday} at {time}'**
  String nextReminderOn(String weekday, String time);

  /// Total reminder count shown on the home-screen next-reminder card
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No reminders set} =1{1 reminder set} other{{count} reminders set}}'**
  String nRemindersSet(num count);

  /// Button on the home-screen next-reminder card that turns off the reminder rule whose next firing is shown
  ///
  /// In en, this message translates to:
  /// **'Dismiss next'**
  String get dismissNextReminder;

  /// Title of the wizard welcome step
  ///
  /// In en, this message translates to:
  /// **'Welcome to Doxa Prayer'**
  String get wizardWelcomeTitle;

  /// Body of the wizard welcome step
  ///
  /// In en, this message translates to:
  /// **'Doxa helps you pray for an unreached people group. We\'ll help you choose a group, set a reminder, and stay in the loop.'**
  String get wizardWelcomeBody;

  /// Primary button on the wizard welcome step
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get wizardGetStarted;

  /// Title of the wizard people-group selection step
  ///
  /// In en, this message translates to:
  /// **'Choose a people group'**
  String get wizardChoosePeopleGroupTitle;

  /// Title of the wizard confirm-people-group sub-step
  ///
  /// In en, this message translates to:
  /// **'Pray for {name}?'**
  String wizardConfirmPeopleGroupTitle(String name);

  /// Body of the wizard confirm-people-group sub-step
  ///
  /// In en, this message translates to:
  /// **'We\'ll show you prayer content and reminders for this group. You can change this later.'**
  String get wizardConfirmPeopleGroupBody;

  /// Title of the wizard reminder step
  ///
  /// In en, this message translates to:
  /// **'Set a prayer reminder'**
  String get wizardSetReminderTitle;

  /// Body of the wizard reminder step
  ///
  /// In en, this message translates to:
  /// **'We\'ll send you a gentle nudge at the time you choose. You can skip this and add reminders later.'**
  String get wizardSetReminderBody;

  /// Title of the wizard news-signup step
  ///
  /// In en, this message translates to:
  /// **'Stay in the loop'**
  String get wizardNewsSignupTitle;

  /// Body of the wizard news-signup step
  ///
  /// In en, this message translates to:
  /// **'Optional. Get news about your people group and updates from Doxa.'**
  String get wizardNewsSignupBody;

  /// Back button label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Continue button label (named to avoid the reserved word 'continue')
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// Save-and-advance button label used in wizard steps
  ///
  /// In en, this message translates to:
  /// **'Save & continue'**
  String get saveAndContinue;

  /// Skip button label
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Finish button label on the final wizard step
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// Label for the name input on the news signup form
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// Label for the email input on the news signup form
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Checkbox label on the news signup form for per-people-group updates
  ///
  /// In en, this message translates to:
  /// **'Receive updates about my people group'**
  String get updatesAboutMyPeopleGroup;

  /// Checkbox label on the news signup form for general Doxa updates
  ///
  /// In en, this message translates to:
  /// **'Receive updates from Doxa'**
  String get updatesFromDoxa;

  /// Settings row label and sub-screen title for the news signup form
  ///
  /// In en, this message translates to:
  /// **'Sign up for updates'**
  String get signUpForUpdates;

  /// SnackBar shown after the user submits the news signup form from settings
  ///
  /// In en, this message translates to:
  /// **'Thanks — you\'re signed up.'**
  String get newsSignupThanks;

  /// Error message shown when the news signup submission fails
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please check your connection and try again.'**
  String get newsSignupError;

  /// Title of the optional-update banner
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailableTitle;

  /// Body of the optional-update banner
  ///
  /// In en, this message translates to:
  /// **'A new version of Doxa Prayer is available.'**
  String get updateAvailableBody;

  /// Title of the forced-update modal
  ///
  /// In en, this message translates to:
  /// **'Update required'**
  String get updateRequiredTitle;

  /// Body of the forced-update modal
  ///
  /// In en, this message translates to:
  /// **'Please update to the latest version to keep using Doxa Prayer.'**
  String get updateRequiredBody;

  /// Button that starts the app update / opens the store
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateAction;

  /// Button that dismisses the optional-update banner
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get updateDismiss;

  /// Title of the home-screen section with share, donate and feedback buttons
  ///
  /// In en, this message translates to:
  /// **'Get involved'**
  String get getInvolved;

  /// Button that opens the donation page in the browser
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get donate;

  /// Button that opens the feedback page in the browser
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// Message text accompanying the shared app link for a people group
  ///
  /// In en, this message translates to:
  /// **'Pray with me for the {name} — get the Doxa Prayer app:'**
  String shareMessage(String name);

  /// Button on the people group card that shows a QR code of the share link
  ///
  /// In en, this message translates to:
  /// **'QR code'**
  String get qrCode;

  /// Caption under the QR code in the share modal
  ///
  /// In en, this message translates to:
  /// **'Scan to get the app and pray for the {name}'**
  String scanToPray(String name);

  /// App version label shown at the bottom of the settings screen
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(String version);
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
