// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Doxa Prayer';

  @override
  String get home => 'Главная';

  @override
  String get pray => 'Молитесь';

  @override
  String get peopleGroups => 'Народы';

  @override
  String nPeopleGroups(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString народов',
      one: '1 народ',
      zero: 'Нет народов',
    );
    return '$_temp0';
  }

  @override
  String get searchPeopleGroups => 'Поиск народов';

  @override
  String get profile => 'Профиль';

  @override
  String get reminders => 'Напоминания';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get retry => 'Повторить попытку';

  @override
  String get couldNotLoadPeopleGroupsMessage => 'Не удалось загрузить народы.';

  @override
  String get selectPeopleGroup => 'Выберите народ';

  @override
  String get crossCulturalWorkersPresent =>
      'Межкультурные служители присутствуют';

  @override
  String get workInLocalLanguageAndCulture =>
      'Работа на родном языке и в местной культуре';

  @override
  String get discipleAndChurchMultiplication => 'Умножение учеников и церквей';

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
  String get audioScripture => 'Аудиозапись Писания';

  @override
  String get overview => 'Обзор';

  @override
  String get prayerStatus => 'Статус молитвы';

  @override
  String get peopleCommittedToPraying => 'Люди, обязавшиеся молиться';

  @override
  String get prayerCoverage24h => '24-часовой молитвенный охват';

  @override
  String get peopleGroup => 'Народ';

  @override
  String get couldNotLoadPeopleGroupDetailsMessage =>
      'Не удалось загрузить сведения о народе.';

  @override
  String get share => 'Поделиться';

  @override
  String get search => 'Поиск';

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
  String get pauseAndPray => 'Остановитесь и помолитесь';

  @override
  String get select => 'Выбрать';

  @override
  String get selected => 'Выбрано';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get status => 'Статус';

  @override
  String get engagementStatus => 'Статус вовлечения';

  @override
  String get adoptionStatus => 'Статус принятия';

  @override
  String get selectPeopleGroupConfirm => 'Вы хотите выбрать этот народ?';

  @override
  String switchPeopleGroupConfirm(String currentName, String newName) {
    return 'Хотите перестать молиться за народ «$currentName» и начать молиться за народ «$newName»?';
  }

  @override
  String get amen => 'Аминь';

  @override
  String get noPeopleGroupSelected =>
      'Выберите народ, за который хотите начать молиться.';

  @override
  String get couldNotLoadPrayerContent =>
      'Не удалось загрузить молитвенные материалы.';

  @override
  String get noPrayerContentAvailable =>
      'На сегодня молитвенного материала нет.';

  @override
  String get prayerThankYouTitle => 'Спасибо за ваши молитвы';

  @override
  String get prayerThankYouMessage =>
      'Ваша верность в молитве имеет большое значение. Бог слышит вас, и ваши молитвы приносят результаты.';

  @override
  String get prayerThankYouVerse =>
      'Всегда радуйтесь, непрестанно молитесь, за все благодарите; ибо такова воля Божья для вас во Христе Иисусе.';

  @override
  String get prayerThankYouVerseReference => '1 Фессалоникийцам 5:16–18';

  @override
  String get prayedToday => 'Помолились сегодня';

  @override
  String get newReminder => 'Новое напоминание';

  @override
  String get editReminder => 'Редактировать напоминание';

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
      'Откройте Doxa, чтобы начать сегодняшнюю молитву.';

  @override
  String get notifications => 'Уведомления';

  @override
  String get notificationsEnabledStatus =>
      'Уведомления включены. Вы будете получать напоминания о молитвах.';

  @override
  String get notificationsDisabledStatus =>
      'Уведомления отключены, поэтому напоминания о молитвах не будут отображаться.';

  @override
  String get notificationsHowToEnable =>
      'Нажмите ниже, чтобы открыть настройки, а затем разрешите получение уведомлений от Doxa.';

  @override
  String get enableNotifications => 'Включить уведомления';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get nextReminder => 'Следующее напоминание';

  @override
  String nextReminderToday(String time) {
    return 'Сегодня в $time';
  }

  @override
  String nextReminderTomorrow(String time) {
    return 'Завтра в $time';
  }

  @override
  String nextReminderOn(String weekday, String time) {
    return '$weekday в $time';
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
      other: 'Установлено $countString напоминаний',
      one: 'Установлено 1 напоминание',
      zero: 'Напоминаний не установлено',
    );
    return '$_temp0';
  }

  @override
  String get dismissNextReminder => 'Отклонить следующее';

  @override
  String get wizardWelcomeTitle => 'Добро пожаловать в «Doxa Prayer»';

  @override
  String get wizardWelcomeBody =>
      'Doxa поможет вам молиться за недостигнутый народ. Мы поможем вам выбрать народ, настроить напоминание и оставаться в курсе событий.';

  @override
  String get wizardGetStarted => 'Начать работу';

  @override
  String get wizardChoosePeopleGroupTitle => 'Выберите народ';

  @override
  String wizardConfirmPeopleGroupTitle(String name) {
    return 'Помолиться за «$name»?';
  }

  @override
  String get wizardConfirmPeopleGroupBody =>
      'Мы покажем вам молитвенные материалы и напоминания для этого народа. Вы сможете изменить эти настройки позже.';

  @override
  String get wizardSetReminderTitle => 'Установить напоминание о молитве';

  @override
  String get wizardSetReminderBody =>
      'Мы отправим вам небольшое напоминание в выбранное вами время. Вы можете пропустить этот шаг и добавить напоминания позже.';

  @override
  String get wizardNewsSignupTitle => 'Будьте в курсе событий';

  @override
  String get wizardNewsSignupBody =>
      'Необязательно. Получайте новости о вашем народе и обновления от Doxa.';

  @override
  String get back => 'Назад';

  @override
  String get continueLabel => 'Продолжить';

  @override
  String get saveAndContinue => 'Сохранить и продолжить';

  @override
  String get skip => 'Пропустить';

  @override
  String get finish => 'Завершить';

  @override
  String get nameLabel => 'Имя';

  @override
  String get emailLabel => 'Электронная почта';

  @override
  String get emailInvalid =>
      'Пожалуйста, введите действительный адрес электронной почты.';

  @override
  String get nameRequired => 'Пожалуйста, введите своё имя.';

  @override
  String get updatesAboutMyPeopleGroup => 'Получайте новости о моём народе';

  @override
  String get updatesFromDoxa => 'Получайте новости от Doxa';

  @override
  String get signUpForUpdates => 'Подпишитесь на новости';

  @override
  String get newsSignupThanks => 'Спасибо — вы подписаны.';

  @override
  String get newsSignupError =>
      'Произошла ошибка. Проверьте подключение и попробуйте ещё раз.';

  @override
  String get updateAvailableTitle => 'Доступно обновление';

  @override
  String get updateAvailableBody =>
      'Вышла новая версия приложения «Doxa Prayer».';

  @override
  String get updateRequiredTitle => 'Требуется обновление';

  @override
  String get updateRequiredBody =>
      'Пожалуйста, обновите приложение до последней версии, чтобы продолжить пользоваться Doxa Prayer.';

  @override
  String get updateAction => 'Обновить';

  @override
  String get updateDismiss => 'Не сейчас';

  @override
  String get getInvolved => 'Присоединяйтесь';

  @override
  String get donate => 'Сделать пожертвование';

  @override
  String get feedback => 'Отзывы';

  @override
  String shareMessage(String name) {
    return 'Помолитесь вместе со мной за «$name» — скачайте приложение «Doxa Prayer»:';
  }

  @override
  String get qrCode => 'QR-код';

  @override
  String scanToPray(String name) {
    return 'Отсканируйте QR-код, чтобы установить приложение, и помолитесь за $name';
  }

  @override
  String appVersion(String version) {
    return 'Версия$version';
  }

  @override
  String get previousDay => 'Предыдущий день';

  @override
  String get nextDay => 'Следующий день';

  @override
  String get dayInTheLifeTitle => 'Один день из жизни';

  @override
  String get myPeopleGroupTitle => 'Мой народ';

  @override
  String peopleGroupIntroTitle(String name) {
    return 'Помолитесь за народ «$name»';
  }

  @override
  String get peopleGroupOfTheDay => 'Народ дня';

  @override
  String get pressBackAgainToExit => 'Нажмите «Назад» ещё раз, чтобы выйти';

  @override
  String get notifications_enabled => 'Уведомления включены';

  @override
  String get notifications_disabled => 'Уведомления отключены';
}
