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
  String get crossCulturalWorkersPresent =>
      'Présence d\'agents de mission interculturelle';

  @override
  String get workInLocalLanguageAndCulture =>
      'Travailler dans le respect de la langue et de la culture locales';

  @override
  String get discipleAndChurchMultiplication =>
      'Formation de disciples et multiplication des Églises';

  @override
  String get resources => 'Ressources';

  @override
  String get bibleTranslation => 'Traduction de la Bible';

  @override
  String get bibleStories => 'Histoires bibliques';

  @override
  String get jesusFilm => 'Le film « Jésus »';

  @override
  String get radioBroadcast => 'Émission de radio';

  @override
  String get gospelRecordings => 'Enregistrements de gospel';

  @override
  String get audioScripture => 'Écritures en audio';

  @override
  String get overview => 'Aperçu';

  @override
  String get prayerStatus => 'État de la prière';

  @override
  String get peopleCommittedToPraying =>
      'Des personnes qui s\'engagent à prier';

  @override
  String get prayerCoverage24h => 'Veillée de prière 24 heures sur 24';

  @override
  String get peopleGroup => 'People Group';

  @override
  String get couldNotLoadPeopleGroupDetailsMessage =>
      'Could not load people group details.';

  @override
  String get share => 'Partager';

  @override
  String get search => 'Search';

  @override
  String get country => 'Pays';

  @override
  String get alternateName => 'Autre nom';

  @override
  String get population => 'Population';

  @override
  String get primaryLanguage => 'Langue maternelle';

  @override
  String get primaryReligion => 'Religion principale';

  @override
  String get religiousPractices => 'Pratiques religieuses';

  @override
  String get setReminder => 'Définir un rappel';

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
  String get status => 'Statut';

  @override
  String get engagementStatus => 'Situation matrimoniale';

  @override
  String get adoptionStatus => 'Statut d\'adoption';

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
  String get crossCulturalWorkersPresent =>
      'Travailleurs interculturels présents';

  @override
  String get workInLocalLanguageAndCulture =>
      'Travailler dans la langue et la culture locales';

  @override
  String get discipleAndChurchMultiplication =>
      'Formation de disciples et multiplication des Églises';

  @override
  String get resources => 'Ressources';

  @override
  String get bibleTranslation => 'Traduction de la Bible';

  @override
  String get bibleStories => 'Histoires bibliques';

  @override
  String get jesusFilm => 'Film Jésus';

  @override
  String get radioBroadcast => 'Émission de radio';

  @override
  String get gospelRecordings => 'Enregistrements évangéliques';

  @override
  String get audioScripture => 'Écritures audio';

  @override
  String get overview => 'Aperçu';

  @override
  String get prayerStatus => 'Statut de prière';

  @override
  String get peopleCommittedToPraying => 'Personnes engagées dans la prière';

  @override
  String get prayerCoverage24h => 'Prière 24 heures sur 24';

  @override
  String get share => 'Partager';

  @override
  String get country => 'Pays';

  @override
  String get alternateName => 'Autre nom';

  @override
  String get population => 'Population';

  @override
  String get primaryLanguage => 'Langue principale';

  @override
  String get primaryReligion => 'Religion primaire';

  @override
  String get religiousPractices => 'Pratiques religieuses';

  @override
  String get setReminder => 'Définir un rappel';

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
  String get status => 'Statut';

  @override
  String get engagementStatus => 'Statut de l\'engagement';

  @override
  String get adoptionStatus => 'Statut d\'adoption';

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
  String get noRemindersYet => 'Pas encore de rappels';

  @override
  String get reminderNotificationTitle => 'C\'est l\'heure de prier';

  @override
  String get reminderNotificationBody =>
      'Ouvrez la Doxa pour commencer la prière d\'aujourd\'hui.';

  @override
  String get reminderPermissionDenied =>
      'Les notifications sont désactivées. Activez-les dans les paramètres système pour recevoir des rappels.';

  @override
  String get nextReminder => 'Prochain rappel';

  @override
  String nextReminderToday(String time) {
    return 'Aujourd\'hui sur $time';
  }

  @override
  String nextReminderTomorrow(String time) {
    return 'Demain sur $time';
  }

  @override
  String nextReminderOn(String weekday, String time) {
    return '$weekday sur $time';
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
      other: 'Rappels définis $countString',
      one: '1 rappel défini',
      zero: 'Aucun rappel défini',
    );
    return '$_temp0';
  }

  @override
  String get dismissNextReminder => 'Fermer la fenêtre suivante';
}
