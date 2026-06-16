// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Doxa Prayer';

  @override
  String get home => 'Home';

  @override
  String get pray => 'Pray';

  @override
  String get peopleGroups => 'People Groups';

  @override
  String nPeopleGroups(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString People Groups',
      one: '1 People Group',
      zero: 'No People Groups',
    );
    return '$_temp0';
  }

  @override
  String get searchPeopleGroups => 'Search People Groups';

  @override
  String get profile => 'Profile';

  @override
  String get reminders => 'Reminders';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get retry => 'Retry';

  @override
  String get couldNotLoadPeopleGroupsMessage => 'Could not load people groups.';

  @override
  String get selectPeopleGroup => 'Select a people group';

  @override
  String get crossCulturalWorkersPresent => 'Cross-cultural workers present';

  @override
  String get workInLocalLanguageAndCulture =>
      'Work in local language & culture';

  @override
  String get discipleAndChurchMultiplication =>
      'Disciple & church multiplication';

  @override
  String get resources => 'Resources';

  @override
  String get bibleTranslation => 'Bible Translation';

  @override
  String get bibleStories => 'Bible Stories';

  @override
  String get jesusFilm => 'Jesus Film';

  @override
  String get radioBroadcast => 'Radio broadcast';

  @override
  String get gospelRecordings => 'Gospel recordings';

  @override
  String get audioScripture => 'Audio scripture';

  @override
  String get overview => 'Overview';

  @override
  String get prayerStatus => 'Prayer Status';

  @override
  String get peopleCommittedToPraying => 'People committed to praying';

  @override
  String get prayerCoverage24h => '24-Hour Prayer Coverage';

  @override
  String get peopleGroup => 'People Group';

  @override
  String get couldNotLoadPeopleGroupDetailsMessage =>
      'Could not load people group details.';

  @override
  String get share => 'Share';

  @override
  String get search => 'Search';

  @override
  String get country => 'Country';

  @override
  String get alternateName => 'Alternate name';

  @override
  String get population => 'Population';

  @override
  String get primaryLanguage => 'Primary language';

  @override
  String get primaryReligion => 'Primary religion';

  @override
  String get religiousPractices => 'Religious practices';

  @override
  String get setReminder => 'Set reminder';

  @override
  String get pauseAndPray => 'Pause & Pray';

  @override
  String get select => 'Select';

  @override
  String get selected => 'Selected';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get status => 'Status';

  @override
  String get engagementStatus => 'Engagement status';

  @override
  String get adoptionStatus => 'Adoption Status';

  @override
  String get selectPeopleGroupConfirm =>
      'Do you want to select this people group?';

  @override
  String switchPeopleGroupConfirm(String currentName, String newName) {
    return 'Do you want to stop praying for $currentName and start praying for $newName?';
  }

  @override
  String get amen => 'Amen';

  @override
  String get noPeopleGroupSelected => 'Choose a people group to start praying.';

  @override
  String get couldNotLoadPrayerContent => 'Could not load prayer content.';

  @override
  String get noPrayerContentAvailable => 'No prayer content for today.';

  @override
  String get prayerLogged => 'Your prayer has been logged.';

  @override
  String get prayedToday => 'Prayed today';

  @override
  String get couldNotLogPrayerSession => 'Could not log your prayer session.';

  @override
  String get newReminder => 'New reminder';

  @override
  String get editReminder => 'Edit reminder';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get time => 'Time';

  @override
  String get daysOfWeek => 'Days of week';

  @override
  String get everyDay => 'Every day';

  @override
  String get noDaysSelected => 'No days selected';

  @override
  String get noRemindersYet => 'No reminders yet';

  @override
  String get reminderNotificationTitle => 'Time to pray';

  @override
  String get reminderNotificationBody => 'Open Doxa to start today\'s prayer.';

  @override
  String get reminderPermissionDenied =>
      'Notifications are off — enable them in system settings to receive reminders.';

  @override
  String get nextReminder => 'Next reminder';

  @override
  String nextReminderToday(String time) {
    return 'Today at $time';
  }

  @override
  String nextReminderTomorrow(String time) {
    return 'Tomorrow at $time';
  }

  @override
  String nextReminderOn(String weekday, String time) {
    return '$weekday at $time';
  }

  @override
  String nRemindersSet(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString reminders set',
      one: '1 reminder set',
      zero: 'No reminders set',
    );
    return '$_temp0';
  }

  @override
  String get dismissNextReminder => 'Dismiss next';

  @override
  String get wizardWelcomeTitle => 'Welcome to Doxa Prayer';

  @override
  String get wizardWelcomeBody =>
      'Doxa helps you pray for an unreached people group. We\'ll help you choose a group, set a reminder, and stay in the loop.';

  @override
  String get wizardGetStarted => 'Get started';

  @override
  String get wizardChoosePeopleGroupTitle => 'Choose a people group';

  @override
  String wizardConfirmPeopleGroupTitle(String name) {
    return 'Pray for $name?';
  }

  @override
  String get wizardConfirmPeopleGroupBody =>
      'We\'ll show you prayer content and reminders for this group. You can change this later.';

  @override
  String get wizardSetReminderTitle => 'Set a prayer reminder';

  @override
  String get wizardSetReminderBody =>
      'We\'ll send you a gentle nudge at the time you choose. You can skip this and add reminders later.';

  @override
  String get wizardNewsSignupTitle => 'Stay in the loop';

  @override
  String get wizardNewsSignupBody =>
      'Optional. Get news about your people group and updates from Doxa.';

  @override
  String get back => 'Back';

  @override
  String get continueLabel => 'Continue';

  @override
  String get saveAndContinue => 'Save & continue';

  @override
  String get skip => 'Skip';

  @override
  String get finish => 'Finish';

  @override
  String get nameLabel => 'Name';

  @override
  String get emailLabel => 'Email';

  @override
  String get updatesAboutMyPeopleGroup =>
      'Receive updates about my people group';

  @override
  String get updatesFromDoxa => 'Receive updates from Doxa';

  @override
  String get signUpForUpdates => 'Sign up for updates';

  @override
  String get newsSignupThanks => 'Thanks — you\'re signed up.';

  @override
  String get newsSignupError =>
      'Something went wrong. Please check your connection and try again.';

  @override
  String get updateAvailableTitle => 'Update available';

  @override
  String get updateAvailableBody =>
      'A new version of Doxa Prayer is available.';

  @override
  String get updateRequiredTitle => 'Update required';

  @override
  String get updateRequiredBody =>
      'Please update to the latest version to keep using Doxa Prayer.';

  @override
  String get updateAction => 'Update';

  @override
  String get updateDismiss => 'Not now';

  @override
  String get getInvolved => 'Get involved';

  @override
  String get donate => 'Donate';

  @override
  String get feedback => 'Feedback';

  @override
  String shareMessage(String name) {
    return 'Pray with me for the $name — get the Doxa Prayer app:';
  }

  @override
  String get qrCode => 'QR code';

  @override
  String scanToPray(String name) {
    return 'Scan to get the app and pray for the $name';
  }

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get previousDay => 'Previous day';

  @override
  String get nextDay => 'Next day';

  @override
  String get dayInTheLifeTitle => 'Day in the Life';

  @override
  String get myPeopleGroupTitle => 'My People Group';

  @override
  String peopleGroupIntroTitle(String name) {
    return 'Pray for the $name';
  }

  @override
  String get peopleGroupOfTheDay => 'People Group of the Day';
}

