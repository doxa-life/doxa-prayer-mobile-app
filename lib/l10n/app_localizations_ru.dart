// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Doxa Молитва';

  @override
  String get home => 'Главная';

  @override
  String get pray => 'Молиться';

  @override
  String get peopleGroups => 'Группы людей';

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
  String get searchPeopleGroups => 'Поиск групп людей';

  @override
  String get profile => 'Профиль';

  @override
  String get reminders => 'Напоминания';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get retry => 'Повторить';

  @override
  String get couldNotLoadPeopleGroupsMessage =>
      'Не удалось загрузить группы людей.';

  @override
  String get selectPeopleGroup => 'Select a people group';

  @override
  String get selectReminders => 'Select reminders';

  @override
  String get pauseAndPray => 'Pause & Pray';

  @override
  String get select => 'Выбрать';

  @override
  String get selected => 'Выбрано';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get selectPeopleGroupConfirm => 'Вы хотите выбрать эту группу людей?';

  @override
  String switchPeopleGroupConfirm(String currentName, String newName) {
    return 'Вы хотите перестать молиться за $currentName и начать молиться за $newName?';
  }

  @override
  String get amen => 'Аминь';

  @override
  String get noPeopleGroupSelected =>
      'Выберите группу людей, чтобы начать молиться.';

  @override
  String get couldNotLoadPrayerContent =>
      'Не удалось загрузить молитвенный материал.';

  @override
  String get noPrayerContentAvailable => 'Сегодня нет молитвенного материала.';

  @override
  String get prayerLogged => 'Ваша молитва записана.';

  @override
  String get couldNotLogPrayerSession =>
      'Не удалось записать вашу молитвенную сессию.';

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
}

/// The translations for Russian, as used in Russian Federation (`ru_RU`).
class AppLocalizationsRuRu extends AppLocalizationsRu {
  AppLocalizationsRuRu() : super('ru_RU');

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
}
