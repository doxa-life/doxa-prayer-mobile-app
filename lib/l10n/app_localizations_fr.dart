// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Doxa Prière';

  @override
  String get home => 'Accueil';

  @override
  String get pray => 'Prier';

  @override
  String get peopleGroups => 'Groupes de Personnes';

  @override
  String nPeopleGroups(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Groupes de Personnes',
      one: '1 Groupe de Personnes',
      zero: 'Aucun Groupe de Personnes',
    );
    return '$_temp0';
  }

  @override
  String get searchPeopleGroups => 'Rechercher des Groupes de Personnes';

  @override
  String get profile => 'Profil';

  @override
  String get reminders => 'Rappels';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get retry => 'Réessayer';

  @override
  String get couldNotLoadPeopleGroupsMessage =>
      'Impossible de charger les groupes de personnes.';

  @override
  String get selectPeopleGroup => 'Sélectionnez un groupe ethnique';

  @override
  String get prayerStatus => 'Prayer Status';

  @override
  String get peopleCommittedToPraying => 'People committed to praying';

  @override
  String get prayerCoverage24h => '24-Hour Prayer Coverage';

  @override
  String get overview => 'Overview';

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
  String get pauseAndPray => 'Fais une pause et prie';

  @override
  String get select => 'Sélectionner';

  @override
  String get selected => 'Sélectionné';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get status => 'Status';

  @override
  String get selectPeopleGroupConfirm =>
      'Voulez-vous sélectionner ce groupe de personnes ?';

  @override
  String switchPeopleGroupConfirm(String currentName, String newName) {
    return 'Voulez-vous arrêter de prier pour $currentName et commencer à prier pour $newName ?';
  }

  @override
  String get amen => 'Amen';

  @override
  String get noPeopleGroupSelected =>
      'Choisissez un groupe de personnes pour commencer à prier.';

  @override
  String get couldNotLoadPrayerContent =>
      'Impossible de charger le contenu de prière.';

  @override
  String get noPrayerContentAvailable =>
      'Aucun contenu de prière pour aujourd\'hui.';

  @override
  String get prayerLogged => 'Votre prière a été enregistrée.';

  @override
  String get couldNotLogPrayerSession =>
      'Impossible d\'enregistrer votre session de prière.';

  @override
  String get newReminder => 'Nouveau rappel';

  @override
  String get editReminder => 'Modifier le rappel';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get time => 'Heure';

  @override
  String get daysOfWeek => 'Jours de la semaine';

  @override
  String get everyDay => 'Tous les jours';

  @override
  String get noDaysSelected => 'Aucun jour sélectionné';

  @override
  String get noRemindersYet => 'Aucun rappel pour le moment';

  @override
  String get reminderNotificationTitle => 'C\'est l\'heure de prier';

  @override
  String get reminderNotificationBody =>
      'Ouvre Doxa pour commencer la prière du jour.';

  @override
  String get reminderPermissionDenied =>
      'Les notifications sont désactivées ; active-les dans les réglages système pour recevoir les rappels.';

  @override
  String get nextReminder => 'Prochain rappel';

  @override
  String nextReminderToday(String time) {
    return 'Aujourd\'hui à $time';
  }

  @override
  String nextReminderTomorrow(String time) {
    return 'Demain à $time';
  }

  @override
  String nextReminderOn(String weekday, String time) {
    return '$weekday à $time';
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
      other: '$countString rappels actifs',
      one: '1 rappel actif',
      zero: 'Aucun rappel',
    );
    return '$_temp0';
  }

  @override
  String get dismissNextReminder => 'Ignorer le prochain';
}

/// The translations for French, as used in France (`fr_FR`).
class AppLocalizationsFrFr extends AppLocalizationsFr {
  AppLocalizationsFrFr() : super('fr_FR');

  @override
  String get appName => 'nom de l\'application';

  @override
  String get home => 'Accueil';

  @override
  String get pray => 'prier';

  @override
  String get peopleGroups => 'groupes ethniques';

  @override
  String nPeopleGroups(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Groupes de Personnes',
      one: '1 Groupe de Personnes',
      zero: 'Aucun Groupe de Personnes',
    );
    return '$_temp0';
  }

  @override
  String get searchPeopleGroups => 'Rechercher des personnes et des groupes';

  @override
  String get profile => 'profil';

  @override
  String get reminders => 'rappels';

  @override
  String get settings => 'paramètres';

  @override
  String get language => 'langue';

  @override
  String get retry => 'réessayer';

  @override
  String get couldNotLoadPeopleGroupsMessage =>
      'Impossible de charger le message « PeopleGroups »';

  @override
  String get selectPeopleGroup => 'Sélectionnez un groupe ethnique';

  @override
  String get pauseAndPray => 'Fais une pause et prie';

  @override
  String get select => 'Sélectionner';

  @override
  String get selected => 'Sélectionné';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get selectPeopleGroupConfirm =>
      'Souhaitez-vous sélectionner ce groupe ethnique ?';

  @override
  String switchPeopleGroupConfirm(String currentName, String newName) {
    return 'Voulez-vous cesser de prier pour $currentName et commencer à prier pour $newName ?';
  }

  @override
  String get amen => 'Amen';

  @override
  String get noPeopleGroupSelected =>
      'Choisissez un groupe ethnique pour commencer à prier.';

  @override
  String get couldNotLoadPrayerContent =>
      'Impossible de charger le contenu de la prière.';

  @override
  String get noPrayerContentAvailable =>
      'Il n\'y a pas de texte de prière pour aujourd\'hui.';

  @override
  String get prayerLogged => 'Votre prière a été enregistrée.';

  @override
  String get couldNotLogPrayerSession =>
      'Impossible d\'enregistrer votre session de prière.';
}