/// The translations for English, as used in the United States (`en_US`).
class AppLocalizationsEnUs extends AppLocalizationsEn {
  AppLocalizationsEnUs() : super('en_US');

  @override
  String get appName => 'appName';

  @override
  String get home => 'home';

  @override
  String get pray => 'pray';

  @override
  String get peopleGroups => 'peopleGroups';

  @override
  String nPeopleGroups(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return 'nPeopleGroups';
  }

  @override
  String get searchPeopleGroups => 'searchPeopleGroups';

  @override
  String get profile => 'profile';

  @override
  String get reminders => 'reminders';

  @override
  String get settings => 'settings';

  @override
  String get language => 'language';

  @override
  String get retry => 'retry';

  @override
  String get couldNotLoadPeopleGroupsMessage =>
      'couldNotLoadPeopleGroupsMessage';

  @override
  String get selectPeopleGroup => 'Select a people group';

  @override
  String get crossCulturalWorkersPresent => 'Cross-cultural workers present';

  @override
  String get workInLocalLanguageAndCulture =>
      'Work in local language & culture';

  @override
  String get discipleAndChurchMultiplication =>
      'Disciple & church multiplication';

  @override
  String get resources => 'Resources';

  @override
  String get bibleTranslation => 'Bible Translation';

  @override
  String get bibleStories => 'Bible Stories';

