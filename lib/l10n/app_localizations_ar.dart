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
  String get crossCulturalWorkersPresent => 'تواجد خدّام يعملون عبر الثقافات';

  @override
  String get workInLocalLanguageAndCulture => 'العمل باللغة والثقافة المحلية';

  @override
  String get discipleAndChurchMultiplication => 'تكاثر التلاميذ والكنائس';

  @override
  String get resources => 'المصادر';

  @override
  String get bibleTranslation => 'ترجمة الكتاب المقدس';

  @override
  String get bibleStories => 'قصص الكتاب المقدس';

  @override
  String get jesusFilm => 'فيلم يسوع';

  @override
  String get radioBroadcast => 'بث إذاعي';

  @override
  String get gospelRecordings => 'تسجيلات الإنجيل';

  @override
  String get audioScripture => 'الكتاب المقدس الصوتي';

  @override
  String get overview => 'نظرة عامة';

  @override
  String get prayerStatus => 'حالة الصلاة';

  @override
  String get peopleCommittedToPraying => 'الأشخاص الذين التزموا بالصلاة';

  @override
  String get prayerCoverage24h => 'سلسلة صلاة مستمرة على مدار 24 ساعة';

  @override
  String get peopleGroup => 'People Group';

  @override
  String get couldNotLoadPeopleGroupDetailsMessage =>
      'Could not load people group details.';

  @override
  String get share => 'مشاركة';

  @override
  String get search => 'Search';

  @override
  String get country => 'الدولة';

  @override
  String get alternateName => 'اسم بديل';

  @override
  String get population => 'عدد السكان';

  @override
  String get primaryLanguage => 'اللغة الأساسية';

  @override
  String get primaryReligion => 'الدين الرئيسي';

  @override
  String get religiousPractices => 'الممارسات الدينية';

  @override
  String get setReminder => 'تعيين تذكير';

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
  String get status => 'الحالة';

  @override
  String get engagementStatus => 'حالة الإلتزام';

  @override
  String get adoptionStatus => 'وضعية الإنتماء';

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
  String get prayedToday => 'صُلِّي اليوم';

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
  String get notifications => 'الإشعارات';

  @override
  String get notificationsEnabledStatus =>
      'الإشعارات مفعّلة. ستصلك تذكيرات الصلاة.';

  @override
  String get notificationsDisabledStatus =>
      'الإشعارات مغلقة، لذلك لن تظهر تذكيرات الصلاة.';

  @override
  String get notificationsHowToEnable =>
      'اضغط على الزر أدناه لفتح الإعدادات، ثم اسمح بالإشعارات لتطبيق Doxa.';

  @override
  String get enableNotifications => 'تفعيل الإشعارات';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get nextReminder => 'التذكير التالي';

  @override
  String nextReminderToday(String time) {
    return 'اليوم في $time';
  }

  @override
  String nextReminderTomorrow(String time) {
    return 'غدًا في $time';
  }

  @override
  String nextReminderOn(String weekday, String time) {
    return '$weekday في $time';
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
      other: '$countString تذكير مفعّل',
      many: '$countString تذكيرًا مفعّلًا',
      few: '$countString تذكيرات مفعّلة',
      two: 'تذكيران مفعّلان',
      one: 'تذكير واحد مفعّل',
      zero: 'لا توجد تذكيرات',
    );
    return '$_temp0';
  }

  @override
  String get dismissNextReminder => 'إلغاء التالي';

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
    return 'الإصدار $version';
  }

  @override
  String get previousDay => 'اليوم السابق';

  @override
  String get nextDay => 'اليوم التالي';

  @override
  String get dayInTheLifeTitle => 'Day in the Life';

  @override
  String get myPeopleGroupTitle => 'مجموعتي العرقية';

  @override
  String peopleGroupIntroTitle(String name) {
    return 'Pray for the $name';
  }

  @override
  String get peopleGroupOfTheDay => 'People Group of the Day';

  @override
  String get pressBackAgainToExit => 'اضغط مرة أخرى للخروج';

  @override
  String get notifications_enabled => 'الإشعارات مفعّلة';

  @override
  String get notifications_disabled => 'الإشعارات مغلقة';
}
