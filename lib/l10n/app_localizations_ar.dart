// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'صلاة دوكسا';

  @override
  String get home => 'الصفحة الرئيسية';

  @override
  String get pray => 'صلّي';

  @override
  String get peopleGroups => 'مجموعات بشرية';

  @override
  String nPeopleGroups(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'مجموعات سكانية $countString',
      one: 'مجموعة سكانية واحدة',
      zero: 'لا توجد مجموعات سكانية',
    );
    return '$_temp0';
  }

  @override
  String get searchPeopleGroups => 'البحث عن المجموعات العرقية';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get reminders => 'تذكير';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get couldNotLoadPeopleGroupsMessage =>
      'تعذر تحميل المجموعات السكانية.';

  @override
  String get selectPeopleGroup => 'اختر مجموعة عرقية';

  @override
  String get crossCulturalWorkersPresent => 'تواجد خدّام يعملون عبر الثقافات';

  @override
  String get workInLocalLanguageAndCulture => 'العمل باللغة والثقافة المحلية';

  @override
  String get discipleAndChurchMultiplication => 'تضاعف التلاميذ والكنيسة';

  @override
  String get resources => 'الموارد';

  @override
  String get bibleTranslation => 'ترجمة الكتاب المقدس';

  @override
  String get bibleStories => 'قصص الكتاب المقدس';

  @override
  String get jesusFilm => 'فيلم يسوع';

  @override
  String get radioBroadcast => 'البث الإذاعي';

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
  String get prayerCoverage24h => 'تغطية صلاة على مدار 24 ساعة';

  @override
  String get peopleGroup => 'مجموعة بشرية';

  @override
  String get couldNotLoadPeopleGroupDetailsMessage =>
      'تعذر تحميل تفاصيل المجموعة العرقية.';

  @override
  String get share => 'مشاركة';

  @override
  String get search => 'إبحث';

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
  String get select => 'اختر';

  @override
  String get selected => 'مُختار';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get status => 'الحالة';

  @override
  String get engagementStatus => 'حالة الانخراط';

  @override
  String get adoptionStatus => 'وضعية الإنتماء';

  @override
  String get selectPeopleGroupConfirm => 'هل تريد تحديد هذه المجموعة العرقية؟';

  @override
  String switchPeopleGroupConfirm(String currentName, String newName) {
    return 'هل تريد التوقف عن الدعاء من أجل $currentName والبدء في الدعاء من أجل $newName؟';
  }

  @override
  String get amen => 'آمين';

  @override
  String get noPeopleGroupSelected =>
      'اختر مجموعة من الناس لتبدأ بالصلاة من أجلها.';

  @override
  String get couldNotLoadPrayerContent => 'تعذر تحميل محتوى الصلاة.';

  @override
  String get noPrayerContentAvailable => 'لا يوجد محتوى صلاة لليوم.';

  @override
  String get prayerThankYouTitle => 'شكرًا لكم على صلواتكم';

  @override
  String get prayerThankYouMessage =>
      'إخلاصك في الصلاة له أهمية كبيرة. الله يسمعك، وصلواتك تُحدث فرقًا.';

  @override
  String get prayerThankYouVerse =>
      'افرحوا دائمًا، صلّوا بلا انقطاع، اشكروا في كل الأحوال؛ فهذه هي مشيئة الله لكم في المسيح يسوع.';

  @override
  String get prayerThankYouVerseReference => '1 تسالونيكي 5:16-18';

  @override
  String get prayedToday => 'صليت اليوم';

  @override
  String get newReminder => 'تذكير جديد';

  @override
  String get editReminder => 'تحرير التذكير';

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
  String get noDaysSelected => 'لم يتم تحديد أي أيام';

  @override
  String get noRemindersYet => 'لا توجد تذكيرات حتى الآن';

  @override
  String get reminderNotificationTitle => 'حان وقت الصلاة';

  @override
  String get reminderNotificationBody => 'افتح كتاب «دوكسا» لبدء صلاة اليوم.';

  @override
  String get notifications => 'إشعارات';

  @override
  String get notificationsEnabledStatus =>
      'الإشعارات قيد التشغيل. سيتم إرسال تذكيرات الصلاة إليك.';

  @override
  String get notificationsDisabledStatus =>
      'الإشعارات معطلة، لذا لن تظهر تذكيرات الصلاة.';

  @override
  String get notificationsHowToEnable =>
      'انقر أدناه لفتح الإعدادات، ثم قم بالسماح بتلقي الإشعارات من Doxa.';

  @override
  String get enableNotifications => 'تمكين الإشعارات';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get nextReminder => 'التذكير التالي';

  @override
  String nextReminderToday(String time) {
    return 'اليوم على موقع $time';
  }

  @override
  String nextReminderTomorrow(String time) {
    return 'غدًا على موقع $time';
  }

  @override
  String nextReminderOn(String weekday, String time) {
    return '$weekday على الرابط $time';
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
      other: 'تم تعيين $countString تذكير',
      one: 'تم تعيين تذكير واحد',
      zero: 'لم يتم تعيين أي تذكير',
    );
    return '$_temp0';
  }

  @override
  String get dismissNextReminder => 'إغلاق التالي';

  @override
  String get wizardWelcomeTitle => 'مرحبًا بكم في «Doxa Prayer»';

  @override
  String get wizardWelcomeBody =>
      'تساعدك «دوكسا» على الصلاة من أجل إحدى المجموعات العرقية التي لم تصلها البشارة بعد. سنساعدك في اختيار مجموعة معينة، وضبط تذكير، ومتابعة آخر المستجدات.';

  @override
  String get wizardGetStarted => 'ابدؤوا الآن';

  @override
  String get wizardChoosePeopleGroupTitle => 'إختر شعب';

  @override
  String wizardConfirmPeopleGroupTitle(String name) {
    return 'هل نصلي من أجل «$name»؟';
  }

  @override
  String get wizardConfirmPeopleGroupBody =>
      'سنعرض لك محتوى الصلاة والتذكيرات الخاصة بهذه المجموعة. يمكنك تغيير ذلك لاحقًا.';

  @override
  String get wizardSetReminderTitle => 'ضبط تذكير بالصلاة';

  @override
  String get wizardSetReminderBody =>
      'سنرسل لك تذكيرًا لطيفًا في الوقت الذي تختاره. يمكنك تخطي هذه الخطوة وإضافة التذكيرات لاحقًا.';

  @override
  String get wizardNewsSignupTitle => 'ابقَ على اطلاع';

  @override
  String get wizardNewsSignupBody =>
      'اختياري. احصل على الأخبار المتعلقة بمجموعتك العرقية وعلى آخر المستجدات من Doxa.';

  @override
  String get back => 'العودة إلى الخلف';

  @override
  String get continueLabel => 'استمر';

  @override
  String get saveAndContinue => 'حفظ والمتابعة';

  @override
  String get skip => 'تخطّي';

  @override
  String get finish => 'إنهاء';

  @override
  String get nameLabel => 'الإسم';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get emailInvalid => 'يرجى إدخال عنوان بريد إلكتروني صالح.';

  @override
  String get nameRequired => 'يرجى إدخال اسمك.';

  @override
  String get updatesAboutMyPeopleGroup =>
      'تلقي آخر المستجدات حول مجموعتي العرقية';

  @override
  String get updatesFromDoxa => 'احصل على آخر المستجدات من Doxa';

  @override
  String get signUpForUpdates => 'اشترك للحصول على آخر المستجدات';

  @override
  String get newsSignupThanks => 'شكرًا — لقد تم تسجيلك.';

  @override
  String get newsSignupError =>
      'حدث خطأ ما. يرجى التحقق من اتصالك ومحاولة الإجراء مرة أخرى.';

  @override
  String get updateAvailableTitle => 'تحديث متاح';

  @override
  String get updateAvailableBody => 'يتوفر إصدار جديد من تطبيق «Doxa Prayer».';

  @override
  String get updateRequiredTitle => 'يلزم التحديث';

  @override
  String get updateRequiredBody =>
      'يرجى التحديث إلى أحدث إصدار لمواصلة استخدام تطبيق Doxa Prayer.';

  @override
  String get updateAction => 'تحديث';

  @override
  String get updateDismiss => 'ليس الآن';

  @override
  String get getInvolved => 'شارك معنا';

  @override
  String get donate => 'تبرع';

  @override
  String get feedback => 'التعليقات';

  @override
  String shareMessage(String name) {
    return 'صلوا معي من أجل حملة «$name» — قوموا بتنزيل تطبيق «Doxa Prayer»:';
  }

  @override
  String get qrCode => 'رمز QR';

  @override
  String scanToPray(String name) {
    return 'امسح الرمز للحصول على التطبيق وادعُ من أجل حملة «$name»';
  }

  @override
  String appVersion(String version) {
    return 'الإصدار$version';
  }

  @override
  String get previousDay => 'اليوم السابق';

  @override
  String get nextDay => 'في اليوم التالي';

  @override
  String get dayInTheLifeTitle => 'يوم في الحياة';

  @override
  String get myPeopleGroupTitle => 'مجموعتي العرقية';

  @override
  String peopleGroupIntroTitle(String name) {
    return 'صلوا من أجل منظمة «$name»';
  }

  @override
  String get peopleGroupOfTheDay => 'مجموعة إثنية اليوم';

  @override
  String get pressBackAgainToExit => 'اضغط على زر الرجوع مرة أخرى للخروج';

  @override
  String get notifications_enabled => 'تم تمكين الإشعارات';

  @override
  String get notifications_disabled => 'الإشعارات معطلة';
}
