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
}
