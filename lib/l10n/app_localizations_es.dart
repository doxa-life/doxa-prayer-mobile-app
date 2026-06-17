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
  String get selectPeopleGroup => 'Selecciona un grupo étnico';

  @override
  String get crossCulturalWorkersPresent =>
      'Trabajadores transculturales presentes';

  @override
  String get workInLocalLanguageAndCulture =>
      'Trabajar en el idioma y la cultura locales';

  @override
  String get discipleAndChurchMultiplication =>
      'Multiplicación de discípulos y de iglesias';

  @override
  String get resources => 'Recursos';

  @override
  String get bibleTranslation => 'Traducción de la Biblia';

  @override
  String get bibleStories => 'Historias bíblicas';

  @override
  String get jesusFilm => 'La película de Jesús';

  @override
  String get radioBroadcast => 'Emisión de radio';

  @override
  String get gospelRecordings => 'Grabaciones de gospel';

  @override
  String get audioScripture => 'Escritura en audio';

  @override
  String get overview => 'Resumen';

  @override
  String get prayerStatus => 'Estado de la oración';

  @override
  String get peopleCommittedToPraying =>
      'Personas comprometidas con la oración';

  @override
  String get prayerCoverage24h => 'Cobertura de oración las 24 horas';

  @override
  String get peopleGroup => 'People Group';

  @override
  String get couldNotLoadPeopleGroupDetailsMessage =>
      'Could not load people group details.';

  @override
  String get share => 'Compartir';

  @override
  String get search => 'Search';

  @override
  String get country => 'País';

  @override
  String get alternateName => 'Nombre alternativo';

  @override
  String get population => 'Aplicación';

  @override
  String get primaryLanguage => 'Idioma principal';

  @override
  String get primaryReligion => 'Religión principal';

  @override
  String get religiousPractices => 'Prácticas religiosas';

  @override
  String get setReminder => 'Configurar un recordatorio';

  @override
  String get pauseAndPray => 'Haz una pausa y reza';

  @override
  String get select => 'Seleccionar';

  @override
  String get selected => 'Seleccionado';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get status => 'Estado';

  @override
  String get engagementStatus => 'Estado civil';

  @override
  String get adoptionStatus => 'Estado de la adopción';

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
  String get prayedToday => 'Orado hoy';

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

  @override
  String get reminderNotificationTitle => 'Hora de orar';

  @override
  String get reminderNotificationBody =>
      'Abre Doxa para iniciar la oración de hoy.';

  @override
  String get reminderPermissionDenied =>
      'Las notificaciones están desactivadas; actívalas en la configuración del sistema para recibir recordatorios.';

  @override
  String get nextReminder => 'Próximo recordatorio';

  @override
  String nextReminderToday(String time) {
    return 'Hoy a las $time';
  }

  @override
  String nextReminderTomorrow(String time) {
    return 'Mañana a las $time';
  }

  @override
  String nextReminderOn(String weekday, String time) {
    return '$weekday a las $time';
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
      other: '$countString recordatorios activos',
      one: '1 recordatorio activo',
      zero: 'Sin recordatorios',
    );
    return '$_temp0';
  }

  @override
  String get dismissNextReminder => 'Descartar siguiente';

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
    return 'Versión $version';
  }

  @override
  String get previousDay => 'Día anterior';

  @override
  String get nextDay => 'Día siguiente';

  @override
  String get dayInTheLifeTitle => 'Day in the Life';

  @override
  String get myPeopleGroupTitle => 'Mi Grupo de Personas';

  @override
  String peopleGroupIntroTitle(String name) {
    return 'Pray for the $name';
  }

  @override
  String get peopleGroupOfTheDay => 'People Group of the Day';

  @override
  String get pressBackAgainToExit => 'Pulsa de nuevo para salir';
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

  @override
  String get selectPeopleGroup => 'Selecciona un grupo étnico';

  @override
  String get crossCulturalWorkersPresent =>
      'Trabajadores interculturales presentes';

  @override
  String get workInLocalLanguageAndCulture =>
      'Trabajar en el idioma y la cultura locales';

  @override
  String get discipleAndChurchMultiplication =>
      'Multiplicación de discípulos y de iglesias';

  @override
  String get resources => 'Recursos';

  @override
  String get bibleTranslation => 'Traducción de la Biblia';

  @override
  String get bibleStories => 'Historias bíblicas';

  @override
  String get jesusFilm => 'Película sobre Jesús';

  @override
  String get radioBroadcast => 'Emisión de radio';

  @override
  String get gospelRecordings => 'Grabaciones del Evangelio';

  @override
  String get audioScripture => 'Escritura en audio';

  @override
  String get overview => 'Resumen';

  @override
  String get prayerStatus => 'Estado de la oración';

  @override
  String get peopleCommittedToPraying =>
      'Personas comprometidas con la oración';

  @override
  String get prayerCoverage24h => 'Cobertura de oración las 24 horas';

  @override
  String get share => 'Compartir';

  @override
  String get country => 'País';

  @override
  String get alternateName => 'Nombre alternativo';

  @override
  String get population => 'Población';

  @override
  String get primaryLanguage => 'Lenguaje principal';

  @override
  String get primaryReligion => 'Religión primaria';

  @override
  String get religiousPractices => 'Prácticas religiosas';

  @override
  String get setReminder => 'Configurar un recordatorio';

  @override
  String get pauseAndPray => 'Haz una pausa y reza';

  @override
  String get select => 'Seleccionar';

  @override
  String get selected => 'Seleccionado';

  @override
  String get yes => 'Si';

  @override
  String get no => 'No';

  @override
  String get status => 'Estado';

  @override
  String get engagementStatus => 'Estado del compromiso';

  @override
  String get adoptionStatus => 'Estado de la adopción';

  @override
  String get selectPeopleGroupConfirm =>
      '¿Quieres seleccionar este grupo étnico?';

  @override
  String switchPeopleGroupConfirm(String currentName, String newName) {
    return '¿Quieres dejar de rezar por $currentName y empezar a rezar por $newName?';
  }

  @override
  String get amen => 'Amén';

  @override
  String get noPeopleGroupSelected =>
      'Elige un grupo étnico por el que empezar a orar.';

  @override
  String get couldNotLoadPrayerContent =>
      'No se ha podido cargar el contenido de la oración.';

  @override
  String get noPrayerContentAvailable => 'Hoy no hay contenido de oración.';

  @override
  String get prayerLogged => 'Tu oración ha quedado registrada.';

  @override
  String get prayedToday => 'Orado hoy';

  @override
  String get couldNotLogPrayerSession =>
      'No se ha podido registrar tu sesión de oración.';

  @override
  String get newReminder => 'Nuevo recordatorio';

  @override
  String get editReminder => 'Editar recordatorio';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Borrar';

  @override
  String get time => 'Hora';

  @override
  String get daysOfWeek => 'Días de la semana';

  @override
  String get everyDay => 'Todos los días';

  @override
  String get noDaysSelected => 'No se han seleccionado días';

  @override
  String get noRemindersYet => 'Aún no hay recordatorios';

  @override
  String get reminderNotificationTitle => 'Es hora de rezar';

  @override
  String get reminderNotificationBody =>
      'Abre la Doxa para comenzar la oración de hoy.';

  @override
  String get reminderPermissionDenied =>
      'Las notificaciones están desactivadas; actívalas en los ajustes del sistema para recibir recordatorios.';

  @override
  String get nextReminder => 'Próximo recordatorio';

  @override
  String nextReminderToday(String time) {
    return 'Hoy en $time';
  }

  @override
  String nextReminderTomorrow(String time) {
    return 'Mañana en $time';
  }

  @override
  String nextReminderOn(String weekday, String time) {
    return '$weekday en $time';
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
      other: 'Hay ${countString}es recordatorios configurados',
      one: 'Hay 1 recordatorio configurado',
      zero: 'No hay recordatorios configurados',
    );
    return '$_temp0';
  }

  @override
  String get dismissNextReminder => 'Cerrar siguiente';
}
