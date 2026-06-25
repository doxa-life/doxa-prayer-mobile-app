// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'название приложения';

  @override
  String get home => 'Главная';

  @override
  String get pray => 'молиться';

  @override
  String get peopleGroups => 'этнические группы';

  @override
  String nPeopleGroups(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString групп людей',
      many: '$countString групп людей',
      few: '$countString группы людей',
      one: '1 группа людей',
      zero: 'Нет групп людей',
    );
    return '$_temp0';
  }

  @override
  String get searchPeopleGroups => 'поискЛюдиГруппы';

  @override
  String get profile => 'профиль';

  @override
  String get reminders => 'напоминания';

  @override
  String get settings => 'настройки';

  @override
  String get language => 'язык';

  @override
  String get retry => 'повторить попытку';

  @override
  String get couldNotLoadPeopleGroupsMessage =>
      'Не удалось загрузить сообщение о группах людей';

  @override
  String get selectPeopleGroup => 'Выберите этническую группу';

  @override
  String get crossCulturalWorkersPresent =>
      'Межкультурные работники присутствуют';

  @override
  String get workInLocalLanguageAndCulture =>
      'Работа с учетом особенностей местного языка и культуры';

  @override
  String get discipleAndChurchMultiplication =>
      'Распространение ученичества и рост церквей';

  @override
  String get resources => 'Ресурсы';

  @override
  String get bibleTranslation => 'Перевод Библии';

  @override
  String get bibleStories => 'Библейские истории';

  @override
  String get jesusFilm => 'Фильм «Иисус»';

  @override
  String get radioBroadcast => 'Радиопередача';

  @override
  String get gospelRecordings => 'Записи Евангелия';

  @override
  String get audioScripture => 'Аудио-Священное Писание';

  @override
  String get overview => 'Обзор';

  @override
  String get prayerStatus => 'Статус молитвы';

  @override
  String get peopleCommittedToPraying => 'Люди, посвятившие себя молитве';

  @override
  String get prayerCoverage24h => '24-часовая молитвенная поддержка';

  @override
  String get peopleGroup => 'People Group';

  @override
  String get couldNotLoadPeopleGroupDetailsMessage =>
      'Could not load people group details.';

  @override
  String get share => 'доля';

  @override
  String get search => 'Search';

  @override
  String get country => 'Страна';

  @override
  String get alternateName => 'Другое название';

  @override
  String get population => 'Население';

  @override
  String get primaryLanguage => 'Основной язык';

  @override
  String get primaryReligion => 'Основная религия';

  @override
  String get religiousPractices => 'Религиозные обряды';

  @override
  String get setReminder => 'Установить напоминание';

  @override
  String get pauseAndPray => 'Остановись и помолись';

  @override
  String get select => 'Выбрать';

  @override
  String get selected => 'Выбранные';

  @override
  String get yes => 'да';

  @override
  String get no => 'нет';

  @override
  String get status => 'Статус';

  @override
  String get engagementStatus => 'Статус взаимодействия';

  @override
  String get adoptionStatus => 'Статус принятия';

  @override
  String get selectPeopleGroupConfirm =>
      'Вы хотите выбрать эту этническую группу?';

  @override
  String switchPeopleGroupConfirm(String currentName, String newName) {
    return 'Хотите перестать молиться за сайт $currentName и начать молиться за сайт $newName?';
  }

  @override
  String get amen => 'Аминь';

  @override
  String get noPeopleGroupSelected =>
      'Выберите народ, за который вы хотите начать молиться.';

  @override
  String get couldNotLoadPrayerContent => 'Не удалось загрузить текст молитвы.';

  @override
  String get noPrayerContentAvailable => 'Сегодня молитвенного материала нет.';

  @override
  String get prayerThankYouTitle => 'Спасибо за молитву';

  @override
  String get prayerThankYouMessage =>
      'Ваша верность в молитве важна. Бог слышит вас, и ваши молитвы имеют значение.';

  @override
  String get prayerThankYouVerse =>
      'Всегда радуйтесь. Непрестанно молитесь. За всё благодарите: ибо такова о вас воля Божия во Христе Иисусе.';

  @override
  String get prayerThankYouVerseReference => '1 Фессалоникийцам 5:16-18';

  @override
  String get prayedToday => 'Помолились сегодня';

  @override
  String get newReminder => 'Новое напоминание';

  @override
  String get editReminder => 'Изменить напоминание';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get time => 'Время';

  @override
  String get daysOfWeek => 'Дни недели';

  @override
  String get everyDay => 'Каждый день';

  @override
  String get noDaysSelected => 'Дни не выбраны';

  @override
  String get noRemindersYet => 'Пока нет напоминаний';

  @override
  String get reminderNotificationTitle => 'Пора молиться';

  @override
  String get reminderNotificationBody =>
      'Откройте «Доксу», чтобы начать сегодняшнюю молитву.';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsEnabledStatus =>
      'Notifications are on. Your prayer reminders will be delivered.';

  @override
  String get notificationsDisabledStatus =>
      'Notifications are turned off, so your prayer reminders won\'t appear.';

  @override
  String get notificationsHowToEnable =>
      'Tap below to open settings, then allow notifications for Doxa.';

  @override
  String get enableNotifications => 'Enable notifications';

  @override
  String get openSettings => 'Open settings';

  @override
  String get nextReminder => 'Следующее напоминание';

  @override
  String nextReminderToday(String time) {
    return 'Сегодня на сайте $time';
  }

  @override
  String nextReminderTomorrow(String time) {
    return 'Завтра на сайте $time';
  }

  @override
  String nextReminderOn(String weekday, String time) {
    return '$weekday по адресу $time';
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
      other: 'Установлено $countStringо напоминаний',
      one: 'Установлено 1 напоминание',
      zero: 'Напоминания не установлены',
    );
    return '$_temp0';
  }

  @override
  String get dismissNextReminder => 'Закрыть следующее';

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
  String get emailInvalid => 'Please enter a valid email address.';

  @override
  String get nameRequired => 'Please enter your name.';

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
    return 'Version $version';
  }

  @override
  String get previousDay => 'Previous day';

  @override
  String get nextDay => 'Next day';

  @override
  String get dayInTheLifeTitle => 'Day in the Life';

  @override
  String get myPeopleGroupTitle => 'My People Group';

  @override
  String peopleGroupIntroTitle(String name) {
    return 'Pray for the $name';
  }

  @override
  String get peopleGroupOfTheDay => 'People Group of the Day';

  @override
  String get pressBackAgainToExit => 'Press back again to exit';

  @override
  String get notifications_enabled => 'Notifications enabled';

  @override
  String get notifications_disabled => 'Notifications disabled';
}
