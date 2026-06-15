// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Doxa Oração';

  @override
  String get home => 'Início';

  @override
  String get pray => 'Orar';

  @override
  String get peopleGroups => 'Grupos de Pessoas';

  @override
  String nPeopleGroups(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Grupos de Pessoas',
      one: '1 Grupo de Pessoas',
      zero: 'Sem Grupos de Pessoas',
    );
    return '$_temp0';
  }

  @override
  String get searchPeopleGroups => 'Buscar Grupos de Pessoas';

  @override
  String get profile => 'Perfil';

  @override
  String get reminders => 'Lembretes';

  @override
  String get settings => 'Configurações';

  @override
  String get language => 'Idioma';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get couldNotLoadPeopleGroupsMessage =>
      'Não foi possível carregar os grupos de pessoas.';

  @override
  String get selectPeopleGroup => 'Selecione um grupo étnico';

  @override
  String get crossCulturalWorkersPresent =>
      'Trabalhadores interculturais presentes';

  @override
  String get workInLocalLanguageAndCulture =>
      'Trabalho na língua e cultura locais';

  @override
  String get discipleAndChurchMultiplication =>
      'Multiplicação de discípulos e igrejas';

  @override
  String get resources => 'Recursos';

  @override
  String get bibleTranslation => 'Tradução da Bíblia';

  @override
  String get bibleStories => 'Histórias da Bíblia';

  @override
  String get jesusFilm => 'O Filme de Jesus';

  @override
  String get radioBroadcast => 'Transmissão de rádio';

  @override
  String get gospelRecordings => 'Gravações de gospel';

  @override
  String get audioScripture => 'Áudio da passagem bíblica';

  @override
  String get overview => 'Visão geral';

  @override
  String get prayerStatus => 'Estado da oração';

  @override
  String get peopleCommittedToPraying => 'Pessoas empenhadas em rezar';

  @override
  String get prayerCoverage24h => 'Cobertura de oração 24 horas por dia';

  @override
  String get peopleGroup => 'People Group';

  @override
  String get couldNotLoadPeopleGroupDetailsMessage =>
      'Could not load people group details.';

  @override
  String get share => 'Partilhar';

  @override
  String get search => 'Search';

  @override
  String get country => 'País';

  @override
  String get alternateName => 'Nome alternativo';

  @override
  String get population => 'População';

  @override
  String get primaryLanguage => 'Língua principal';

  @override
  String get primaryReligion => 'Religião principal';

  @override
  String get religiousPractices => 'Práticas religiosas';

  @override
  String get setReminder => 'Definir lembrete';

  @override
  String get pauseAndPray => 'Faz uma pausa e reza';

  @override
  String get select => 'Selecionar';

  @override
  String get selected => 'Selecionado';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String get status => 'Estado';

  @override
  String get engagementStatus => 'Estado civil';

  @override
  String get adoptionStatus => 'Estado da adoção';

  @override
  String get selectPeopleGroupConfirm =>
      'Você quer selecionar este grupo de pessoas?';

  @override
  String switchPeopleGroupConfirm(String currentName, String newName) {
    return 'Você quer parar de orar por $currentName e começar a orar por $newName?';
  }

  @override
  String get amen => 'Amém';

  @override
  String get noPeopleGroupSelected =>
      'Escolha um grupo de pessoas para começar a orar.';

  @override
  String get couldNotLoadPrayerContent =>
      'Não foi possível carregar o conteúdo de oração.';

  @override
  String get noPrayerContentAvailable => 'Sem conteúdo de oração para hoje.';

  @override
  String get prayerLogged => 'Sua oração foi registrada.';

  @override
  String get prayedToday => 'Orou hoje';

  @override
  String get couldNotLogPrayerSession =>
      'Não foi possível registrar sua sessão de oração.';

  @override
  String get newReminder => 'Novo lembrete';

  @override
  String get editReminder => 'Editar lembrete';

  @override
  String get save => 'Salvar';

  @override
  String get delete => 'Excluir';

  @override
  String get time => 'Hora';

  @override
  String get daysOfWeek => 'Dias da semana';

  @override
  String get everyDay => 'Todos os dias';

  @override
  String get noDaysSelected => 'Nenhum dia selecionado';

  @override
  String get noRemindersYet => 'Ainda não há lembretes';

  @override
  String get reminderNotificationTitle => 'Hora de orar';

  @override
  String get reminderNotificationBody =>
      'Abre o Doxa para começar a oração de hoje.';

  @override
  String get reminderPermissionDenied =>
      'As notificações estão desativadas; ativa-as nas definições do sistema para receber lembretes.';

  @override
  String get nextReminder => 'Próximo lembrete';

  @override
  String nextReminderToday(String time) {
    return 'Hoje às $time';
  }

  @override
  String nextReminderTomorrow(String time) {
    return 'Amanhã às $time';
  }

  @override
  String nextReminderOn(String weekday, String time) {
    return '$weekday às $time';
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
      other: '$countString lembretes ativos',
      one: '1 lembrete ativo',
      zero: 'Sem lembretes',
    );
    return '$_temp0';
  }

  @override
  String get dismissNextReminder => 'Descartar próximo';

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
    return 'Versão $version';
  }
}

