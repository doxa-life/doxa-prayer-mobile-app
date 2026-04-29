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
  String get selectReminders => 'Select reminders';

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
  String get couldNotLogPrayerSession => 'Could not log your prayer session.';
}
