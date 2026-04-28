// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Doxa Oración';

  @override
  String get home => 'Inicio';

  @override
  String get pray => 'Orar';

  @override
  String get peopleGroups => 'Grupos de Personas';

  @override
  String nPeopleGroups(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Grupos de Personas',
      one: '1 Grupo de Personas',
      zero: 'Sin Grupos de Personas',
    );
    return '$_temp0';
  }

  @override
  String get searchPeopleGroups => 'Buscar Grupos de Personas';

  @override
  String get profile => 'Perfil';

  @override
  String get reminders => 'Recordatorios';

  @override
  String get settings => 'Ajustes';

  @override
  String get language => 'Idioma';

  @override
  String get retry => 'Reintentar';

  @override
  String get couldNotLoadPeopleGroupsMessage =>
      'No se pudieron cargar los grupos de personas.';

  @override
  String get selectPeopleGroup => 'Select a people group';

  @override
  String get selectReminders => 'Select reminders';

  @override
  String get pauseAndPray => 'Pause & Pray';

  @override
  String get select => 'Seleccionar';

  @override
  String get selected => 'Seleccionado';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get selectPeopleGroupConfirm =>
      '¿Quieres seleccionar este grupo de personas?';

  @override
  String switchPeopleGroupConfirm(String currentName, String newName) {
    return '¿Quieres dejar de orar por $currentName y comenzar a orar por $newName?';
  }

  @override
  String get amen => 'Amén';

  @override
  String get noPeopleGroupSelected =>
      'Elige un grupo de personas para empezar a orar.';

  @override
  String get couldNotLoadPrayerContent =>
      'No se pudo cargar el contenido de oración.';

  @override
  String get noPrayerContentAvailable =>
      'No hay contenido de oración para hoy.';

  @override
  String get prayerLogged => 'Tu oración ha sido registrada.';

  @override
  String get couldNotLogPrayerSession =>
      'No se pudo registrar tu sesión de oración.';

  @override
  String get newReminder => 'Nuevo recordatorio';

  @override
  String get editReminder => 'Editar recordatorio';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get time => 'Hora';

  @override
  String get daysOfWeek => 'Días de la semana';

  @override
  String get everyDay => 'Todos los días';

  @override
  String get noDaysSelected => 'Ningún día seleccionado';

  @override
  String get noRemindersYet => 'Aún no hay recordatorios';
}

/// The translations for Spanish Castilian, as used in Spain (`es_ES`).
class AppLocalizationsEsEs extends AppLocalizationsEs {
  AppLocalizationsEsEs() : super('es_ES');

  @override
  String get appName => 'nombreDeLaAplicación';

  @override
  String get home => 'Inicio';

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
      other: '$countString Grupos de Personas',
      one: '1 Grupo de Personas',
      zero: 'Sin Grupos de Personas',
    );
    return '$_temp0';
  }

  @override
  String get searchPeopleGroups => 'Buscar personas y grupos';

  @override
  String get profile => 'perfil';

  @override
  String get reminders => 'recordatorios';

  @override
  String get settings => 'configuración';

  @override
  String get language => 'idioma';

  @override
  String get retry => 'reintentar';

  @override
  String get couldNotLoadPeopleGroupsMessage =>
      'No se ha podido cargar el mensaje de los grupos de personas';
}
