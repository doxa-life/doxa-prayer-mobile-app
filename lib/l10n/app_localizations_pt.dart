// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Doxa Prayer';

  @override
  String get home => 'Início';

  @override
  String get pray => 'Orar';

  @override
  String get peopleGroups => 'Povos';

  @override
  String nPeopleGroups(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count povos',
      one: '1 povo',
      zero: 'Nenhum povo',
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
      'Trabalho na língua e cultura locais';

  @override
  String get discipleAndChurchMultiplication =>
      'Multiplicação de discípulos e igrejas';

  @override
  String get resources => 'Recursos';

  @override
  String get bibleTranslation => 'Tradução da Bíblia';

  @override
  String get bibleStories => 'Histórias bíblicas';

  @override
  String get jesusFilm => 'Filme Jesus';

  @override
  String get radioBroadcast => 'Transmissão de rádio';

  @override
  String get gospelRecordings => 'Gravações do evangelho';

  @override
  String get audioScripture => 'Áudio das Escrituras';

  @override
  String get overview => 'Visão geral';

  @override
  String get prayerStatus => 'Status de oração';

  @override
  String get peopleCommittedToPraying => 'Pessoas comprometidas a orar';

  @override
  String get prayerCoverage24h => 'Cobertura de oração de 24 horas';

  @override
  String get peopleGroup => 'Povo';

  @override
  String get couldNotLoadPeopleGroupDetailsMessage =>
      'Não foi possível carregar os detalhes do povo.';

  @override
  String get share => 'Compartilhar';

  @override
  String get search => 'Pesquisar';

  @override
  String get country => 'País';

  @override
  String get alternateName => 'Nome alternativo';

  @override
  String get population => 'População';

  @override
  String get primaryLanguage => 'Idioma principal';

  @override
  String get primaryReligion => 'Religião principal';

  @override
  String get religiousPractices => 'Práticas religiosas';

  @override
  String get setReminder => 'Definir lembrete';

  @override
  String get pauseAndPray => 'Pause e ore';

  @override
  String get select => 'Selecionar';

  @override
  String get selected => 'Selecionado';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String get status => 'Status';

  @override
  String get engagementStatus => 'Status de engajamento';

  @override
  String get engaged => 'Engajado';

  @override
  String get adoptionStatus => 'Status da adoção';

  @override
  String get selectPeopleGroupConfirm => 'Você quer selecionar este povo?';

  @override
  String switchPeopleGroupConfirm(String currentName, String newName) {
    return 'Você quer parar de orar por $currentName e começar a orar por $newName?';
  }

  @override
  String get amen => 'Amém';

  @override
  String get noPeopleGroupSelected => 'Escolha um povo para começar a orar.';

  @override
  String get couldNotLoadPrayerContent =>
      'Não foi possível carregar o conteúdo de oração.';

  @override
  String get noPrayerContentAvailable => 'Nenhum conteúdo de oração para hoje.';

  @override
  String get prayerThankYouTitle => 'Obrigado por orar';

  @override
  String get prayerThankYouMessage =>
      'Sua fidelidade na oração importa. Deus ouve você, e suas orações fazem a diferença.';

  @override
  String get prayerThankYouVerse =>
      'Regozijai-vos sempre. Orai sem cessar. Em tudo dai graças, porque esta é a vontade de Deus em Cristo Jesus para convosco.';

  @override
  String get prayerThankYouVerseReference => '1 Tessalonicenses 5:16-18';

  @override
  String get prayedToday => 'Orei hoje';

  @override
  String get prayerReminderTitle => 'Tudo pronto para orar hoje?';

  @override
  String prayerReminderBody(String peopleGroup) {
    return 'Toque para orar por $peopleGroup.';
  }

  @override
  String get dismissReminderLabel => 'Dispensar lembrete';

  @override
  String get newReminder => 'Novo lembrete';

  @override
  String get editReminder => 'Editar lembrete';

  @override
  String get save => 'Salvar';

  @override
  String get delete => 'Excluir';

  @override
  String get time => 'Horário';

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
      'Abra o Doxa para começar a oração de hoje.';

  @override
  String get notifications => 'Notificações';

  @override
  String get notificationsEnabledStatus =>
      'As notificações estão ativadas. Seus lembretes de oração serão entregues.';

  @override
  String get notificationsDisabledStatus =>
      'As notificações estão desativadas, então seus lembretes de oração não vão aparecer.';

  @override
  String get notificationsHowToEnable =>
      'Toque abaixo para abrir as configurações e permita as notificações do Doxa.';

  @override
  String get exactAlarmsDisabledStatus =>
      'Os alarmes exatos não são permitidos para o Doxa, então seus lembretes de oração podem chegar com alguns minutos de atraso.';

  @override
  String get allowExactAlarms => 'Permitir alarmes exatos';

  @override
  String get exactAlarmsPromptBody =>
      'Para que seus lembretes de oração cheguem na hora certa, permita que o Doxa use alarmes exatos.';

  @override
  String get allow => 'Permitir';

  @override
  String get notNow => 'Agora não';

  @override
  String get enableNotifications => 'Ativar notificações';

  @override
  String get openSettings => 'Abrir configurações';

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
      other: '$countString lembretes definidos',
      one: '1 lembrete definido',
      zero: 'Nenhum lembrete definido',
    );
    return '$_temp0';
  }

  @override
  String get dismissNextReminder => 'Dispensar o próximo';

  @override
  String get wizardWelcomeTitle => 'Bem-vindo ao Doxa Prayer';

  @override
  String get wizardWelcomeBody =>
      'A Doxa ajuda você a orar por um povo ainda não alcançado. Vamos ajudar você a escolher um povo, definir um lembrete e ficar por dentro.';

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
      'Vamos mostrar conteúdo de oração e lembretes para este povo. Você pode mudar isso depois.';

  @override
  String get wizardSetReminderTitle => 'Defina um lembrete de oração';

  @override
  String get wizardSetReminderBody =>
      'Vamos enviar um lembrete discreto no horário que você escolher. Você pode pular isto e adicionar lembretes depois.';

  @override
  String get wizardNewsSignupTitle => 'Fique por dentro';

  @override
  String get wizardNewsSignupBody =>
      'Opcional. Receba notícias sobre seu povo e novidades da Doxa.';

  @override
  String get back => 'Voltar';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get saveAndContinue => 'Salvar e continuar';

  @override
  String get skip => 'Pular';

  @override
  String get finish => 'Concluir';

  @override
  String get nameLabel => 'Nome';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get emailInvalid => 'Insira um endereço de e-mail válido.';

  @override
  String get nameRequired => 'Insira seu nome.';

  @override
  String get updatesAboutMyPeopleGroup => 'Receber novidades sobre meu povo';

  @override
  String get updatesFromDoxa => 'Receber novidades da Doxa';

  @override
  String get signUpForUpdates => 'Inscreva-se para receber novidades';

  @override
  String get newsSignupSuccessTitle => 'Obrigado por se inscrever!';

  @override
  String newsSignupSuccessBody(String email) {
    return 'Enviamos um e-mail de verificação para $email. Abra sua caixa de entrada e toque no link para confirmar sua inscrição.';
  }

  @override
  String get newsSignupError =>
      'Algo deu errado. Verifique sua conexão e tente novamente.';

  @override
  String get enableNotificationsPromptBody =>
      'Enable notifications to also receive updates in push notifications.';

  @override
  String get enableNotificationsButton => 'Enable notifications';

  @override
  String get accountSectionTitle => 'Sua conta';

  @override
  String get emailVerified => 'Verificado';

  @override
  String get emailUnverified => 'Não verificado';

  @override
  String get resendVerification => 'Reenviar e-mail de verificação';

  @override
  String get resendVerificationSent =>
      'E-mail de verificação enviado. Verifique sua caixa de entrada.';

  @override
  String resendVerificationCooldown(int seconds) {
    return 'Aguarde $seconds s antes de solicitar outro e-mail.';
  }

  @override
  String resendVerificationCountdown(int seconds) {
    return 'Reenviar em $seconds s';
  }

  @override
  String get signUp => 'Inscrever-se';

  @override
  String get resendVerificationFailed =>
      'Não foi possível enviar o e-mail. Tente novamente.';

  @override
  String get viewProfile => 'Ver perfil';

  @override
  String get emailsLoadError => 'Não foi possível carregar seus e-mails.';

  @override
  String get updateAvailableTitle => 'Atualização disponível';

  @override
  String get updateAvailableBody =>
      'Uma nova versão do Doxa Prayer está disponível.';

  @override
  String get updateRequiredTitle => 'Atualização necessária';

  @override
  String get updateRequiredBody =>
      'Atualize para a versão mais recente para continuar usando o Doxa Prayer.';

  @override
  String get updateAction => 'Atualizar';

  @override
  String get updateDismiss => 'Agora não';

  @override
  String get getInvolved => 'Participe';

  @override
  String get donate => 'Doar';

  @override
  String get feedback => 'Comentários';

  @override
  String get feedbackIntro =>
      'Adoraríamos ouvir você. Conte-nos o que acha do aplicativo.';

  @override
  String get feedbackTypeLabel => 'Que tipo de comentário?';

  @override
  String get feedbackTypeCompliment => 'Elogio';

  @override
  String get feedbackTypeSuggestion => 'Sugestão';

  @override
  String get feedbackTypeProblem => 'Problema';

  @override
  String get feedbackTypeRequired => 'Escolha um tipo de comentário.';

  @override
  String get feedbackNameLabel => 'Nome (opcional)';

  @override
  String get feedbackMessageLabel => 'Mensagem';

  @override
  String get feedbackMessageRequired => 'Insira uma mensagem.';

  @override
  String get feedbackConsentLabel =>
      'Mantenha-me atualizado com as novidades da Doxa';

  @override
  String get feedbackSubmit => 'Enviar comentários';

  @override
  String get feedbackError =>
      'Algo deu errado. Verifique sua conexão e tente novamente.';

  @override
  String get feedbackRateLimited =>
      'Você enviou muitos comentários recentemente. Tente novamente mais tarde.';

  @override
  String get feedbackSuccessTitle => 'Obrigado!';

  @override
  String feedbackSuccessBody(String email) {
    return 'Seus comentários foram enviados como $email. Se não for o endereço correto, envie-os novamente com o endereço certo.';
  }

  @override
  String shareMessage(String name) {
    return 'Ore comigo por $name — baixe o aplicativo Doxa Prayer:';
  }

  @override
  String get qrCode => 'Código QR';

  @override
  String scanToPray(String name) {
    return 'Escaneie o código para baixar o aplicativo e orar por $name';
  }

  @override
  String appVersion(String version) {
    return 'Versão $version';
  }

  @override
  String get previousDay => 'Dia anterior';

  @override
  String get nextDay => 'Próximo dia';

  @override
  String get dayInTheLifeTitle => 'Um dia na vida';

  @override
  String get myPeopleGroupTitle => 'Meu povo';

  @override
  String peopleGroupIntroTitle(String name) {
    return 'Ore por $name';
  }

  @override
  String get peopleGroupOfTheDay => 'Povo do dia';

  @override
  String get pressBackAgainToExit => 'Pressione voltar novamente para sair';

  @override
  String get notifications_enabled => 'Notificações ativadas';

  @override
  String get notifications_disabled => 'Notificações desativadas';
}
