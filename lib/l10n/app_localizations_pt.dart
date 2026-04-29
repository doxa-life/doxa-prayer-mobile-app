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
  String get setReminder => 'Set reminder';

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
  String get couldNotLogPrayerSession =>
      'Não foi possível registar a sua sessão de oração.';
}
