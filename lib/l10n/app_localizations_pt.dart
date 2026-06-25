// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Oração da Doxa';

  @override
  String get home => 'Início';

  @override
  String get pray => 'Ore';

  @override
  String get peopleGroups => 'Povos';

  @override
  String nPeopleGroups(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString povos',
      one: '1 povo',
      zero: 'Sem povos',
    );
    return '$_temp0';
  }

  @override
  String get searchPeopleGroups => 'Pesquisar povos';

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
      'Não foi possível carregar os povos.';

  @override
  String get selectPeopleGroup => 'Selecione um povo';

  @override
  String get crossCulturalWorkersPresent => 'Obreiros transculturais presentes';

  @override
  String get workInLocalLanguageAndCulture =>
      'Trabalhar na língua e cultura locais';

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
  String get radioBroadcast => 'Emissão de rádio';

  @override
  String get gospelRecordings => 'Gravações do Evangelho';

  @override
  String get audioScripture => 'Áudio das Escrituras';

  @override
  String get overview => 'Visão geral';

  @override
  String get prayerStatus => 'Estado da oração';

  @override
  String get peopleCommittedToPraying => 'Pessoas comprometidas com a oração';

  @override
  String get prayerCoverage24h => 'Cobertura de oração de 24 horas';

  @override
  String get peopleGroup => 'Povo';

  @override
  String get couldNotLoadPeopleGroupDetailsMessage =>
      'Não foi possível carregar os detalhes do povo.';

  @override
  String get share => 'Partilhar';

  @override
  String get search => 'Pesquisar';

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
  String get pauseAndPray => 'Fazer uma pausa e orar';

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
  String get engagementStatus => 'Estado do engajamento';

  @override
  String get adoptionStatus => 'Estado da adoção';

  @override
  String get selectPeopleGroupConfirm => 'Quer selecionar este povo?';

  @override
  String switchPeopleGroupConfirm(String currentName, String newName) {
    return 'Queres deixar de orar por $currentName e começar a orar por $newName?';
  }

  @override
  String get amen => 'Ámen';

  @override
  String get noPeopleGroupSelected => 'Escolha um povo para começar a orar.';

  @override
  String get couldNotLoadPrayerContent =>
      'Não foi possível carregar o conteúdo da oração.';

  @override
  String get noPrayerContentAvailable => 'Hoje não há texto de oração.';

  @override
  String get prayerThankYouTitle => 'Obrigado pelas vossas orações';

  @override
  String get prayerThankYouMessage =>
      'A tua fidelidade na oração é importante. Deus ouve-te e as tuas orações fazem a diferença.';

  @override
  String get prayerThankYouVerse =>
      'Alegrai-vos sempre, orai sem cessar, dai graças em todas as circunstâncias; pois esta é a vontade de Deus para vós em Cristo Jesus.';

  @override
  String get prayerThankYouVerseReference => '1 Tessalonicenses 5:16-18';

  @override
  String get prayedToday => 'Orei hoje';

  @override
  String get newReminder => 'Novo lembrete';

  @override
  String get editReminder => 'Editar lembrete';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Apagar';

  @override
  String get time => 'Hora';

  @override
  String get daysOfWeek => 'Dias da semana';

  @override
  String get everyDay => 'Todos os dias';

  @override
  String get noDaysSelected => 'Não foram selecionados dias';

  @override
  String get noRemindersYet => 'Ainda não há lembretes';

  @override
  String get reminderNotificationTitle => 'Está na hora de rezar';

  @override
  String get reminderNotificationBody =>
      'Abre o Doxa para dar início à oração de hoje.';

  @override
  String get notifications => 'Notificações';

  @override
  String get notificationsEnabledStatus =>
      'As notificações estão ativadas. Os teus lembretes de oração serão enviados.';

  @override
  String get notificationsDisabledStatus =>
      'As notificações estão desativadas, pelo que os teus lembretes de oração não irão aparecer.';

  @override
  String get notificationsHowToEnable =>
      'Toque abaixo para abrir as definições e, em seguida, autorize as notificações do Doxa.';

  @override
  String get enableNotifications => 'Ativar notificações';

  @override
  String get openSettings => 'Abrir definições';

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
      other: '$countString lembretes definidos',
      one: '1 lembrete definido',
      zero: 'Não há lembretes definidos',
    );
    return '$_temp0';
  }

  @override
  String get dismissNextReminder => 'Ignorar o seguinte';

  @override
  String get wizardWelcomeTitle => 'Bem-vindo à Doxa Prayer';

  @override
  String get wizardWelcomeBody =>
      'A Doxa ajuda-te a orar por um povo ainda não alcançado. Vamos ajudar-te a escolher um povo, a definir um lembrete e a manter-te a par das novidades.';

  @override
  String get wizardGetStarted => 'Começar';

  @override
  String get wizardChoosePeopleGroupTitle => 'Escolha um povo';

  @override
  String wizardConfirmPeopleGroupTitle(String name) {
    return 'Orar por $name?';
  }

  @override
  String get wizardConfirmPeopleGroupBody =>
      'Vamos mostrar-lhe conteúdos de oração e lembretes para este povo. Pode alterar isto mais tarde.';

  @override
  String get wizardSetReminderTitle => 'Definir um lembrete de oração';

  @override
  String get wizardSetReminderBody =>
      'Vamos enviar-lhe um lembrete discreto na hora que escolher. Pode ignorar isto e adicionar lembretes mais tarde.';

  @override
  String get wizardNewsSignupTitle => 'Mantenha-se a par das novidades';

  @override
  String get wizardNewsSignupBody =>
      'Opcional. Receba notícias sobre o seu grupo étnico e atualizações da Doxa.';

  @override
  String get back => 'Voltar';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get saveAndContinue => 'Guardar e continuar';

  @override
  String get skip => 'Ignorar';

  @override
  String get finish => 'Concluir';

  @override
  String get nameLabel => 'Nome';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get emailInvalid => 'Introduza um endereço de e-mail válido.';

  @override
  String get nameRequired => 'Por favor, introduza o seu nome.';

  @override
  String get updatesAboutMyPeopleGroup =>
      'Receber atualizações sobre o meu povo';

  @override
  String get updatesFromDoxa => 'Receba atualizações da Doxa';

  @override
  String get signUpForUpdates => 'Inscreva-se para receber atualizações';

  @override
  String get newsSignupThanks => 'Obrigado — já estás inscrito.';

  @override
  String get newsSignupError =>
      'Ocorreu um erro. Verifique a sua ligação e tente novamente.';

  @override
  String get updateAvailableTitle => 'Atualização disponível';

  @override
  String get updateAvailableBody =>
      'Está disponível uma nova versão do Doxa Prayer.';

  @override
  String get updateRequiredTitle => 'É necessária uma atualização';

  @override
  String get updateRequiredBody =>
      'Por favor, atualize para a versão mais recente para continuar a utilizar o Doxa Prayer.';

  @override
  String get updateAction => 'Atualização';

  @override
  String get updateDismiss => 'Agora não';

  @override
  String get getInvolved => 'Participe';

  @override
  String get donate => 'Fazer um donativo';

  @override
  String get feedback => 'Comentários';

  @override
  String shareMessage(String name) {
    return 'Orem comigo pela «$name» — descarreguem a aplicação Doxa Prayer:';
  }

  @override
  String get qrCode => 'Código QR';

  @override
  String scanToPray(String name) {
    return 'Digitaliza o código para descarregar a aplicação e ora pela $name';
  }

  @override
  String appVersion(String version) {
    return 'Versão$version';
  }

  @override
  String get previousDay => 'Dia anterior';

  @override
  String get nextDay => 'No dia seguinte';

  @override
  String get dayInTheLifeTitle => 'Um dia na vida';

  @override
  String get myPeopleGroupTitle => 'O meu povo';

  @override
  String peopleGroupIntroTitle(String name) {
    return 'Orem pela «$name»';
  }

  @override
  String get peopleGroupOfTheDay => 'Povo do dia';

  @override
  String get pressBackAgainToExit => 'Prima «Voltar» novamente para sair';

  @override
  String get notifications_enabled => 'Notificações ativadas';

  @override
  String get notifications_disabled => 'Notificações desativadas';
}
