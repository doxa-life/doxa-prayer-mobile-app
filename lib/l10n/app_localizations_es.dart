// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Doxa Prayer';

  @override
  String get home => 'Inicio';

  @override
  String get pray => 'Orar';

  @override
  String get peopleGroups => 'Grupos de personas';

  @override
  String nPeopleGroups(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grupos de personas',
      one: '1 grupo de personas',
      zero: 'Sin grupos de personas',
    );
    return '$_temp0';
  }

  @override
  String get searchPeopleGroups => 'Buscar grupos de personas';

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
      'No se han podido cargar los grupos de personas.';

  @override
  String get selectPeopleGroup => 'Selecciona un grupo de personas';

  @override
  String get crossCulturalWorkersPresent => 'Obreros transculturales presentes';

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
  String get prayerCoverage24h => 'Cobertura en oración las 24 horas';

  @override
  String get peopleGroup => 'Grupo de personas';

  @override
  String get couldNotLoadPeopleGroupDetailsMessage =>
      'No se han podido cargar los datos del grupo de personas.';

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
  String get status => 'Estado';

  @override
  String get engagementStatus => 'Estado del compromiso';

  @override
  String get engaged => 'Comprometido';

  @override
  String get adoptionStatus => 'Estado de la adopción';

  @override
  String get selectPeopleGroupConfirm =>
      '¿Quieres seleccionar este grupo de personas?';

  @override
  String switchPeopleGroupConfirm(String currentName, String newName) {
    return '¿Quieres dejar de orar por $currentName y empezar a orar por $newName?';
  }

  @override
  String get amen => 'Amén';

  @override
  String get noPeopleGroupSelected =>
      'Elige un grupo de personas por el que empezar a orar.';

  @override
  String get couldNotLoadPrayerContent =>
      'No se ha podido cargar el contenido de oración.';

  @override
  String get noPrayerContentAvailable => 'Hoy no hay contenido de oración.';

  @override
  String get prayerThankYouTitle => 'Gracias por orar';

  @override
  String get prayerThankYouMessage =>
      'Tu constancia en la oración es importante. Dios te escucha, y tus oraciones marcan la diferencia.';

  @override
  String get prayerThankYouVerse =>
      'Estad siempre gozosos, orad sin cesar, dad gracias en todo, porque esta es la voluntad de Dios para con vosotros en Cristo Jesús.';

  @override
  String get prayerThankYouVerseReference => '1 Tesalonicenses 5:16-18';

  @override
  String get prayedToday => 'Hoy he orado';

  @override
  String get prayerReminderTitle => '¿Todo listo para orar hoy?';

  @override
  String prayerReminderBody(String peopleGroup) {
    return 'Toca para orar por $peopleGroup.';
  }

  @override
  String get dismissReminderLabel => 'Descartar recordatorio';

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
      'Abre Doxa para comenzar la oración de hoy.';

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
      'Pulsa aquí abajo para abrir los ajustes y, a continuación, autoriza las notificaciones de Doxa.';

  @override
  String get exactAlarmsDisabledStatus =>
      'Las alarmas exactas no están permitidas para Doxa, por lo que tus recordatorios de oración pueden llegar con varios minutos de retraso.';

  @override
  String get allowExactAlarms => 'Permitir alarmas exactas';

  @override
  String get exactAlarmsPromptBody =>
      'Para que tus recordatorios de oración lleguen justo a tiempo, permite que Doxa use alarmas exactas.';

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
  String get dismissNextReminder => 'Descartar siguiente';

  @override
  String get wizardWelcomeTitle => 'Bienvenidos a Doxa Prayer';

  @override
  String get wizardWelcomeBody =>
      'Doxa te ayuda a orar por un grupo de personas no alcanzado. Te ayudaremos a elegir un grupo, a configurar un recordatorio y a mantenerte informado.';

  @override
  String get wizardGetStarted => 'Empezar';

  @override
  String get wizardChoosePeopleGroupTitle => 'Elige un grupo de personas';

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
      'Opcional. Recibe noticias sobre tu grupo de personas y novedades de Doxa.';

  @override
  String get back => 'Volver';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get saveAndContinue => 'Guardar y continuar';

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
      'Recibir noticias sobre mi grupo de personas';

  @override
  String get updatesFromDoxa => 'Recibe novedades de Doxa';

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
      'Enable notifications to also receive updates in push notifications.';

  @override
  String get enableNotificationsButton => 'Enable notifications';

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
      'No se pudo enviar el correo. Inténtalo de nuevo.';

  @override
  String get viewProfile => 'Ver perfil';

  @override
  String get emailsLoadError => 'No se pudieron cargar tus correos.';

  @override
  String get updateAvailableTitle => 'Hay una actualización disponible';

  @override
  String get updateAvailableBody =>
      'Ya está disponible una nueva versión de Doxa Prayer.';

  @override
  String get updateRequiredTitle => 'Se requiere una actualización';

  @override
  String get updateRequiredBody =>
      'Actualiza a la última versión para seguir utilizando Doxa Prayer.';

  @override
  String get updateAction => 'Actualizar';

  @override
  String get updateDismiss => 'Ahora no';

  @override
  String get getInvolved => 'Involúcrate';

  @override
  String get donate => 'Donar';

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
  String get feedbackConsentLabel => 'Mantenme al día de las novedades de Doxa';

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
    return 'Tus comentarios se enviaron como $email. Si no es la dirección correcta, vuelve a enviarlos con la correcta.';
  }

  @override
  String shareMessage(String name) {
    return 'Ora conmigo por los «$name»; descárgate la aplicación Doxa Prayer:';
  }

  @override
  String get qrCode => 'Código QR';

  @override
  String scanToPray(String name) {
    return 'Escanea el código para descargar la aplicación y ora por los $name';
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
  String get myPeopleGroupTitle => 'Mi grupo de personas';

  @override
  String peopleGroupIntroTitle(String name) {
    return 'Ora por los «$name»';
  }

  @override
  String get peopleGroupOfTheDay => 'Grupo de personas del día';

  @override
  String get pressBackAgainToExit => 'Vuelve a pulsar para salir';

  @override
  String get notifications_enabled => 'Notificaciones activadas';

  @override
  String get notifications_disabled => 'Notificaciones desactivadas';
}