/// The translations for Portuguese, as used in Portugal (`pt_PT`).
class AppLocalizationsPtPt extends AppLocalizationsPt {
  AppLocalizationsPtPt() : super('pt_PT');

  @override
  String get appName => 'nome da aplicação';

  @override
  String get home => 'início';

  @override
  String get pray => 'rezar';

  @override
  String get peopleGroups => 'Grupos étnicos';

  @override
  String nPeopleGroups(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Grupos de Pessoas',
      one: '1 Grupo de Pessoas',
      zero: 'Sem Grupos de Pessoas',
    );
    return '$_temp0';
  }

  @override
  String get searchPeopleGroups => 'Pesquisar Pessoas Grupos';

  @override
  String get profile => 'perfil';

  @override
  String get reminders => 'lembretes';

  @override
  String get settings => 'configurações';

  @override
  String get language => 'língua';

  @override
  String get retry => 'tentar novamente';

  @override
  String get couldNotLoadPeopleGroupsMessage =>
      'Mensagem de falha ao carregar grupos de pessoas';

  @override
  String get selectPeopleGroup => 'Selecione um grupo étnico';

  @override
  String get crossCulturalWorkersPresent =>
      'Trabalhadores interculturais presentes';

  @override
  String get workInLocalLanguageAndCulture =>
      'Trabalho na língua e cultura locais';

  @override
  String get discipleAndChurchMultiplication =>
      'Multiplicação de discípulos e igrejas';

  @override
  String get resources => 'Recursos';

  @override
  String get bibleTranslation => 'Tradução da Bíblia';

  @override
  String get bibleStories => 'Histórias da Bíblia';

  @override
  String get jesusFilm => 'Filme Jesus';

  @override
  String get radioBroadcast => 'Transmissão de rádio';

  @override
  String get gospelRecordings => 'Gravações do Evangelho';

  @override
  String get audioScripture => 'Áudio das Escrituras';

  @override
  String get overview => 'Visão geral';

  @override
  String get prayerStatus => 'Status de oração';

  @override
  String get peopleCommittedToPraying => 'Pessoas comprometidas com a oração';

  @override
  String get prayerCoverage24h => 'Cobertura de oração 24 horas por dia';

  @override
  String get share => 'Compartilhe';

  @override
  String get country => 'País';

  @override
  String get alternateName => 'Nome alternativo';

  @override
  String get population => 'Aplicação';

  @override
  String get primaryLanguage => 'Língua principal';

  @override
  String get primaryReligion => 'Religião Primária';

  @override
  String get religiousPractices => 'Práticas religiosas';

  @override
  String get setReminder => 'Definir lembrete';

  @override
  String get pauseAndPray => 'Faz uma pausa e reza';

  @override
  String get select => 'Selecionar';

  @override
  String get selected => 'Selecionado';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String get status => 'Estado';

  @override
  String get engagementStatus => 'Estado do noivado';

  @override
  String get adoptionStatus => 'Estado da adoção';

  @override
  String get selectPeopleGroupConfirm => 'Quer selecionar este grupo étnico?';

  @override
  String switchPeopleGroupConfirm(String currentName, String newName) {
    return 'Queres deixar de rezar por $currentName e começar a rezar por $newName?';
  }

  @override
  String get amen => 'Ámen';

  @override
  String get noPeopleGroupSelected =>
      'Escolha um grupo étnico para começar a orar.';

  @override
  String get couldNotLoadPrayerContent =>
      'Não foi possível carregar o conteúdo da oração.';

  @override
  String get noPrayerContentAvailable => 'Hoje não há texto de oração.';

  @override
  String get prayerLogged => 'A sua oração foi registada.';

  @override
  String get prayedToday => 'Orou hoje';

  @override
  String get couldNotLogPrayerSession =>
      'Não foi possível registar a sua sessão de oração.';

  @override
  String get newReminder => 'Novo lembrete';

  @override
  String get editReminder => 'Editar lembrete';

  @override
  String get save => 'Salve';

  @override
  String get delete => 'Excluir';

  @override
  String get time => 'Tempo';

  @override
  String get daysOfWeek => 'Dias da semana';

  @override
  String get everyDay => 'Diariamente';

  @override
  String get noDaysSelected => 'Não foram selecionados dias';

  @override
  String get noRemindersYet => 'Ainda não há lembretes';

  @override
  String get reminderNotificationTitle => 'É hora de rezar';

  @override
  String get reminderNotificationBody =>
      'Abra o Doxa para iniciar a oração de hoje.';

  @override
  String get reminderPermissionDenied =>
      'As notificações estão desativadas — ative-as nas definições do sistema para receber lembretes.';

  @override
  String get nextReminder => 'Próximo lembrete';

  @override
  String nextReminderToday(String time) {
    return 'Hoje em $time';
  }

  @override
  String nextReminderTomorrow(String time) {
    return 'Amanhã em $time';
  }

  @override
  String nextReminderOn(String weekday, String time) {
    return '$weekday em $time';
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
      other: 'Estão definidos ${countString}es de lembretes',
      one: '1 lembrete definido',
      zero: 'Não há lembretes definidos',
    );
    return '$_temp0';
  }

  @override
  String get dismissNextReminder => 'Ignorar o próximo';
}
