// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'DOXA Prayer';

  @override
  String get home => 'Home';

  @override
  String get pray => 'Prega';

  @override
  String get peopleGroups => 'Gruppi etnici';

  @override
  String nPeopleGroups(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gruppi etnici',
      one: '1 gruppo etnico',
      zero: 'Nessun gruppo etnico',
    );
    return '$_temp0';
  }

  @override
  String get searchPeopleGroups => 'Cerca gruppi etnici';

  @override
  String get profile => 'Profilo';

  @override
  String get reminders => 'Promemoria';

  @override
  String get settings => 'Impostazioni';

  @override
  String get language => 'Lingua';

  @override
  String get retry => 'Riprova';

  @override
  String get couldNotLoadPeopleGroupsMessage =>
      'Impossibile caricare i gruppi etnici.';

  @override
  String get selectPeopleGroup => 'Seleziona un gruppo etnico';

  @override
  String get crossCulturalWorkersPresent => 'Operatori transculturali presenti';

  @override
  String get unselect => 'Deseleziona';

  @override
  String get workInLocalLanguageAndCulture =>
      'Lavoro nella lingua e nella cultura locali';

  @override
  String get discipleAndChurchMultiplication =>
      'Moltiplicazione di discepoli e chiese';

  @override
  String get resources => 'Risorse';

  @override
  String get bibleTranslation => 'Traduzione della Bibbia';

  @override
  String get bibleStories => 'Racconti biblici';

  @override
  String get jesusFilm => 'Film su Gesù';

  @override
  String get radioBroadcast => 'Trasmissione radio';

  @override
  String get gospelRecordings => 'Registrazioni del Vangelo';

  @override
  String get audioScripture => 'Scrittura in audio';

  @override
  String get overview => 'Panoramica';

  @override
  String get prayerStatus => 'Stato della preghiera';

  @override
  String get peopleCommittedToPraying => 'Persone impegnate a pregare';

  @override
  String get dailyPrayerCoverage => 'Copertura di preghiera quotidiana';

  @override
  String get peopleGroup => 'Gruppo etnico';

  @override
  String get couldNotLoadPeopleGroupDetailsMessage =>
      'Impossibile caricare i dettagli del gruppo etnico.';

  @override
  String get share => 'Condividi';

  @override
  String get search => 'Cerca';

  @override
  String get country => 'Paese';

  @override
  String get alternateName => 'Nome alternativo';

  @override
  String get population => 'Popolazione';

  @override
  String get primaryLanguage => 'Lingua principale';

  @override
  String get primaryReligion => 'Religione principale';

  @override
  String get religiousPractices => 'Pratiche religiose';

  @override
  String get setReminder => 'Imposta un promemoria';

  @override
  String get pauseAndPray => 'Fermati e prega';

  @override
  String get select => 'Seleziona';

  @override
  String get selected => 'Selezionato';

  @override
  String get yes => 'Sì';

  @override
  String get no => 'No';

  @override
  String get partial => 'Parziale';

  @override
  String get status => 'Stato';

  @override
  String get engagementStatus => 'Stato del coinvolgimento';

  @override
  String get engaged => 'Coinvolto';

  @override
  String get adoptionStatus => 'Stato dell\'adozione';

  @override
  String get selectPeopleGroupConfirm =>
      'Vuoi selezionare questo gruppo etnico?';

  @override
  String switchPeopleGroupConfirm(String currentName, String newName) {
    return 'Vuoi smettere di pregare per «$currentName» e iniziare a pregare per «$newName»?';
  }

  @override
  String get amen => 'Amen';

  @override
  String get noPeopleGroupSelected =>
      'Scegli un gruppo etnico per iniziare a pregare.';

  @override
  String get couldNotLoadPrayerContent =>
      'Impossibile caricare i contenuti di preghiera.';

  @override
  String get noPrayerContentAvailable =>
      'Nessun contenuto di preghiera per oggi.';

  @override
  String get prayerThankYouTitle => 'Grazie per aver pregato';

  @override
  String get prayedToday => 'Hai pregato oggi';

  @override
  String get prayerReminderTitle => 'Pronto per la preghiera di oggi?';

  @override
  String prayerReminderBody(String peopleGroup) {
    return 'Tocca per pregare per «$peopleGroup».';
  }

  @override
  String get dismissReminderLabel => 'Chiudi il promemoria';

  @override
  String prayForPeopleGroupLabel(String peopleGroup) {
    return 'Prega per «$peopleGroup»';
  }

  @override
  String get pictureCreditLabel => 'Crediti foto';

  @override
  String get clearSearchLabel => 'Cancella la ricerca';

  @override
  String get forwardLabel => 'Avanti';

  @override
  String get prayerRecordedAnnouncement => 'Preghiera registrata';

  @override
  String prayingWithYou(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString persone stanno pregando con te ora',
      one: '1 persona sta pregando con te ora',
    );
    return '$_temp0';
  }

  @override
  String get newReminder => 'Nuovo promemoria';

  @override
  String get editReminder => 'Modifica promemoria';

  @override
  String get save => 'Salva';

  @override
  String get delete => 'Elimina';

  @override
  String get time => 'Ora';

  @override
  String get daysOfWeek => 'Giorni della settimana';

  @override
  String get everyDay => 'Ogni giorno';

  @override
  String get noDaysSelected => 'Nessun giorno selezionato';

  @override
  String get noRemindersYet => 'Ancora nessun promemoria';

  @override
  String get reminderNotificationTitle => 'È ora di pregare';

  @override
  String get reminderNotificationBody =>
      'Apri DOXA per iniziare la preghiera di oggi.';

  @override
  String get notifications => 'Notifiche';

  @override
  String get notificationsEnabledStatus =>
      'Le notifiche sono attive. Riceverai i tuoi promemoria di preghiera.';

  @override
  String get notificationsDisabledStatus =>
      'Le notifiche sono disattivate, quindi i tuoi promemoria di preghiera non compariranno.';

  @override
  String get notificationsHowToEnable =>
      'Tocca qui sotto per aprire le impostazioni, poi consenti le notifiche per DOXA.';

  @override
  String get exactAlarmsDisabledStatus =>
      'Le sveglie esatte non sono consentite per DOXA, quindi i tuoi promemoria di preghiera potrebbero arrivare con qualche minuto di ritardo.';

  @override
  String get allowExactAlarms => 'Consenti sveglie esatte';

  @override
  String get exactAlarmsPromptBody =>
      'Perché i tuoi promemoria di preghiera arrivino in orario, consenti a DOXA di usare sveglie esatte.';

  @override
  String get allow => 'Consenti';

  @override
  String get notNow => 'Non ora';

  @override
  String get enableNotifications => 'Attiva le notifiche';

  @override
  String get openSettings => 'Apri le impostazioni';

  @override
  String get nextReminder => 'Prossimo promemoria';

  @override
  String nextReminderToday(String time) {
    return 'Oggi alle $time';
  }

  @override
  String nextReminderTomorrow(String time) {
    return 'Domani alle $time';
  }

  @override
  String nextReminderOn(String weekday, String time) {
    return '$weekday alle $time';
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
      other: '$countString promemoria impostati',
      one: '1 promemoria impostato',
      zero: 'Nessun promemoria impostato',
    );
    return '$_temp0';
  }

  @override
  String get wizardWelcomeTitle => 'Benvenuto in DOXA Prayer';

  @override
  String get wizardWelcomeBody =>
      'DOXA ti aiuta a pregare per un gruppo etnico non raggiunto. Ti aiuteremo a scegliere un gruppo, impostare un promemoria e restare aggiornato.';

  @override
  String get wizardGetStarted => 'Inizia';

  @override
  String get wizardChoosePeopleGroupTitle => 'Scegli un gruppo etnico';

  @override
  String wizardConfirmPeopleGroupTitle(String name) {
    return 'Pregare per «$name»?';
  }

  @override
  String get wizardConfirmPeopleGroupBody =>
      'Ti mostreremo contenuti di preghiera e promemoria per questo gruppo. Potrai cambiarlo in seguito.';

  @override
  String get wizardSetReminderTitle => 'Imposta un promemoria di preghiera';

  @override
  String get wizardSetReminderBody =>
      'Ti manderemo un piccolo richiamo all\'ora che scegli. Puoi saltare questo passaggio e aggiungere promemoria più tardi.';

  @override
  String get wizardNewsSignupTitle => 'Resta aggiornato';

  @override
  String get wizardNewsSignupBody =>
      'Facoltativo. Ricevi notizie sul tuo gruppo etnico e aggiornamenti da DOXA.';

  @override
  String get back => 'Indietro';

  @override
  String get continueLabel => 'Continua';

  @override
  String get skip => 'Salta';

  @override
  String get finish => 'Fine';

  @override
  String get nameLabel => 'Nome';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get emailInvalid => 'Inserisci un indirizzo e-mail valido.';

  @override
  String get nameRequired => 'Inserisci il tuo nome.';

  @override
  String get updatesAboutMyPeopleGroup =>
      'Ricevi aggiornamenti sul mio gruppo etnico';

  @override
  String get updatesFromDoxa => 'Ricevi aggiornamenti da DOXA';

  @override
  String get signUpForUpdates => 'Iscriviti agli aggiornamenti';

  @override
  String get newsSignupSuccessTitle => 'Grazie per l\'iscrizione!';

  @override
  String newsSignupSuccessBody(String email) {
    return 'Abbiamo inviato un\'e-mail di verifica a $email. Apri la tua casella di posta e tocca il link per confermare l\'iscrizione.';
  }

  @override
  String get newsSignupError =>
      'Qualcosa è andato storto. Controlla la connessione e riprova.';

  @override
  String get enableNotificationsPromptBody =>
      'Attiva le notifiche per ricevere questi aggiornamenti anche sul telefono.';

  @override
  String get enableNotificationsButton => 'Attiva le notifiche';

  @override
  String get accountSectionTitle => 'Il tuo account';

  @override
  String get emailVerified => 'Verificato';

  @override
  String get emailUnverified => 'Non verificato';

  @override
  String get resendVerification => 'Invia di nuovo l\'e-mail di verifica';

  @override
  String get resendVerificationSent =>
      'E-mail di verifica inviata. Controlla la tua casella di posta.';

  @override
  String resendVerificationCooldown(int seconds) {
    return 'Attendi $seconds s prima di richiedere un\'altra e-mail.';
  }

  @override
  String resendVerificationCountdown(int seconds) {
    return 'Invia di nuovo tra $seconds s';
  }

  @override
  String get signUp => 'Iscriviti';

  @override
  String get resendVerificationFailed =>
      'Impossibile inviare l\'e-mail. Riprova.';

  @override
  String get viewProfile => 'Vedi il profilo';

  @override
  String get emailsLoadError => 'Impossibile caricare i tuoi indirizzi e-mail.';

  @override
  String get updateAvailableTitle => 'Aggiornamento disponibile';

  @override
  String get updateAvailableBody =>
      'È disponibile una nuova versione di DOXA Prayer.';

  @override
  String get updateRequiredTitle => 'Aggiornamento necessario';

  @override
  String get updateRequiredBody =>
      'Aggiorna all\'ultima versione per continuare a usare DOXA Prayer.';

  @override
  String get updateAction => 'Aggiorna';

  @override
  String get updateDismiss => 'Non ora';

  @override
  String get feedback => 'Feedback';

  @override
  String get feedbackIntro =>
      'Ci farebbe piacere sentirti. Dicci cosa pensi dell\'app.';

  @override
  String get feedbackTypeLabel => 'Che tipo di feedback?';

  @override
  String get feedbackTypeCompliment => 'Complimento';

  @override
  String get feedbackTypeSuggestion => 'Suggerimento';

  @override
  String get feedbackTypeProblem => 'Problema';

  @override
  String get feedbackTypeRequired => 'Scegli un tipo di feedback.';

  @override
  String get feedbackNameLabel => 'Nome (facoltativo)';

  @override
  String get feedbackMessageLabel => 'Messaggio';

  @override
  String get feedbackMessageRequired => 'Inserisci un messaggio.';

  @override
  String get feedbackConsentLabel => 'Tienimi aggiornato sulle novità di DOXA';

  @override
  String get feedbackSubmit => 'Invia il feedback';

  @override
  String get feedbackError =>
      'Qualcosa è andato storto. Controlla la connessione e riprova.';

  @override
  String get feedbackRateLimited =>
      'Hai inviato molti feedback di recente. Riprova più tardi.';

  @override
  String get feedbackSuccessTitle => 'Grazie!';

  @override
  String feedbackSuccessBody(String email) {
    return 'Il tuo feedback è stato inviato come $email. Se non è l\'indirizzo giusto, invialo di nuovo con quello corretto.';
  }

  @override
  String shareMessage(String name) {
    return 'Prega con me per «$name» — scarica l\'app DOXA Prayer:';
  }

  @override
  String get shareLink => 'Condividi il link';

  @override
  String scanToPray(String name) {
    return 'Scansiona per scaricare l\'app e pregare per «$name»';
  }

  @override
  String appVersion(String version) {
    return 'Versione $version';
  }

  @override
  String get previousDay => 'Giorno precedente';

  @override
  String get nextDay => 'Giorno successivo';

  @override
  String get dayInTheLifeTitle => 'Un giorno nella loro vita';

  @override
  String get myPeopleGroupTitle => 'Il mio gruppo etnico';

  @override
  String peopleGroupIntroTitle(String name) {
    return 'Prega per «$name»';
  }

  @override
  String get peopleGroupOfTheDay => 'Gruppo etnico del giorno';

  @override
  String get pressBackAgainToExit => 'Premi di nuovo Indietro per uscire';

  @override
  String get notifications_enabled => 'Notifiche attivate';

  @override
  String get notifications_disabled => 'Notifiche disattivate';

  @override
  String get cancel => 'Annulla';

  @override
  String addPeopleGroupConfirm(String name) {
    return 'Vuoi iniziare a pregare per «$name»?';
  }

  @override
  String get choosePeopleGroup => 'Scegli un gruppo etnico';

  @override
  String get addAnotherPeopleGroup => 'Aggiungi un altro gruppo etnico';

  @override
  String peopleGroupLimitTitle(num count) {
    return 'Stai pregando per $count gruppi etnici';
  }

  @override
  String peopleGroupLimitBody(String name) {
    return 'È il massimo per cui puoi pregare contemporaneamente. Per aggiungere «$name», scegli un gruppo per cui smettere di pregare.';
  }

  @override
  String get swapPeopleGroupAction => 'Sostituisci';

  @override
  String removePeopleGroupTitle(String name) {
    return 'Smettere di pregare per «$name»?';
  }

  @override
  String get removePeopleGroupBody =>
      'Sarà rimosso dalla tua schermata iniziale. Puoi aggiungerlo di nuovo in qualsiasi momento.';

  @override
  String removePeopleGroupReminders(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'I suoi $count promemoria saranno eliminati.',
      one: 'Il suo promemoria sarà eliminato.',
    );
    return '$_temp0';
  }

  @override
  String get stopPraying => 'Smetti di pregare';

  @override
  String get noPeopleGroupsForReminder =>
      'Scegli un gruppo etnico prima di impostare un promemoria.';

  @override
  String get reminderPeopleGroup => 'Gruppo etnico';

  @override
  String reminderNotificationBodyForGroup(String name) {
    return 'Apri DOXA per pregare per «$name».';
  }

  @override
  String nextReminderForGroup(String time, String name) {
    return '$time per «$name»';
  }

  @override
  String prayForNextGroup(String name) {
    return 'Prega per «$name»';
  }

  @override
  String switchToPeopleGroup(String name) {
    return 'Passa a «$name»';
  }

  @override
  String get map => 'Mappa';

  @override
  String mapOf(String name) {
    return 'Mappa di «$name»';
  }

  @override
  String get nearbyPeopleGroups => 'Gruppi etnici nelle vicinanze';

  @override
  String get recenter => 'Ricentra';

  @override
  String get mapUnavailableOffline =>
      'Immagini della mappa non disponibili offline';

  @override
  String get yourPeopleGroups => 'I tuoi gruppi etnici';

  @override
  String get locationNotAvailable => 'Posizione non disponibile';

  @override
  String get couldNotLoadMapMessage => 'Impossibile caricare la mappa.';
}
