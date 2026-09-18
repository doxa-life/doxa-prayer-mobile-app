// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appName => 'DOXA Prayer';

  @override
  String get home => 'Acasă';

  @override
  String get pray => 'Roagă-te';

  @override
  String get peopleGroups => 'Grupuri etnolingvistice';

  @override
  String nPeopleGroups(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de grupuri etnolingvistice',
      few: '$count grupuri etnolingvistice',
      one: '1 grup etnolingvistic',
      zero: 'Niciun grup etnolingvistic',
    );
    return '$_temp0';
  }

  @override
  String get searchPeopleGroups => 'Caută grupuri etnolingvistice';

  @override
  String get profile => 'Profil';

  @override
  String get reminders => 'Mementouri';

  @override
  String get settings => 'Setări';

  @override
  String get language => 'Limba';

  @override
  String get retry => 'Reîncearcă';

  @override
  String get couldNotLoadPeopleGroupsMessage =>
      'Grupurile etnolingvistice nu au putut fi încărcate.';

  @override
  String get selectPeopleGroup => 'Selectează un grup etnolingvistic';

  @override
  String get crossCulturalWorkersPresent => 'Lucrători transculturali prezenți';

  @override
  String get unselect => 'Deselectează';

  @override
  String get workInLocalLanguageAndCulture =>
      'Lucrare în limba și cultura locală';

  @override
  String get discipleAndChurchMultiplication =>
      'Multiplicarea ucenicilor și a bisericilor';

  @override
  String get resources => 'Resurse';

  @override
  String get bibleTranslation => 'Traducerea Bibliei';

  @override
  String get bibleStories => 'Povestiri biblice';

  @override
  String get jesusFilm => 'Filmul Isus';

  @override
  String get radioBroadcast => 'Emisiune radio';

  @override
  String get gospelRecordings => 'Înregistrări cu Evanghelia';

  @override
  String get audioScripture => 'Scriptura audio';

  @override
  String get overview => 'Prezentare generală';

  @override
  String get prayerStatus => 'Stadiul rugăciunii';

  @override
  String get peopleCommittedToPraying => 'Persoane angajate să se roage';

  @override
  String get dailyPrayerCoverage => 'Acoperire zilnică în rugăciune';

  @override
  String get peopleGroup => 'Grup etnolingvistic';

  @override
  String get couldNotLoadPeopleGroupDetailsMessage =>
      'Detaliile grupului etnolingvistic nu au putut fi încărcate.';

  @override
  String get share => 'Distribuie';

  @override
  String get search => 'Caută';

  @override
  String get country => 'Țara';

  @override
  String get alternateName => 'Nume alternativ';

  @override
  String get population => 'Populație';

  @override
  String get primaryLanguage => 'Limba principală';

  @override
  String get primaryReligion => 'Religia principală';

  @override
  String get religiousPractices => 'Practici religioase';

  @override
  String get setReminder => 'Setează un memento';

  @override
  String get pauseAndPray => 'Oprește-te și roagă-te';

  @override
  String get select => 'Selectează';

  @override
  String get selected => 'Selectat';

  @override
  String get yes => 'Da';

  @override
  String get no => 'Nu';

  @override
  String get partial => 'Parțial';

  @override
  String get status => 'Stare';

  @override
  String get engagementStatus => 'Stadiul angajării misionare';

  @override
  String get engaged => 'Angajat misionar';

  @override
  String get adoptionStatus => 'Stadiul adoptării';

  @override
  String get selectPeopleGroupConfirm =>
      'Vrei să selectezi acest grup etnolingvistic?';

  @override
  String switchPeopleGroupConfirm(String currentName, String newName) {
    return 'Vrei să nu te mai rogi pentru „$currentName” și să începi să te rogi pentru „$newName”?';
  }

  @override
  String get amen => 'Amin';

  @override
  String get noPeopleGroupSelected =>
      'Alege un grup etnolingvistic ca să începi să te rogi.';

  @override
  String get couldNotLoadPrayerContent =>
      'Conținutul de rugăciune nu a putut fi încărcat.';

  @override
  String get noPrayerContentAvailable =>
      'Niciun conținut de rugăciune pentru astăzi.';

  @override
  String get prayerThankYouTitle => 'Îți mulțumim că te-ai rugat';

  @override
  String get prayedToday => 'Te-ai rugat astăzi';

  @override
  String get prayerReminderTitle => 'Ești gata pentru rugăciunea de astăzi?';

  @override
  String prayerReminderBody(String peopleGroup) {
    return 'Atinge ca să te rogi pentru „$peopleGroup”.';
  }

  @override
  String get dismissReminderLabel => 'Închide mementoul';

  @override
  String prayForPeopleGroupLabel(String peopleGroup) {
    return 'Roagă-te pentru „$peopleGroup”';
  }

  @override
  String get pictureCreditLabel => 'Credit foto';

  @override
  String get clearSearchLabel => 'Șterge căutarea';

  @override
  String get forwardLabel => 'Înainte';

  @override
  String get prayerRecordedAnnouncement => 'Rugăciune înregistrată';

  @override
  String prayingWithYou(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString de persoane se roagă acum împreună cu tine',
      few: '$countString persoane se roagă acum împreună cu tine',
      one: '1 persoană se roagă acum împreună cu tine',
    );
    return '$_temp0';
  }

  @override
  String get newReminder => 'Memento nou';

  @override
  String get editReminder => 'Editează mementoul';

  @override
  String get save => 'Salvează';

  @override
  String get delete => 'Șterge';

  @override
  String get time => 'Ora';

  @override
  String get daysOfWeek => 'Zilele săptămânii';

  @override
  String get everyDay => 'În fiecare zi';

  @override
  String get noDaysSelected => 'Nicio zi selectată';

  @override
  String get noRemindersYet => 'Încă niciun memento';

  @override
  String get reminderNotificationTitle => 'E timpul pentru rugăciune';

  @override
  String get reminderNotificationBody =>
      'Deschide DOXA ca să începi rugăciunea de astăzi.';

  @override
  String get notifications => 'Notificări';

  @override
  String get notificationsEnabledStatus =>
      'Notificările sunt active. Vei primi mementourile de rugăciune.';

  @override
  String get notificationsDisabledStatus =>
      'Notificările sunt dezactivate, așa că mementourile tale de rugăciune nu vor apărea.';

  @override
  String get notificationsHowToEnable =>
      'Atinge mai jos ca să deschizi setările, apoi permite notificările pentru DOXA.';

  @override
  String get exactAlarmsDisabledStatus =>
      'Alarmele exacte nu sunt permise pentru DOXA, așa că mementourile tale de rugăciune pot ajunge cu câteva minute întârziere.';

  @override
  String get allowExactAlarms => 'Permite alarme exacte';

  @override
  String get exactAlarmsPromptBody =>
      'Pentru ca mementourile tale de rugăciune să ajungă la timp, permite-i aplicației DOXA să folosească alarme exacte.';

  @override
  String get allow => 'Permite';

  @override
  String get notNow => 'Nu acum';

  @override
  String get enableNotifications => 'Activează notificările';

  @override
  String get openSettings => 'Deschide setările';

  @override
  String get nextReminder => 'Următorul memento';

  @override
  String nextReminderToday(String time) {
    return 'Astăzi la $time';
  }

  @override
  String nextReminderTomorrow(String time) {
    return 'Mâine la $time';
  }

  @override
  String nextReminderOn(String weekday, String time) {
    return '$weekday la $time';
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
      other: '$countString de mementouri setate',
      few: '$countString mementouri setate',
      one: '1 memento setat',
      zero: 'Niciun memento setat',
    );
    return '$_temp0';
  }

  @override
  String get wizardWelcomeTitle => 'Bine ai venit la DOXA Prayer';

  @override
  String get wizardWelcomeBody =>
      'DOXA te ajută să te rogi pentru un grup etnolingvistic neatins cu Evanghelia. Te vom ajuta să alegi un grup, să setezi un memento și să rămâi la curent.';

  @override
  String get wizardGetStarted => 'Începe';

  @override
  String get wizardChoosePeopleGroupTitle => 'Alege un grup etnolingvistic';

  @override
  String wizardConfirmPeopleGroupTitle(String name) {
    return 'Te rogi pentru „$name”?';
  }

  @override
  String get wizardConfirmPeopleGroupBody =>
      'Îți vom arăta conținut de rugăciune și mementouri pentru acest grup. Poți schimba asta mai târziu.';

  @override
  String get wizardSetReminderTitle => 'Setează un memento de rugăciune';

  @override
  String get wizardSetReminderBody =>
      'Îți vom trimite un mic îndemn la ora aleasă de tine. Poți omite acest pas și adăuga mementouri mai târziu.';

  @override
  String get wizardNewsSignupTitle => 'Rămâi la curent';

  @override
  String get wizardNewsSignupBody =>
      'Opțional. Primește noutăți despre grupul tău etnolingvistic și de la DOXA.';

  @override
  String get back => 'Înapoi';

  @override
  String get continueLabel => 'Continuă';

  @override
  String get skip => 'Omite';

  @override
  String get finish => 'Finalizează';

  @override
  String get nameLabel => 'Nume';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get emailInvalid => 'Introdu o adresă de e-mail validă.';

  @override
  String get nameRequired => 'Introdu numele tău.';

  @override
  String get updatesAboutMyPeopleGroup =>
      'Primesc noutăți despre grupul meu etnolingvistic';

  @override
  String get updatesFromDoxa => 'Primesc noutăți de la DOXA';

  @override
  String get signUpForUpdates => 'Înscrie-te pentru noutăți';

  @override
  String get newsSignupSuccessTitle => 'Îți mulțumim pentru înscriere!';

  @override
  String newsSignupSuccessBody(String email) {
    return 'Am trimis un e-mail de verificare la $email. Deschide-ți inboxul și atinge linkul ca să confirmi abonarea.';
  }

  @override
  String get newsSignupError =>
      'Ceva nu a mers bine. Verifică-ți conexiunea și încearcă din nou.';

  @override
  String get enableNotificationsPromptBody =>
      'Activează notificările ca să primești aceste noutăți și pe telefon.';

  @override
  String get enableNotificationsButton => 'Activează notificările';

  @override
  String get accountSectionTitle => 'Contul tău';

  @override
  String get emailVerified => 'Verificată';

  @override
  String get emailUnverified => 'Neverificată';

  @override
  String get resendVerification => 'Retrimite e-mailul de verificare';

  @override
  String get resendVerificationSent =>
      'E-mail de verificare trimis. Verifică-ți inboxul.';

  @override
  String resendVerificationCooldown(int seconds) {
    return 'Așteaptă $seconds s înainte de a cere alt e-mail.';
  }

  @override
  String resendVerificationCountdown(int seconds) {
    return 'Retrimite în $seconds s';
  }

  @override
  String get signUp => 'Înscrie-te';

  @override
  String get resendVerificationFailed =>
      'E-mailul nu a putut fi trimis. Încearcă din nou.';

  @override
  String get viewProfile => 'Vezi profilul';

  @override
  String get emailsLoadError =>
      'Adresele tale de e-mail nu au putut fi încărcate.';

  @override
  String get updateAvailableTitle => 'Actualizare disponibilă';

  @override
  String get updateAvailableBody =>
      'O versiune nouă a aplicației DOXA Prayer este disponibilă.';

  @override
  String get updateRequiredTitle => 'Actualizare necesară';

  @override
  String get updateRequiredBody =>
      'Actualizează la cea mai recentă versiune ca să poți folosi în continuare DOXA Prayer.';

  @override
  String get updateAction => 'Actualizează';

  @override
  String get updateDismiss => 'Nu acum';

  @override
  String get feedback => 'Feedback';

  @override
  String get feedbackIntro =>
      'Ne-ar plăcea să auzim de la tine. Spune-ne ce părere ai despre aplicație.';

  @override
  String get feedbackTypeLabel => 'Ce fel de feedback?';

  @override
  String get feedbackTypeCompliment => 'Apreciere';

  @override
  String get feedbackTypeSuggestion => 'Sugestie';

  @override
  String get feedbackTypeProblem => 'Problemă';

  @override
  String get feedbackTypeRequired => 'Alege un tip de feedback.';

  @override
  String get feedbackNameLabel => 'Nume (opțional)';

  @override
  String get feedbackMessageLabel => 'Mesaj';

  @override
  String get feedbackMessageRequired => 'Introdu un mesaj.';

  @override
  String get feedbackConsentLabel =>
      'Ține-mă la curent cu noutățile de la DOXA';

  @override
  String get feedbackSubmit => 'Trimite feedbackul';

  @override
  String get feedbackError =>
      'Ceva nu a mers bine. Verifică-ți conexiunea și încearcă din nou.';

  @override
  String get feedbackRateLimited =>
      'Ai trimis mult feedback în ultima vreme. Încearcă din nou mai târziu.';

  @override
  String get feedbackSuccessTitle => 'Îți mulțumim!';

  @override
  String feedbackSuccessBody(String email) {
    return 'Feedbackul tău a fost trimis ca $email. Dacă nu este adresa corectă, trimite-l din nou cu cea corectă.';
  }

  @override
  String shareMessage(String name) {
    return 'Roagă-te cu mine pentru „$name” — descarcă aplicația DOXA Prayer:';
  }

  @override
  String get shareLink => 'Distribuie linkul';

  @override
  String scanToPray(String name) {
    return 'Scanează ca să obții aplicația și să te rogi pentru „$name”';
  }

  @override
  String appVersion(String version) {
    return 'Versiunea $version';
  }

  @override
  String get previousDay => 'Ziua anterioară';

  @override
  String get nextDay => 'Ziua următoare';

  @override
  String get dayInTheLifeTitle => 'O zi din viață';

  @override
  String get myPeopleGroupTitle => 'Grupul meu etnolingvistic';

  @override
  String peopleGroupIntroTitle(String name) {
    return 'Roagă-te pentru „$name”';
  }

  @override
  String get peopleGroupOfTheDay => 'Grupul etnolingvistic al zilei';

  @override
  String get pressBackAgainToExit => 'Apasă din nou Înapoi ca să ieși';

  @override
  String get notifications_enabled => 'Notificări activate';

  @override
  String get notifications_disabled => 'Notificări dezactivate';

  @override
  String get cancel => 'Anulează';

  @override
  String addPeopleGroupConfirm(String name) {
    return 'Vrei să începi să te rogi pentru „$name”?';
  }

  @override
  String get choosePeopleGroup => 'Alege un grup etnolingvistic';

  @override
  String get addAnotherPeopleGroup => 'Adaugă alt grup etnolingvistic';

  @override
  String peopleGroupLimitTitle(num count) {
    return 'Te rogi pentru $count grupuri etnolingvistice';
  }

  @override
  String peopleGroupLimitBody(String name) {
    return 'Este numărul maxim pentru care te poți ruga în același timp. Ca să adaugi „$name”, alege un grup pentru care să nu te mai rogi.';
  }

  @override
  String get swapPeopleGroupAction => 'Înlocuiește';

  @override
  String removePeopleGroupTitle(String name) {
    return 'Nu te mai rogi pentru „$name”?';
  }

  @override
  String get removePeopleGroupBody =>
      'Va fi eliminat de pe ecranul tău principal. Îl poți adăuga din nou oricând.';

  @override
  String removePeopleGroupReminders(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cele $count de mementouri ale lui vor fi șterse.',
      few: 'Cele $count mementouri ale lui vor fi șterse.',
      one: 'Mementoul lui va fi șters.',
    );
    return '$_temp0';
  }

  @override
  String get stopPraying => 'Nu mă mai rog';

  @override
  String get noPeopleGroupsForReminder =>
      'Alege un grup etnolingvistic înainte de a seta un memento.';

  @override
  String get reminderPeopleGroup => 'Grup etnolingvistic';

  @override
  String reminderNotificationBodyForGroup(String name) {
    return 'Deschide DOXA ca să te rogi pentru „$name”.';
  }

  @override
  String nextReminderForGroup(String time, String name) {
    return '$time pentru „$name”';
  }

  @override
  String prayForNextGroup(String name) {
    return 'Roagă-te pentru „$name”';
  }

  @override
  String switchToPeopleGroup(String name) {
    return 'Comută la „$name”';
  }

  @override
  String get map => 'Hartă';

  @override
  String mapOf(String name) {
    return 'Harta grupului „$name”';
  }

  @override
  String get nearbyPeopleGroups => 'Grupuri etnolingvistice din apropiere';

  @override
  String get recenter => 'Recentrează';

  @override
  String get mapUnavailableOffline =>
      'Imaginile hărții nu sunt disponibile offline';

  @override
  String get yourPeopleGroups => 'Grupurile tale etnolingvistice';

  @override
  String get locationNotAvailable => 'Locație indisponibilă';

  @override
  String get couldNotLoadMapMessage => 'Harta nu a putut fi încărcată.';
}
