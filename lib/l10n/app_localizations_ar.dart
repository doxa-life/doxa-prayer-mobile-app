// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'اسم التطبيق';

  @override
  String get home => 'الصفحة الرئيسية';

  @override
  String get pray => 'صلي';

  @override
  String get peopleGroups => 'المجموعات العرقية';

  @override
  String nPeopleGroups(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString People Groups',
      one: '1 People Group',
      zero: 'No People Groups',
    );
    return '$_temp0';
  }

  @override
  String get searchPeopleGroups => 'البحث عن الأشخاص والمجموعات';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get reminders => 'تذكيرات';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get couldNotLoadPeopleGroupsMessage =>
      'تعذر تحميل رسالة مجموعات الأشخاص';

  @override
  String get selectPeopleGroup => 'اختر مجموعة عرقية';

  @override
  String get selectReminders => 'Select reminders';

  @override
  String get pauseAndPray => 'توقف وصلي';

  @override
  String get select => 'اختيار';

  @override
  String get selected => 'تم الاختيار';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get selectPeopleGroupConfirm => 'هل تريد اختيار هذه المجموعة العرقية؟';

  @override
  String switchPeopleGroupConfirm(String currentName, String newName) {
    return 'هل تريد التوقف عن الصلاة لـ $currentName والبدء في الصلاة لـ $newName؟';
  }

  @override
  String get amen => 'آمين';

  @override
  String get noPeopleGroupSelected => 'اختر مجموعة عرقية لتبدأ الصلاة.';

  @override
  String get couldNotLoadPrayerContent => 'تعذر تحميل محتوى الصلاة.';

  @override
  String get noPrayerContentAvailable => 'لا يوجد محتوى صلاة لهذا اليوم.';

  @override
  String get prayerLogged => 'تم تسجيل صلاتك.';

  @override
  String get couldNotLogPrayerSession => 'تعذر تسجيل جلسة الصلاة.';

  @override
  String get newReminder => 'تذكير جديد';

  @override
  String get editReminder => 'تعديل التذكير';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get time => 'الوقت';

  @override
  String get daysOfWeek => 'أيام الأسبوع';

  @override
  String get everyDay => 'كل يوم';

  @override
  String get noDaysSelected => 'لم يتم تحديد أيام';

  @override
  String get noRemindersYet => 'لا توجد تذكيرات بعد';

  @override
  String get reminderNotificationTitle => 'حان وقت الصلاة';

  @override
  String get reminderNotificationBody => 'افتح Doxa لبدء صلاة اليوم.';

  @override
  String get reminderPermissionDenied =>
      'الإشعارات مغلقة — فعّلها من إعدادات النظام لاستلام التذكيرات.';
}
