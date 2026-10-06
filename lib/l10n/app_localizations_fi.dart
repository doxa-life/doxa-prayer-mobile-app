// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get appName => 'DOXA Prayer';

  @override
  String get home => 'Koti';

  @override
  String get pray => 'Rukoile';

  @override
  String get peopleGroups => 'Kansanryhmät';

  @override
  String nPeopleGroups(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kansanryhmää',
      one: '1 kansanryhmä',
      zero: 'Ei kansanryhmiä',
    );
    return '$_temp0';
  }

  @override
  String get searchPeopleGroups => 'Hae kansanryhmiä';

  @override
  String get profile => 'Profiili';

  @override
  String get reminders => 'Muistutukset';

  @override
  String get settings => 'Asetukset';

  @override
  String get language => 'Kieli';

  @override
  String get retry => 'Yritä uudelleen';

  @override
  String get couldNotLoadPeopleGroupsMessage => 'Kansanryhmiä ei voitu latata.';

  @override
  String get selectPeopleGroup => 'Valitse kansanryhmä';

  @override
  String get crossCulturalWorkersPresent =>
      'Kulttuurirajat ylittäviä työntekijöitä paikalla';

  @override
  String get unselect => 'Poista valinta';

  @override
  String get workInLocalLanguageAndCulture =>
      'Työ paikallisella kielellä ja kulttuurissa';

  @override
  String get discipleAndChurchMultiplication =>
      'Opetuslapseuden ja seurakuntien moninkertaistuminen';

  @override
  String get resources => 'Resurssit';

  @override
  String get bibleTranslation => 'Raamatunkäännös';

  @override
  String get bibleStories => 'Raamatun kertomukset';

  @override
  String get jesusFilm => 'Jeesus-elokuva';

  @override
  String get radioBroadcast => 'Radiolähetys';

  @override
  String get gospelRecordings => 'Evankeliumiäänitteet';

  @override
  String get audioScripture => 'Raamattu äänikirjana';

  @override
  String get overview => 'Yleiskatsaus';

  @override
  String get prayerStatus => 'Rukouksen tilanne';

  @override
  String get peopleCommittedToPraying => 'Rukoukseen sitoutuneet ihmiset';

  @override
  String get dailyPrayerCoverage => 'Päivittäisen rukouksen kattavuus';

  @override
  String get peopleGroup => 'Kansanryhmä';

  @override
  String get couldNotLoadPeopleGroupDetailsMessage =>
      'Kansanryhmän tietoja ei voitu latata.';

  @override
  String get share => 'Jaa';

  @override
  String get search => 'Hae';

  @override
  String get country => 'Maa';

  @override
  String get alternateName => 'Vaihtoehtoinen nimi';

  @override
  String get population => 'Väestö';

  @override
  String get primaryLanguage => 'Pääkieli';

  @override
  String get primaryReligion => 'Pääuskonto';

  @override
  String get religiousPractices => 'Uskonnolliset käytännöt';

  @override
  String get setReminder => 'Aseta muistutus';

  @override
  String get pauseAndPray => 'Pysähdy ja rukoile';

  @override
  String get select => 'Valitse';

  @override
  String get selected => 'Valittu';

  @override
  String get yes => 'Kyllä';

  @override
  String get no => 'Ei';

  @override
  String get partial => 'Osittainen';

  @override
  String get status => 'Tila';

  @override
  String get engagementStatus => 'Kohtaamistyön tilanne';

  @override
  String get engaged => 'Kohdattu';

  @override
  String get unengaged => 'Unengaged';

  @override
  String nPeoplePraying(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people praying',
      one: '1 person praying',
      zero: 'No one praying yet',
    );
    return '$_temp0';
  }

  @override
  String get adoptionStatus => 'Vastuunoton tilanne';

  @override
  String get selectPeopleGroupConfirm => 'Haluatko valita tämän kansanryhmän?';

  @override
  String switchPeopleGroupConfirm(String currentName, String newName) {
    return 'Haluatko lopettaa rukoilemisen kansanryhmän $currentName puolesta ja alkaa rukoilla kansanryhmän $newName puolesta?';
  }

  @override
  String get amen => 'Aamen';

  @override
  String get noPeopleGroupSelected =>
      'Valitse kansanryhmä aloittaaksesi rukoilemisen.';

  @override
  String get couldNotLoadPrayerContent => 'Rukoussisältöä ei voitu latata.';

  @override
  String get noPrayerContentAvailable =>
      'Tälle päivälle ei ole rukoussisältöä.';

  @override
  String get prayerThankYouTitle => 'Kiitos, että rukoilit';

  @override
  String get prayedToday => 'Rukoiltu tänään';

  @override
  String get prayerReminderTitle => 'Valmiina tämän päivän rukoukseen?';

  @override
  String prayerReminderBody(String peopleGroup) {
    return 'Napauta rukoillaksesi kansanryhmän $peopleGroup puolesta.';
  }

  @override
  String get dismissReminderLabel => 'Hylkää muistutus';

  @override
  String prayForPeopleGroupLabel(String peopleGroup) {
    return 'Rukoile kansanryhmän $peopleGroup puolesta';
  }

  @override
  String get pictureCreditLabel => 'Kuvan lähde';

  @override
  String get clearSearchLabel => 'Tyhjennä haku';

  @override
  String get forwardLabel => 'Eteenpäin';

  @override
  String get prayerRecordedAnnouncement => 'Rukous tallennettu';

  @override
  String prayingWithYou(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$countString henkilöä rukoilee juuri nyt kohtaamattomien kansanryhmien puolesta',
      one:
          '$countString henkilö rukoilee juuri nyt kohtaamattomien kansanryhmien puolesta',
    );
    return '$_temp0';
  }

  @override
  String get newReminder => 'Uusi muistutus';

  @override
  String get editReminder => 'Muokkaa muistutusta';

  @override
  String get save => 'Tallenna';

  @override
  String get delete => 'Poista';

  @override
  String get time => 'Aika';

  @override
  String get daysOfWeek => 'Viikonpäivät';

  @override
  String get everyDay => 'Joka päivä';

  @override
  String get noDaysSelected => 'Ei valittuja päiviä';

  @override
  String get noRemindersYet => 'Ei vielä muistutuksia';

  @override
  String get reminderNotificationTitle => 'On aika rukoilla';

  @override
  String get reminderNotificationBody =>
      'Avaa DOXA aloittaaksesi tämän päivän rukouksen.';

  @override
  String get notifications => 'Ilmoitukset';

  @override
  String get notificationsEnabledStatus =>
      'Ilmoitukset ovat käytössä. Rukousmuistutuksesi toimitetaan.';

  @override
  String get notificationsDisabledStatus =>
      'Ilmoitukset on poistettu käytöstä, joten rukousmuistutuksesi eivät näy.';

  @override
  String get notificationsHowToEnable =>
      'Napauta alla avataksesi asetukset ja salli sitten ilmoitukset DOXAlle.';

  @override
  String get exactAlarmsDisabledStatus =>
      'Täsmähälytykset eivät ole sallittuja DOXAlle, joten rukousmuistutuksesi voivat saapua useita minuutteja myöhässä.';

  @override
  String get allowExactAlarms => 'Salli täsmähälytykset';

  @override
  String get exactAlarmsPromptBody =>
      'Jotta rukousmuistutuksesi saapuvat täsmälleen ajallaan, salli DOXAn käyttää täsmähälytyksiä.';

  @override
  String get allow => 'Salli';

  @override
  String get notNow => 'Ei nyt';

  @override
  String get enableNotifications => 'Ota ilmoitukset käyttöön';

  @override
  String get openSettings => 'Avaa asetukset';

  @override
  String get nextReminder => 'Seuraava muistutus';

  @override
  String nextReminderToday(String time) {
    return 'Tänään klo $time';
  }

  @override
  String nextReminderTomorrow(String time) {
    return 'Huomenna klo $time';
  }

  @override
  String nextReminderOn(String weekday, String time) {
    return '$weekday klo $time';
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
      other: '$countString muistutusta asetettuna',
      one: '1 muistutus asetettuna',
      zero: 'Ei muistutuksia asetettuna',
    );
    return '$_temp0';
  }

  @override
  String get wizardWelcomeTitle => 'Tervetuloa DOXA Prayer -sovellukseen';

  @override
  String get wizardWelcomeBody =>
      'DOXA auttaa sinua rukoilemaan tavoittamattoman kansanryhmän puolesta. Autamme sinua valitsemaan ryhmän, asettamaan muistutuksen ja pysymään ajan tasalla.';

  @override
  String get wizardGetStarted => 'Aloita';

  @override
  String get wizardChoosePeopleGroupTitle => 'Valitse kansanryhmä';

  @override
  String wizardConfirmPeopleGroupTitle(String name) {
    return 'Rukoiletko kansanryhmän $name puolesta?';
  }

  @override
  String get wizardConfirmPeopleGroupBody =>
      'Näytämme sinulle rukoussisältöä ja muistutuksia tälle ryhmälle. Voit muuttaa tätä myöhemmin.';

  @override
  String get wizardSetReminderTitle => 'Aseta rukousmuistutus';

  @override
  String get wizardSetReminderBody =>
      'Lähetämme sinulle lempeän muistutuksen valitsemanasi aikana. Voit ohittaa tämän ja lisätä muistutuksia myöhemmin.';

  @override
  String get wizardNewsSignupTitle => 'Pysy ajan tasalla';

  @override
  String get wizardNewsSignupBody =>
      'Valinnainen. Saat uutisia kansanryhmästäsi ja päivityksiä DOXAlta.';

  @override
  String get back => 'Takaisin';

  @override
  String get continueLabel => 'Jatka';

  @override
  String get skip => 'Ohita';

  @override
  String get finish => 'Valmis';

  @override
  String get nameLabel => 'Nimi';

  @override
  String get emailLabel => 'Sähköposti';

  @override
  String get emailInvalid => 'Anna kelvollinen sähköpostiosoite.';

  @override
  String get nameRequired => 'Anna nimesi.';

  @override
  String get updatesAboutMyPeopleGroup =>
      'Vastaanota päivityksiä kansanryhmästäni';

  @override
  String get updatesFromDoxa => 'Vastaanota päivityksiä DOXAlta';

  @override
  String get signUpForUpdates => 'Tilaa päivitykset';

  @override
  String get newsSignupSuccessTitle => 'Kiitos tilauksesta!';

  @override
  String newsSignupSuccessBody(String email) {
    return 'Lähetimme vahvistussähköpostin osoitteeseen $email. Avaa postilaatikkosi ja napauta linkkiä vahvistaaksesi tilauksesi.';
  }

  @override
  String get newsSignupError =>
      'Jokin meni pieleen. Tarkista yhteytesi ja yritä uudelleen.';

  @override
  String get enableNotificationsPromptBody =>
      'Ota ilmoitukset käyttöön saadaksesi näitä päivityksiä myös puhelimeesi.';

  @override
  String get enableNotificationsButton => 'Ota ilmoitukset käyttöön';

  @override
  String get accountSectionTitle => 'Tilisi';

  @override
  String get emailVerified => 'Vahvistettu';

  @override
  String get emailUnverified => 'Ei vahvistettu';

  @override
  String get resendVerification => 'Lähetä vahvistussähköposti uudelleen';

  @override
  String get resendVerificationSent =>
      'Vahvistussähköposti lähetetty. Tarkista postilaatikkosi.';

  @override
  String resendVerificationCooldown(int seconds) {
    return 'Odota $seconds s, ennen kuin pyydät toisen sähköpostin.';
  }

  @override
  String resendVerificationCountdown(int seconds) {
    return 'Lähetä uudelleen $seconds s kuluttua';
  }

  @override
  String get signUp => 'Tilaa';

  @override
  String get resendVerificationFailed =>
      'Sähköpostia ei voitu lähettää. Yritä uudelleen.';

  @override
  String get viewProfile => 'Näytä profiili';

  @override
  String get emailsLoadError => 'Sähköpostiosoitteitasi ei voitu latata.';

  @override
  String get updateAvailableTitle => 'Päivitys saatavilla';

  @override
  String get updateAvailableBody =>
      'DOXA Prayerista on saatavilla uusi versio.';

  @override
  String get updateRequiredTitle => 'Päivitys vaaditaan';

  @override
  String get updateRequiredBody =>
      'Päivitä uusimpaan versioon jatkaaksesi DOXA Prayerin käyttöä.';

  @override
  String get updateAction => 'Päivitä';

  @override
  String get updateDismiss => 'Ei nyt';

  @override
  String get feedback => 'Palaute';

  @override
  String get feedbackIntro =>
      'Haluaisimme kuulla sinusta. Kerro, mitä pidät sovelluksesta.';

  @override
  String get feedbackTypeLabel => 'Minkälaista palautetta?';

  @override
  String get feedbackTypeCompliment => 'Kiitos';

  @override
  String get feedbackTypeSuggestion => 'Ehdotus';

  @override
  String get feedbackTypeProblem => 'Ongelma';

  @override
  String get feedbackTypeRequired => 'Valitse palautteen tyyppi.';

  @override
  String get feedbackNameLabel => 'Nimi (valinnainen)';

  @override
  String get feedbackMessageLabel => 'Viesti';

  @override
  String get feedbackMessageRequired => 'Kirjoita viesti.';

  @override
  String get feedbackConsentLabel => 'Pidä minut ajan tasalla DOXAn uutisista';

  @override
  String get feedbackSubmit => 'Lähetä palaute';

  @override
  String get feedbackError =>
      'Jokin meni pieleen. Tarkista yhteytesi ja yritä uudelleen.';

  @override
  String get feedbackRateLimited =>
      'Olet lähettänyt paljon palautetta viime aikoina. Yritä myöhemmin uudelleen.';

  @override
  String get feedbackSuccessTitle => 'Kiitos!';

  @override
  String feedbackSuccessBody(String email) {
    return 'Palautteesi lähetettiin osoitteesta $email. Jos se ei ole oikea osoite, lähetä palaute uudelleen oikealla osoitteella.';
  }

  @override
  String shareMessage(String name) {
    return 'Rukoile kanssani kansanryhmän $name puolesta — hanki DOXA Prayer -sovellus:';
  }

  @override
  String get shareLink => 'Jaa linkki';

  @override
  String scanToPray(String name) {
    return 'Skannaa saadaksesi sovelluksen ja rukoillaksesi kansanryhmän $name puolesta';
  }

  @override
  String appVersion(String version) {
    return 'Versio $version';
  }

  @override
  String get previousDay => 'Edellinen päivä';

  @override
  String get nextDay => 'Seuraava päivä';

  @override
  String get dayInTheLifeTitle => 'Päivä elämässä';

  @override
  String get myPeopleGroupTitle => 'Oma kansanryhmäni';

  @override
  String peopleGroupIntroTitle(String name) {
    return 'Rukoile kansanryhmän $name puolesta';
  }

  @override
  String get peopleGroupOfTheDay => 'Päivän kansanryhmä';

  @override
  String get pressBackAgainToExit =>
      'Paina takaisin-painiketta uudelleen poistuaksesi';

  @override
  String get notifications_enabled => 'Ilmoitukset käytössä';

  @override
  String get notifications_disabled => 'Ilmoitukset pois käytöstä';

  @override
  String get cancel => 'Peruuta';

  @override
  String addPeopleGroupConfirm(String name) {
    return 'Haluatko alkaa rukoilla kansanryhmän $name puolesta?';
  }

  @override
  String get choosePeopleGroup => 'Valitse kansanryhmä';

  @override
  String get addAnotherPeopleGroup => 'Lisää toinen kansanryhmä';

  @override
  String peopleGroupLimitTitle(num count) {
    return 'Rukoilet $count kansanryhmän puolesta';
  }

  @override
  String peopleGroupLimitBody(String name) {
    return 'Se on enimmäismäärä, jonka puolesta voit rukoilla samanaikaisesti. Lisätäksesi kansanryhmän $name, valitse yksi, jonka puolesta lopetat rukoilemisen.';
  }

  @override
  String get swapPeopleGroupAction => 'Vaihda';

  @override
  String removePeopleGroupTitle(String name) {
    return 'Lopeta rukoileminen kansanryhmän $name puolesta?';
  }

  @override
  String get removePeopleGroupBody =>
      'Se poistetaan aloitusnäytöltäsi. Voit lisätä sen takaisin milloin tahansa.';

  @override
  String removePeopleGroupReminders(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sen $count muistutusta poistetaan.',
      one: 'Sen muistutus poistetaan.',
    );
    return '$_temp0';
  }

  @override
  String get stopPraying => 'Lopeta rukoileminen';

  @override
  String get noPeopleGroupsForReminder =>
      'Valitse kansanryhmä ennen muistutuksen asettamista.';

  @override
  String get reminderPeopleGroup => 'Kansanryhmä';

  @override
  String reminderNotificationBodyForGroup(String name) {
    return 'Avaa DOXA rukoillaksesi kansanryhmän $name puolesta.';
  }

  @override
  String nextReminderForGroup(String time, String name) {
    return '$time kansanryhmän $name puolesta';
  }

  @override
  String prayForNextGroup(String name) {
    return 'Rukoile kansanryhmän $name puolesta';
  }

  @override
  String switchToPeopleGroup(String name) {
    return 'Vaihda kansanryhmään $name';
  }

  @override
  String get map => 'Kartta';

  @override
  String mapOf(String name) {
    return 'Kansanryhmän $name kartta';
  }

  @override
  String get nearbyPeopleGroups => 'Lähellä olevat kansanryhmät';

  @override
  String get recenter => 'Keskitä uudelleen';

  @override
  String get mapUnavailableOffline =>
      'Karttakuvat eivät ole käytettävissä offline-tilassa';

  @override
  String get yourPeopleGroups => 'Omat kansanryhmäsi';

  @override
  String get locationNotAvailable => 'Sijaintia ei saatavilla';

  @override
  String get couldNotLoadMapMessage => 'Karttaa ei voitu latata.';

  @override
  String get filters => 'Filters';

  @override
  String get sortByName => 'Sort by name';

  @override
  String get sortAscending => 'Sort ascending (A–Z)';

  @override
  String get sortDescending => 'Sort descending (Z–A)';

  @override
  String get allLanguages => 'All languages';

  @override
  String get allReligions => 'All religions';

  @override
  String get allStatuses => 'Either status';

  @override
  String nSelected(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
      zero: 'None selected',
    );
    return '$_temp0';
  }

  @override
  String get clear => 'Clear';

  @override
  String get done => 'Done';

  @override
  String get clearFilters => 'Clear filters';
}
