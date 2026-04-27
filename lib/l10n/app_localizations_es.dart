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
