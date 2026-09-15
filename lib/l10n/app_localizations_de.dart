// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Doxa Prayer';

  @override
  String get home => 'Start';

  @override
  String get pray => 'Beten';

  @override
  String get peopleGroups => 'Volksgruppen';

  @override
  String nPeopleGroups(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Volksgruppen',
      one: '1 Volksgruppe',
      zero: 'Keine Volksgruppen',
    );
    return '$_temp0';
  }

  @override
  String get searchPeopleGroups => 'Volksgruppen suchen';

  @override
  String get profile => 'Profil';

  @override
  String get reminders => 'Erinnerungen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get couldNotLoadPeopleGroupsMessage =>
      'Die Volksgruppen konnten nicht geladen werden.';

  @override
  String get selectPeopleGroup => 'Wähle eine Volksgruppe';

  @override
  String get crossCulturalWorkersPresent =>
      'Kulturübergreifende Mitarbeiter/innen vor Ort';

  @override
  String get unselect => 'Abwählen';

  @override
  String get workInLocalLanguageAndCulture =>
      'Arbeit in lokaler Sprache & Kultur';

  @override
  String get discipleAndChurchMultiplication =>
      'Vermehrung von Jüngern und Gemeinden';

  @override
  String get resources => 'Ressourcen';

  @override
  String get bibleTranslation => 'Bibelübersetzung';

  @override
  String get bibleStories => 'Bibelgeschichten';

  @override
  String get jesusFilm => 'Jesus-Film';

  @override
  String get radioBroadcast => 'Radiosendung';

  @override
  String get gospelRecordings => 'Evangeliums-Tonaufnahmen';

  @override
  String get audioScripture => 'Audio-Bibel';

  @override
  String get overview => 'Überblick';

  @override
  String get prayerStatus => 'Gebetsstatus';

  @override
  String get peopleCommittedToPraying =>
      'Menschen, die sich zum Gebet verpflichtet haben';

  @override
  String get dailyPrayerCoverage => 'Tägliche Gebetsabdeckung';

  @override
  String get peopleGroup => 'Volksgruppe';

  @override
  String get couldNotLoadPeopleGroupDetailsMessage =>
      'Die Details zur Volksgruppe konnten nicht geladen werden.';

  @override
  String get share => 'Teilen';

  @override
  String get search => 'Suchen';

  @override
  String get country => 'Land';

  @override
  String get alternateName => 'Alternativer Name';

  @override
  String get population => 'Bevölkerung';

  @override
  String get primaryLanguage => 'Hauptsprache';

  @override
  String get primaryReligion => 'Hauptreligion';

  @override
  String get religiousPractices => 'Religiöse Praktiken';

  @override
  String get setReminder => 'Erinnerung einrichten';

  @override
  String get pauseAndPray => 'Innehalten & beten';

  @override
  String get select => 'Auswählen';

  @override
  String get selected => 'Ausgewählt';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get partial => 'Teilweise';

  @override
  String get status => 'Status';

  @override
  String get engagementStatus => 'Engagement-Status';

  @override
  String get engaged => 'Engagiert';

  @override
  String get adoptionStatus => 'Adoptionsstatus';

  @override
  String get selectPeopleGroupConfirm =>
      'Möchtest du diese Volksgruppe auswählen?';

  @override
  String switchPeopleGroupConfirm(String currentName, String newName) {
    return 'Möchtest du nicht mehr für „$currentName“ beten und stattdessen für „$newName“ beten?';
  }

  @override
  String get amen => 'Amen';

  @override
  String get noPeopleGroupSelected =>
      'Wähle eine Volksgruppe, um mit dem Beten zu beginnen.';

  @override
  String get couldNotLoadPrayerContent =>
      'Die Gebetsinhalte konnten nicht geladen werden.';

  @override
  String get noPrayerContentAvailable => 'Heute keine Gebetsinhalte.';

  @override
  String get prayerThankYouTitle => 'Danke, dass du gebetet hast';

  @override
  String get prayedToday => 'Heute gebetet';

  @override
  String get prayerReminderTitle => 'Bereit für das Gebet von heute?';

  @override
  String prayerReminderBody(String peopleGroup) {
    return 'Tippe, um für „$peopleGroup“ zu beten.';
  }

  @override
  String get dismissReminderLabel => 'Erinnerung ausblenden';

  @override
  String prayForPeopleGroupLabel(String peopleGroup) {
    return 'Für „$peopleGroup“ beten';
  }

  @override
  String get pictureCreditLabel => 'Bildnachweis';

  @override
  String get clearSearchLabel => 'Suche löschen';

  @override
  String get forwardLabel => 'Vorwärts';

  @override
  String get prayerRecordedAnnouncement => 'Gebet erfasst';

  @override
  String prayingWithYou(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Personen beten gerade mit dir',
      one: '1 Person betet gerade mit dir',
    );
    return '$_temp0';
  }

  @override
  String get newReminder => 'Neue Erinnerung';

  @override
  String get editReminder => 'Erinnerung bearbeiten';

  @override
  String get save => 'Speichern';

  @override
  String get delete => 'Löschen';

  @override
  String get time => 'Uhrzeit';

  @override
  String get daysOfWeek => 'Wochentage';

  @override
  String get everyDay => 'Täglich';

  @override
  String get noDaysSelected => 'Keine Tage ausgewählt';

  @override
  String get noRemindersYet => 'Noch keine Erinnerungen';

  @override
  String get reminderNotificationTitle => 'Zeit zu beten';

  @override
  String get reminderNotificationBody =>
      'Öffne Doxa, um das heutige Gebet zu beginnen.';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get notificationsEnabledStatus =>
      'Benachrichtigungen sind an. Deine Gebetserinnerungen werden zugestellt.';

  @override
  String get notificationsDisabledStatus =>
      'Benachrichtigungen sind ausgeschaltet, deshalb erscheinen deine Gebetserinnerungen nicht.';

  @override
  String get notificationsHowToEnable =>
      'Tippe unten, um die Einstellungen zu öffnen, und erlaube dort Benachrichtigungen für Doxa.';

  @override
  String get exactAlarmsDisabledStatus =>
      'Exakte Alarme sind für Doxa nicht erlaubt, deshalb können deine Gebetserinnerungen einige Minuten zu spät ankommen.';

  @override
  String get allowExactAlarms => 'Exakte Alarme erlauben';

  @override
  String get exactAlarmsPromptBody =>
      'Damit deine Gebetserinnerungen pünktlich ankommen, erlaube Doxa exakte Alarme.';

  @override
  String get allow => 'Erlauben';

  @override
  String get notNow => 'Jetzt nicht';

  @override
  String get enableNotifications => 'Benachrichtigungen aktivieren';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get nextReminder => 'Nächste Erinnerung';

  @override
  String nextReminderToday(String time) {
    return 'Heute um $time';
  }

  @override
  String nextReminderTomorrow(String time) {
    return 'Morgen um $time';
  }

  @override
  String nextReminderOn(String weekday, String time) {
    return '$weekday um $time';
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
      other: '$countString Erinnerungen eingerichtet',
      one: '1 Erinnerung eingerichtet',
      zero: 'Keine Erinnerungen eingerichtet',
    );
    return '$_temp0';
  }

  @override
  String get wizardWelcomeTitle => 'Willkommen bei Doxa Prayer';

  @override
  String get wizardWelcomeBody =>
      'Doxa hilft dir, für eine unerreichte Volksgruppe zu beten. Wir helfen dir, eine Gruppe zu wählen, eine Erinnerung einzurichten und auf dem Laufenden zu bleiben.';

  @override
  String get wizardGetStarted => 'Los geht\'s';

  @override
  String get wizardChoosePeopleGroupTitle => 'Eine Volksgruppe wählen';

  @override
  String wizardConfirmPeopleGroupTitle(String name) {
    return 'Für „$name“ beten?';
  }

  @override
  String get wizardConfirmPeopleGroupBody =>
      'Wir zeigen dir Gebetsinhalte und Erinnerungen für diese Gruppe. Du kannst das später ändern.';

  @override
  String get wizardSetReminderTitle => 'Gebetserinnerung einrichten';

  @override
  String get wizardSetReminderBody =>
      'Wir schicken dir zur gewählten Zeit einen sanften Anstoß. Du kannst das überspringen und Erinnerungen später hinzufügen.';

  @override
  String get wizardNewsSignupTitle => 'Bleib auf dem Laufenden';

  @override
  String get wizardNewsSignupBody =>
      'Optional. Erhalte Neuigkeiten über deine Volksgruppe und Updates von Doxa.';

  @override
  String get back => 'Zurück';

  @override
  String get continueLabel => 'Weiter';

  @override
  String get skip => 'Überspringen';

  @override
  String get finish => 'Fertig';

  @override
  String get nameLabel => 'Name';

  @override
  String get emailLabel => 'E-Mail';

  @override
  String get emailInvalid => 'Bitte gib eine gültige E-Mail-Adresse ein.';

  @override
  String get nameRequired => 'Bitte gib deinen Namen ein.';

  @override
  String get updatesAboutMyPeopleGroup =>
      'Neuigkeiten über meine Volksgruppe erhalten';

  @override
  String get updatesFromDoxa => 'Neuigkeiten von Doxa erhalten';

  @override
  String get signUpForUpdates => 'Für Neuigkeiten anmelden';

  @override
  String get newsSignupSuccessTitle => 'Danke für deine Anmeldung!';

  @override
  String newsSignupSuccessBody(String email) {
    return 'Wir haben eine Bestätigungs-E-Mail an $email geschickt. Bitte öffne dein Postfach und tippe auf den Link, um dein Abo zu bestätigen.';
  }

  @override
  String get newsSignupError =>
      'Etwas ist schiefgelaufen. Bitte prüfe deine Verbindung und versuche es erneut.';

  @override
  String get enableNotificationsPromptBody =>
      'Aktiviere Benachrichtigungen, um diese Neuigkeiten auch auf deinem Handy zu bekommen.';

  @override
  String get enableNotificationsButton => 'Benachrichtigungen aktivieren';

  @override
  String get accountSectionTitle => 'Dein Konto';

  @override
  String get emailVerified => 'Bestätigt';

  @override
  String get emailUnverified => 'Nicht bestätigt';

  @override
  String get resendVerification => 'Bestätigungs-E-Mail erneut senden';

  @override
  String get resendVerificationSent =>
      'Bestätigungs-E-Mail gesendet. Sieh in deinem Postfach nach.';

  @override
  String resendVerificationCooldown(int seconds) {
    return 'Bitte warte $seconds s, bevor du eine weitere E-Mail anforderst.';
  }

  @override
  String resendVerificationCountdown(int seconds) {
    return 'Erneut senden in $seconds s';
  }

  @override
  String get signUp => 'Anmelden';

  @override
  String get resendVerificationFailed =>
      'Die E-Mail konnte nicht gesendet werden. Bitte versuche es erneut.';

  @override
  String get viewProfile => 'Profil ansehen';

  @override
  String get emailsLoadError =>
      'Deine E-Mail-Adressen konnten nicht geladen werden.';

  @override
  String get updateAvailableTitle => 'Update verfügbar';

  @override
  String get updateAvailableBody =>
      'Eine neue Version von Doxa Prayer ist verfügbar.';

  @override
  String get updateRequiredTitle => 'Update erforderlich';

  @override
  String get updateRequiredBody =>
      'Bitte aktualisiere auf die neueste Version, um Doxa Prayer weiter zu nutzen.';

  @override
  String get updateAction => 'Aktualisieren';

  @override
  String get updateDismiss => 'Jetzt nicht';

  @override
  String get feedback => 'Feedback';

  @override
  String get feedbackIntro =>
      'Wir freuen uns, von dir zu hören. Sag uns, was du von der App hältst.';

  @override
  String get feedbackTypeLabel => 'Welche Art von Feedback?';

  @override
  String get feedbackTypeCompliment => 'Lob';

  @override
  String get feedbackTypeSuggestion => 'Vorschlag';

  @override
  String get feedbackTypeProblem => 'Problem';

  @override
  String get feedbackTypeRequired => 'Bitte wähle eine Feedback-Art.';

  @override
  String get feedbackNameLabel => 'Name (optional)';

  @override
  String get feedbackMessageLabel => 'Nachricht';

  @override
  String get feedbackMessageRequired => 'Bitte gib eine Nachricht ein.';

  @override
  String get feedbackConsentLabel =>
      'Haltet mich mit Neuigkeiten von Doxa auf dem Laufenden';

  @override
  String get feedbackSubmit => 'Feedback senden';

  @override
  String get feedbackError =>
      'Etwas ist schiefgelaufen. Bitte prüfe deine Verbindung und versuche es erneut.';

  @override
  String get feedbackRateLimited =>
      'Du hast in letzter Zeit viel Feedback gesendet. Bitte versuche es später erneut.';

  @override
  String get feedbackSuccessTitle => 'Vielen Dank!';

  @override
  String feedbackSuccessBody(String email) {
    return 'Dein Feedback wurde als $email gesendet. Falls das nicht die richtige Adresse ist, sende es noch einmal mit der richtigen.';
  }

  @override
  String shareMessage(String name) {
    return 'Bete mit mir für die $name — hol dir die App Doxa Prayer:';
  }

  @override
  String get shareLink => 'Link teilen';

  @override
  String scanToPray(String name) {
    return 'Scannen, um die App zu holen und für die „$name“ zu beten';
  }

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get previousDay => 'Vorheriger Tag';

  @override
  String get nextDay => 'Nächster Tag';

  @override
  String get dayInTheLifeTitle => 'Ein Tag im Leben';

  @override
  String get myPeopleGroupTitle => 'Meine Volksgruppe';

  @override
  String peopleGroupIntroTitle(String name) {
    return 'Bete für die „$name“';
  }

  @override
  String get peopleGroupOfTheDay => 'Volksgruppe des Tages';

  @override
  String get pressBackAgainToExit => 'Zum Beenden erneut „Zurück“ drücken';

  @override
  String get notifications_enabled => 'Benachrichtigungen aktiviert';

  @override
  String get notifications_disabled => 'Benachrichtigungen deaktiviert';

  @override
  String get cancel => 'Abbrechen';

  @override
  String addPeopleGroupConfirm(String name) {
    return 'Möchtest du anfangen, für „$name“ zu beten?';
  }

  @override
  String get choosePeopleGroup => 'Eine Volksgruppe wählen';

  @override
  String get addAnotherPeopleGroup => 'Weitere Volksgruppe hinzufügen';

  @override
  String peopleGroupLimitTitle(num count) {
    return 'Du betest für $count Volksgruppen';
  }

  @override
  String peopleGroupLimitBody(String name) {
    return 'Für mehr kannst du nicht gleichzeitig beten. Um „$name“ hinzuzufügen, wähle eine Gruppe, für die du nicht mehr betest.';
  }

  @override
  String get swapPeopleGroupAction => 'Tauschen';

  @override
  String removePeopleGroupTitle(String name) {
    return 'Nicht mehr für „$name“ beten?';
  }

  @override
  String get removePeopleGroupBody =>
      'Sie verschwindet von deinem Startbildschirm. Du kannst sie jederzeit wieder hinzufügen.';

  @override
  String removePeopleGroupReminders(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ihre $count Erinnerungen werden gelöscht.',
      one: 'Ihre Erinnerung wird gelöscht.',
    );
    return '$_temp0';
  }

  @override
  String get stopPraying => 'Nicht mehr beten';

  @override
  String get noPeopleGroupsForReminder =>
      'Wähle eine Volksgruppe, bevor du eine Erinnerung einrichtest.';

  @override
  String get reminderPeopleGroup => 'Volksgruppe';

  @override
  String reminderNotificationBodyForGroup(String name) {
    return 'Öffne Doxa, um für „$name“ zu beten.';
  }

  @override
  String nextReminderForGroup(String time, String name) {
    return '$time für „$name“';
  }

  @override
  String prayForNextGroup(String name) {
    return 'Für „$name“ beten';
  }

  @override
  String switchToPeopleGroup(String name) {
    return 'Zu „$name“ wechseln';
  }

  @override
  String get map => 'Karte';

  @override
  String mapOf(String name) {
    return 'Karte von „$name“';
  }

  @override
  String get nearbyPeopleGroups => 'Volksgruppen in der Nähe';

  @override
  String get recenter => 'Neu zentrieren';

  @override
  String get mapUnavailableOffline => 'Kartenbilder offline nicht verfügbar';

  @override
  String get yourPeopleGroups => 'Deine Volksgruppen';

  @override
  String get locationNotAvailable => 'Standort nicht verfügbar';

  @override
  String get couldNotLoadMapMessage => 'Die Karte konnte nicht geladen werden.';
}