  @override
  String get jesusFilm => 'Jesus Film';

  @override
  String get radioBroadcast => 'Radio broadcast';

  @override
  String get gospelRecordings => 'Gospel Recordings';

  @override
  String get audioScripture => 'Audio Scripture';

  @override
  String get overview => 'Overview';

  @override
  String get prayerStatus => 'Prayer Status';

  @override
  String get peopleCommittedToPraying => 'People committed to praying';

  @override
  String get prayerCoverage24h => '24-Hour Prayer Coverage';

  @override
  String get share => 'Share';

  @override
  String get country => 'Country';

  @override
  String get alternateName => 'Alternate name';

  @override
  String get population => 'Population';

  @override
  String get primaryLanguage => 'Primary Language';

  @override
  String get primaryReligion => 'Primary Religion';

  @override
  String get religiousPractices => 'Religious Practices';

  @override
  String get setReminder => 'Set reminder';

  @override
  String get pauseAndPray => 'Pause & Pray';

  @override
  String get select => 'Select';

  @override
  String get selected => 'Selected';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get status => 'Status';

  @override
  String get engagementStatus => 'Engagement Status';

  @override
  String get adoptionStatus => 'Adoption Status';

  @override
  String get selectPeopleGroupConfirm =>
      'Do you want to select this people group?';

  @override
  String switchPeopleGroupConfirm(String currentName, String newName) {
    return 'Do you want to stop praying for $currentName and start praying for $newName?';
  }

  @override
  String get amen => 'Amen';

  @override
  String get noPeopleGroupSelected => 'Choose a people group to start praying.';

  @override
  String get couldNotLoadPrayerContent => 'Could not load prayer content.';

  @override
  String get noPrayerContentAvailable => 'No prayer content for today.';

  @override
  String get prayerLogged => 'Your prayer has been logged.';

  @override
  String get prayedToday => 'Prayed today';

  @override
  String get couldNotLogPrayerSession => 'Could not log your prayer session.';

  @override
  String get newReminder => 'New reminder';

  @override
  String get editReminder => 'Edit reminder';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get time => 'Time';

  @override
  String get daysOfWeek => 'Days of week';

  @override
  String get everyDay => 'Every day';

  @override
  String get noDaysSelected => 'No days selected';

  @override
  String get noRemindersYet => 'No reminders yet';

  @override
  String get reminderNotificationTitle => 'Time to pray';

  @override
  String get reminderNotificationBody => 'Open Doxa to start today\'s prayer.';

  @override
  String get reminderPermissionDenied =>
      'Notifications are off — enable them in system settings to receive reminders.';

  @override
  String get nextReminder => 'Next reminder';

  @override
  String nextReminderToday(String time) {
    return 'Today at $time';
  }

  @override
  String nextReminderTomorrow(String time) {
    return 'Tomorrow at $time';
  }

  @override
  String nextReminderOn(String weekday, String time) {
    return '$weekday at $time';
  }

  @override
  String nRemindersSet(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString reminders set',
      one: '1 reminder set',
      zero: 'No reminders set',
    );
    return '$_temp0';
  }

  @override
  String get dismissNextReminder => 'Dismiss next';
}
