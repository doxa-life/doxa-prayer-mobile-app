// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'DOXA Prayer';

  @override
  String get home => 'Inicio';

  @override
  String get pray => 'Orar';

  @override
  String get peopleGroups => 'Grupos étnicos';

  @override
  String nPeopleGroups(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grupos étnicos',
      one: '1 grupo étnico',
      zero: 'Sin grupos étnicos',
    );
    return '$_temp0';
  }

  @override
  String get searchPeopleGroups => 'Buscar grupos étnicos';

  @override
  String get profile => 'Perfil';

  @override
  String get reminders => 'Recordatorios';

  @override
  String get settings => 'Configuración';

  @override
  String get language => 'Idioma';

  @override
  String get retry => 'Volver a intentarlo';

  @override
  String get couldNotLoadPeopleGroupsMessage =>
      'No se han podido cargar los grupos étnicos.';

  @override
  String get selectPeopleGroup => 'Selecciona un grupo étnico';

  @override
  String get crossCulturalWorkersPresent => 'Obreros transculturales presentes';

  @override
  String get unselect => 'Deseleccionar';

  @override
  String get workInLocalLanguageAndCulture =>
      'Trabajar en el idioma y la cultura locales';

  @override
  String get discipleAndChurchMultiplication =>
      'Multiplicación de discípulos e iglesias';

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
  String get dailyPrayerCoverage => 'Cobertura de oración diaria';

  @override
  String get peopleGroup => 'Grupo étnico';

  @override
  String get couldNotLoadPeopleGroupDetailsMessage =>
      'No se han podido cargar los datos del grupo étnico.';

  @override
  String get share => 'Compartir';

  @override
  String get search => 'Buscar';

  @override
  String get country => 'País';

  @override
  String get alternateName => 'Nombre alternativo';

  @override
  String get population => 'Población';

  @override
  String get primaryLanguage => 'Idioma principal';

  @override
  String get primaryReligion => 'Religión principal';

  @override
  String get religiousPractices => 'Prácticas religiosas';

  @override
  String get setReminder => 'Configurar un recordatorio';

  @override
  String get pauseAndPray => 'Haz una pausa y ora';

  @override
  String get select => 'Seleccionar';

  @override
  String get selected => 'Seleccionado';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get partial => 'Parcial';

  @override
  String get status => 'Estado';

  @override
  String get engagementStatus => 'Estado del compromiso';

  @override
  String get engaged => 'Comprometido';

  @override
  String get adoptionStatus => 'Estado de la adopción';

  @override
  String get selectPeopleGroupConfirm =>
      '¿Quieres seleccionar este grupo étnico?';

  @override
  String switchPeopleGroupConfirm(String currentName, String newName) {
    return '¿Quieres dejar de orar por «$currentName» y empezar a orar por «$newName»?';
  }

  @override
  String get amen => 'Amén';

  @override
  String get noPeopleGroupSelected =>
      'Elige un grupo étnico por el que empezar a orar.';

  @override
  String get couldNotLoadPrayerContent =>
      'No se ha podido cargar el contenido de oración.';

  @override
  String get noPrayerContentAvailable => 'Hoy no hay contenido de oración.';

  @override
  String get prayerThankYouTitle => 'Gracias por orar';

  @override
  String get prayedToday => 'Hoy he orado';

  @override
  String get prayerReminderTitle => '¿Todo listo para la oración de hoy?';

  @override
  String prayerReminderBody(String peopleGroup) {
    return 'Toca para orar por «$peopleGroup».';
  }

  @override
  String get dismissReminderLabel => 'Descartar recordatorio';

  @override
  String prayForPeopleGroupLabel(String peopleGroup) {
    return 'Orar por «$peopleGroup»';
  }

  @override
  String get pictureCreditLabel => 'Crédito de la imagen';

  @override
  String get clearSearchLabel => 'Borrar búsqueda';

  @override
  String get forwardLabel => 'Adelante';

  @override
  String get prayerRecordedAnnouncement => 'Oración registrada';

  @override
  String prayingWithYou(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString personas orando contigo ahora',
      one: '1 persona orando contigo ahora',
    );
    return '$_temp0';
  }

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
  String get noDaysSelected => 'No se han seleccionado días';

  @override
  String get noRemindersYet => 'Aún no hay recordatorios';

  @override
  String get reminderNotificationTitle => 'Es hora de orar';

  @override
  String get reminderNotificationBody =>
      'Abre DOXA para comenzar la oración de hoy.';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get notificationsEnabledStatus =>
      'Las notificaciones están activadas. Recibirás tus recordatorios de oración.';

  @override
  String get notificationsDisabledStatus =>
      'Las notificaciones están desactivadas, por lo que no aparecerán los recordatorios de oración.';

  @override
  String get notificationsHowToEnable =>
      'Pulsa aquí abajo para abrir los ajustes y, a continuación, autoriza las notificaciones de DOXA.';

  @override
  String get exactAlarmsDisabledStatus =>
      'DOXA no tiene permiso para usar alarmas exactas, por lo que tus recordatorios de oración pueden llegar con varios minutos de retraso.';

  @override
  String get allowExactAlarms => 'Permitir alarmas exactas';

  @override
  String get exactAlarmsPromptBody =>
      'Para que tus recordatorios de oración lleguen justo a tiempo, permite que DOXA use alarmas exactas.';

  @override
  String get allow => 'Permitir';

  @override
  String get notNow => 'Ahora no';

  @override
  String get enableNotifications => 'Activar notificaciones';

  @override
  String get openSettings => 'Abrir ajustes';

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
      other: 'Hay $countString recordatorios configurados',
      one: 'Hay 1 recordatorio configurado',
      zero: 'No hay recordatorios configurados',
    );
    return '$_temp0';
  }

  @override
  String get wizardWelcomeTitle => 'Bienvenidos a DOXA Prayer';

  @override
  String get wizardWelcomeBody =>
      'DOXA te ayuda a orar por un grupo étnico no alcanzado. Te ayudaremos a elegir un grupo, a configurar un recordatorio y a mantenerte informado.';

  @override
  String get wizardGetStarted => 'Empezar';

  @override
  String get wizardChoosePeopleGroupTitle => 'Elige un grupo étnico';

  @override
  String wizardConfirmPeopleGroupTitle(String name) {
    return '¿Oramos por «$name»?';
  }

  @override
  String get wizardConfirmPeopleGroupBody =>
      'Te mostraremos contenidos de oración y recordatorios para este grupo. Puedes cambiarlo más adelante.';

  @override
  String get wizardSetReminderTitle => 'Configurar un recordatorio de oración';

  @override
  String get wizardSetReminderBody =>
      'Te enviaremos un pequeño recordatorio a la hora que elijas. Puedes saltarte este paso y añadir recordatorios más adelante.';

  @override
  String get wizardNewsSignupTitle => 'Mantente al día';

  @override
  String get wizardNewsSignupBody =>
      'Opcional. Recibe noticias sobre tu grupo étnico y novedades de DOXA.';

  @override
  String get back => 'Volver';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get skip => 'Omitir';

  @override
  String get finish => 'Finalizar';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get emailInvalid =>
      'Introduce una dirección de correo electrónico válida.';

  @override
  String get nameRequired => 'Introduce tu nombre, por favor.';

  @override
  String get updatesAboutMyPeopleGroup =>
      'Recibir noticias sobre mi grupo étnico';

  @override
  String get updatesFromDoxa => 'Recibe novedades de DOXA';

  @override
  String get signUpForUpdates => 'Suscríbete para recibir novedades';

  @override
  String get newsSignupSuccessTitle => '¡Gracias por registrarte!';

  @override
  String newsSignupSuccessBody(String email) {
    return 'Hemos enviado un correo de verificación a $email. Abre tu bandeja de entrada y toca el enlace para confirmar tu suscripción.';
  }

  @override
  String get newsSignupError =>
      'Ha surgido un problema. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get enableNotificationsPromptBody =>
      'Activa las notificaciones para recibir estas novedades también en tu móvil.';

  @override
  String get enableNotificationsButton => 'Activar notificaciones';

  @override
  String get accountSectionTitle => 'Tu cuenta';

  @override
  String get emailVerified => 'Verificado';

  @override
  String get emailUnverified => 'Sin verificar';

  @override
  String get resendVerification => 'Reenviar correo de verificación';

  @override
  String get resendVerificationSent =>
      'Correo de verificación enviado. Revisa tu bandeja de entrada.';

  @override
  String resendVerificationCooldown(int seconds) {
    return 'Espera $seconds s antes de solicitar otro correo.';
  }

  @override
  String resendVerificationCountdown(int seconds) {
    return 'Reenviar en $seconds s';
  }

  @override
  String get signUp => 'Registrarse';

  @override
  String get resendVerificationFailed =>
      'No se ha podido enviar el correo. Inténtalo de nuevo.';

  @override
  String get viewProfile => 'Ver perfil';

  @override
  String get emailsLoadError =>
      'No se han podido cargar tus direcciones de correo.';

  @override
  String get updateAvailableTitle => 'Hay una actualización disponible';

  @override
  String get updateAvailableBody =>
      'Ya está disponible una nueva versión de DOXA Prayer.';

  @override
  String get updateRequiredTitle => 'Se requiere una actualización';

  @override
  String get updateRequiredBody =>
      'Actualiza a la última versión para seguir utilizando DOXA Prayer.';

  @override
  String get updateAction => 'Actualizar';

  @override
  String get updateDismiss => 'Ahora no';

  @override
  String get feedback => 'Comentarios';

  @override
  String get feedbackIntro =>
      'Nos encantaría conocer tu opinión. Cuéntanos qué te parece la aplicación.';

  @override
  String get feedbackTypeLabel => '¿Qué tipo de comentario?';

  @override
  String get feedbackTypeCompliment => 'Elogio';

  @override
  String get feedbackTypeSuggestion => 'Sugerencia';

  @override
  String get feedbackTypeProblem => 'Problema';

  @override
  String get feedbackTypeRequired => 'Elige un tipo de comentario.';

  @override
  String get feedbackNameLabel => 'Nombre (opcional)';

  @override
  String get feedbackMessageLabel => 'Mensaje';

  @override
  String get feedbackMessageRequired => 'Introduce un mensaje.';

  @override
  String get feedbackConsentLabel => 'Mantenme al día de las novedades de DOXA';

  @override
  String get feedbackSubmit => 'Enviar comentarios';

  @override
  String get feedbackError =>
      'Ha surgido un problema. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get feedbackRateLimited =>
      'Has enviado muchos comentarios recientemente. Inténtalo de nuevo más tarde.';

  @override
  String get feedbackSuccessTitle => '¡Gracias!';

  @override
  String feedbackSuccessBody(String email) {
    return 'Tus comentarios se han enviado desde $email. Si esa no es la dirección correcta, vuelve a enviarlos con la correcta.';
  }

  @override
  String shareMessage(String name) {
    return 'Ora conmigo por los «$name»; descárgate la aplicación DOXA Prayer:';
  }

  @override
  String get shareLink => 'Compartir enlace';

  @override
  String scanToPray(String name) {
    return 'Escanea el código para descargar la aplicación y ora por los «$name»';
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
  String get dayInTheLifeTitle => 'Un día en la vida';

  @override
  String get myPeopleGroupTitle => 'Mi grupo étnico';

  @override
  String peopleGroupIntroTitle(String name) {
    return 'Ora por los «$name»';
  }

  @override
  String get peopleGroupOfTheDay => 'Grupo étnico del día';

  @override
  String get pressBackAgainToExit => 'Vuelve a pulsar para salir';

  @override
  String get notifications_enabled => 'Notificaciones activadas';

  @override
  String get notifications_disabled => 'Notificaciones desactivadas';

  @override
  String get cancel => 'Cancelar';

  @override
  String addPeopleGroupConfirm(String name) {
    return '¿Quieres empezar a orar por «$name»?';
  }

  @override
  String get choosePeopleGroup => 'Elegir un grupo étnico';

  @override
  String get addAnotherPeopleGroup => 'Añadir otro grupo étnico';

  @override
  String peopleGroupLimitTitle(num count) {
    return 'Estás orando por $count grupos étnicos';
  }

  @override
  String peopleGroupLimitBody(String name) {
    return 'Es el máximo por el que puedes orar a la vez. Para añadir «$name», elige uno por el que dejar de orar.';
  }

  @override
  String get swapPeopleGroupAction => 'Cambiar';

  @override
  String removePeopleGroupTitle(String name) {
    return '¿Dejar de orar por «$name»?';
  }

  @override
  String get removePeopleGroupBody =>
      'Desaparecerá de tu pantalla de inicio. Puedes volver a añadirlo cuando quieras.';

  @override
  String removePeopleGroupReminders(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se eliminarán sus $count recordatorios.',
      one: 'Se eliminará su recordatorio.',
    );
    return '$_temp0';
  }

  @override
  String get stopPraying => 'Dejar de orar';

  @override
  String get noPeopleGroupsForReminder =>
      'Elige un grupo étnico antes de configurar un recordatorio.';

  @override
  String get reminderPeopleGroup => 'Grupo étnico';

  @override
  String reminderNotificationBodyForGroup(String name) {
    return 'Abre DOXA para orar por «$name».';
  }

  @override
  String nextReminderForGroup(String time, String name) {
    return '$time por «$name»';
  }

  @override
  String prayForNextGroup(String name) {
    return 'Orar por «$name»';
  }

  @override
  String switchToPeopleGroup(String name) {
    return 'Cambiar a «$name»';
  }

  @override
  String get map => 'Mapa';

  @override
  String mapOf(String name) {
    return 'Mapa de «$name»';
  }

  @override
  String get nearbyPeopleGroups => 'Grupos étnicos cercanos';

  @override
  String get recenter => 'Centrar de nuevo';

  @override
  String get mapUnavailableOffline =>
      'Imágenes del mapa no disponibles sin conexión';

  @override
  String get yourPeopleGroups => 'Tus grupos étnicos';

  @override
  String get locationNotAvailable => 'Ubicación no disponible';

  @override
  String get couldNotLoadMapMessage => 'No se ha podido cargar el mapa.';
}
