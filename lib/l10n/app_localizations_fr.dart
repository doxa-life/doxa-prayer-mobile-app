// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Doxa Prayer';

  @override
  String get home => 'Accueil';

  @override
  String get pray => 'Prier';

  @override
  String get peopleGroups => 'Peuples';

  @override
  String nPeopleGroups(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString peuples',
      one: '1 peuple',
      zero: 'Aucun peuple',
    );
    return '$_temp0';
  }

  @override
  String get searchPeopleGroups => 'Rechercher des peuples';

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
      'Impossible de charger les peuples.';

  @override
  String get selectPeopleGroup => 'Sélectionnez un peuple';

  @override
  String get crossCulturalWorkersPresent => 'Ouvriers transculturels présents';

  @override
  String get workInLocalLanguageAndCulture =>
      'Travail dans la langue et la culture locales';

  @override
  String get discipleAndChurchMultiplication =>
      'Multiplication des disciples et des églises';

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
  String get prayerCoverage24h => 'Couverture de prière 24h/24';

  @override
  String get peopleGroup => 'Peuple';

  @override
  String get couldNotLoadPeopleGroupDetailsMessage =>
      'Impossible de charger les informations relatives au peuple.';

  @override
  String get share => 'Partager';

  @override
  String get search => 'Rechercher';

  @override
  String get country => 'Pays';

  @override
  String get alternateName => 'Autre nom';

  @override
  String get population => 'Population';

  @override
  String get primaryLanguage => 'Langue principale';

  @override
  String get primaryReligion => 'Religion principale';

  @override
  String get religiousPractices => 'Pratiques religieuses';

  @override
  String get setReminder => 'Définir un rappel';

  @override
  String get pauseAndPray => 'Faire une pause et prier';

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
      'Souhaitez-vous sélectionner ce peuple ?';

  @override
  String switchPeopleGroupConfirm(String currentName, String newName) {
    return 'Voulez-vous cesser de prier pour « $currentName » et commencer à prier pour « $newName » ?';
  }

  @override
  String get amen => 'Amen';

  @override
  String get noPeopleGroupSelected =>
      'Choisissez un peuple pour commencer à prier.';

  @override
  String get couldNotLoadPrayerContent =>
      'Impossible de charger le contenu de la prière.';

  @override
  String get noPrayerContentAvailable =>
      'Il n\'y a pas de texte de prière pour aujourd\'hui.';

  @override
  String get prayerThankYouTitle => 'Merci de vos prières';

  @override
  String get prayerThankYouMessage =>
      'Votre assiduité dans la prière compte. Dieu vous écoute, et vos prières font la différence.';

  @override
  String get prayerThankYouVerse =>
      'Réjouissez-vous toujours, priez sans cesse, rendez grâce en toutes circonstances ; car telle est la volonté de Dieu à votre égard en Jésus-Christ.';

  @override
  String get prayerThankYouVerseReference => '1 Thessaloniciens 5, 16-18';

  @override
  String get prayedToday => 'J\'ai prié aujourd\'hui';

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
      'Ouvrez Doxa pour commencer la prière d\'aujourd\'hui.';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsEnabledStatus =>
      'Les notifications sont activées. Vous recevrez vos rappels de prière.';

  @override
  String get notificationsDisabledStatus =>
      'Les notifications sont désactivées ; vos rappels de prière n\'apparaîtront donc pas.';

  @override
  String get notificationsHowToEnable =>
      'Appuyez ci-dessous pour ouvrir les paramètres, puis autorisez les notifications pour Doxa.';

  @override
  String get enableNotifications => 'Activer les notifications';

  @override
  String get openSettings => 'Ouvrir les paramètres';

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
      other: '${countString}s rappels définis',
      one: '1 rappel défini',
      zero: 'Aucun rappel défini',
    );
    return '$_temp0';
  }

  @override
  String get dismissNextReminder => 'Ignorer le prochain';

  @override
  String get wizardWelcomeTitle => 'Bienvenue sur Doxa Prayer';

  @override
  String get wizardWelcomeBody =>
      'Doxa vous aide à prier pour un peuple non atteint. Nous vous aiderons à choisir un peuple, à programmer un rappel et à rester informé.';

  @override
  String get wizardGetStarted => 'Commencer';

  @override
  String get wizardChoosePeopleGroupTitle => 'Choisissez un peuple';

  @override
  String wizardConfirmPeopleGroupTitle(String name) {
    return 'Prier pour « $name » ?';
  }

  @override
  String get wizardConfirmPeopleGroupBody =>
      'Nous vous proposerons des sujets de prière et des rappels pour ce peuple. Vous pourrez modifier ces paramètres ultérieurement.';

  @override
  String get wizardSetReminderTitle => 'Définir un rappel de prière';

  @override
  String get wizardSetReminderBody =>
      'Nous vous enverrons un petit rappel à l\'heure que vous aurez choisie. Vous pouvez ignorer cette étape et ajouter des rappels plus tard.';

  @override
  String get wizardNewsSignupTitle => 'Restez informé';

  @override
  String get wizardNewsSignupBody =>
      'Facultatif. Recevez des actualités concernant votre peuple ainsi que les dernières informations de Doxa.';

  @override
  String get back => 'Retour';

  @override
  String get continueLabel => 'Continuer';

  @override
  String get saveAndContinue => 'Enregistrer et continuer';

  @override
  String get skip => 'Passer';

  @override
  String get finish => 'Terminer';

  @override
  String get nameLabel => 'Nom';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailInvalid => 'Veuillez saisir une adresse e-mail valide.';

  @override
  String get nameRequired => 'Veuillez saisir votre nom.';

  @override
  String get updatesAboutMyPeopleGroup =>
      'Recevoir des informations sur mon peuple';

  @override
  String get updatesFromDoxa => 'Recevoir les actualités de Doxa';

  @override
  String get signUpForUpdates => 'Inscrivez-vous pour recevoir nos actualités';

  @override
  String get newsSignupSuccessTitle => 'Merci de votre inscription !';

  @override
  String newsSignupSuccessBody(String email) {
    return 'Nous avons envoyé un e-mail de vérification à $email. Ouvrez votre boîte de réception et appuyez sur le lien pour confirmer votre inscription.';
  }

  @override
  String get newsSignupError =>
      'Une erreur s\'est produite. Veuillez vérifier votre connexion et réessayer.';

  @override
  String get accountSectionTitle => 'Votre compte';

  @override
  String get emailVerified => 'Vérifié';

  @override
  String get emailUnverified => 'Non vérifié';

  @override
  String get resendVerification => 'Renvoyer l\'e-mail de vérification';

  @override
  String get resendVerificationSent =>
      'E-mail de vérification envoyé. Vérifiez votre boîte de réception.';

  @override
  String get resendVerificationCooldown =>
      'Veuillez patienter avant de demander un autre e-mail.';

  @override
  String get resendVerificationFailed =>
      'Impossible d\'envoyer l\'e-mail. Veuillez réessayer.';

  @override
  String get viewProfile => 'Voir le profil';

  @override
  String get emailsLoadError => 'Impossible de charger vos e-mails.';

  @override
  String get updateAvailableTitle => 'Mise à jour disponible';

  @override
  String get updateAvailableBody =>
      'Une nouvelle version de Doxa Prayer est disponible.';

  @override
  String get updateRequiredTitle => 'Mise à jour requise';

  @override
  String get updateRequiredBody =>
      'Veuillez effectuer la mise à jour vers la dernière version pour continuer à utiliser Doxa Prayer.';

  @override
  String get updateAction => 'Mise à jour';

  @override
  String get updateDismiss => 'Pas maintenant';

  @override
  String get getInvolved => 'Impliquez-vous';

  @override
  String get donate => 'Faire un don';

  @override
  String get feedback => 'Commentaires';

  @override
  String shareMessage(String name) {
    return 'Priez avec moi pour l’$name — téléchargez l’application Doxa Prayer :';
  }

  @override
  String get qrCode => 'Code QR';

  @override
  String scanToPray(String name) {
    return 'Scannez le code pour télécharger l\'application et priez pour l\'$name';
  }

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get previousDay => 'Jour précédent';

  @override
  String get nextDay => 'Jour suivant';

  @override
  String get dayInTheLifeTitle => 'Une journée type';

  @override
  String get myPeopleGroupTitle => 'Mon peuple';

  @override
  String peopleGroupIntroTitle(String name) {
    return 'Priez pour l’$name';
  }

  @override
  String get peopleGroupOfTheDay => 'Le peuple du jour';

  @override
  String get pressBackAgainToExit =>
      'Appuyez à nouveau sur cette touche pour quitter';

  @override
  String get notifications_enabled => 'Notifications activées';

  @override
  String get notifications_disabled => 'Notifications désactivées';
}
