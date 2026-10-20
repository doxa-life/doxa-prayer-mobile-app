// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'DOXA Prayer';

  @override
  String get home => 'होम';

  @override
  String get pray => 'प्रार्थना करें';

  @override
  String get peopleGroups => 'जनसमूह';

  @override
  String nPeopleGroups(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count जनसमूह',
      one: '1 जनसमूह',
      zero: 'कोई जनसमूह नहीं',
    );
    return '$_temp0';
  }

  @override
  String get searchPeopleGroups => 'जनसमूह खोजें';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get reminders => 'रिमाइंडर';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get language => 'भाषा';

  @override
  String get retry => 'फिर कोशिश करें';

  @override
  String get couldNotLoadPeopleGroupsMessage => 'जनसमूह लोड नहीं हो सके।';

  @override
  String get selectPeopleGroup => 'एक जनसमूह चुनें';

  @override
  String get crossCulturalWorkersPresent => 'अंतर-सांस्कृतिक कार्यकर्ता मौजूद';

  @override
  String get deselect => 'चयन हटाएँ';

  @override
  String get workInLocalLanguageAndCulture =>
      'स्थानीय भाषा और संस्कृति में कार्य';

  @override
  String get discipleAndChurchMultiplication => 'शिष्य और कलीसिया का गुणन';

  @override
  String get resources => 'संसाधन';

  @override
  String get bibleTranslation => 'बाइबिल अनुवाद';

  @override
  String get bibleStories => 'बाइबिल कहानियाँ';

  @override
  String get jesusFilm => 'यीशु फ़िल्म';

  @override
  String get radioBroadcast => 'रेडियो प्रसारण';

  @override
  String get gospelRecordings => 'सुसमाचार रिकॉर्डिंग';

  @override
  String get audioScripture => 'ऑडियो पवित्रशास्त्र';

  @override
  String get overview => 'अवलोकन';

  @override
  String get prayerStatus => 'प्रार्थना की स्थिति';

  @override
  String get peopleCommittedToPraying => 'प्रार्थना के लिए प्रतिबद्ध लोग';

  @override
  String committedToPrayFor(String name) {
    return '“$name” के लिए प्रार्थना करने को प्रतिबद्ध';
  }

  @override
  String prayerStatusExplanation(String name) {
    return 'यह उन लोगों की संख्या है जो “$name” के लिए प्रार्थना करने के लिए प्रतिबद्ध हैं।';
  }

  @override
  String get dailyPrayerCoverage => 'दैनिक प्रार्थना कवरेज';

  @override
  String get peopleGroup => 'जनसमूह';

  @override
  String get couldNotLoadPeopleGroupDetailsMessage =>
      'जनसमूह का विवरण लोड नहीं हो सका।';

  @override
  String get share => 'साझा करें';

  @override
  String get search => 'खोजें';

  @override
  String get country => 'देश';

  @override
  String get alternateName => 'वैकल्पिक नाम';

  @override
  String get population => 'जनसंख्या';

  @override
  String get primaryLanguage => 'मुख्य भाषा';

  @override
  String get primaryReligion => 'मुख्य धर्म';

  @override
  String get religiousPractices => 'धार्मिक प्रथाएँ';

  @override
  String get setReminder => 'रिमाइंडर सेट करें';

  @override
  String get pauseAndPray => 'रुकें और प्रार्थना करें';

  @override
  String get select => 'चुनें';

  @override
  String get selected => 'चयनित';

  @override
  String get yes => 'हाँ';

  @override
  String get no => 'नहीं';

  @override
  String get partial => 'आंशिक';

  @override
  String get status => 'स्थिति';

  @override
  String get engagementStatus => 'संलग्नता की स्थिति';

  @override
  String get engaged => 'संपर्कित';

  @override
  String get unengaged => 'अनसंपर्कित';

  @override
  String nPeoplePraying(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count लोगों ने हाल में प्रार्थना की',
      one: '$count व्यक्ति ने हाल में प्रार्थना की',
      zero: 'हाल में किसी ने प्रार्थना नहीं की',
    );
    return '$_temp0';
  }

  @override
  String get adoptionStatus => 'गोद लेने की स्थिति';

  @override
  String get selectPeopleGroupConfirm =>
      'क्या आप इस जनसमूह को चुनना चाहते हैं?';

  @override
  String switchPeopleGroupConfirm(String currentName, String newName) {
    return 'क्या आप “$currentName” के लिए प्रार्थना करना बंद करके “$newName” के लिए प्रार्थना करना शुरू करना चाहते हैं?';
  }

  @override
  String get amen => 'आमीन';

  @override
  String get noPeopleGroupSelected =>
      'प्रार्थना शुरू करने के लिए एक जनसमूह चुनें।';

  @override
  String get couldNotLoadPrayerContent => 'प्रार्थना सामग्री लोड नहीं हो सकी।';

  @override
  String get noPrayerContentAvailable =>
      'आज के लिए कोई प्रार्थना सामग्री नहीं।';

  @override
  String get prayerThankYouTitle => 'प्रार्थना करने के लिए धन्यवाद';

  @override
  String get prayedToday => 'आज प्रार्थना की';

  @override
  String get prayerReminderTitle => 'आज की प्रार्थना के लिए तैयार?';

  @override
  String prayerReminderBody(String peopleGroup) {
    return '“$peopleGroup” के लिए प्रार्थना करने हेतु टैप करें।';
  }

  @override
  String get dismissReminderLabel => 'रिमाइंडर बंद करें';

  @override
  String prayForPeopleGroupLabel(String peopleGroup) {
    return '“$peopleGroup” के लिए प्रार्थना करें';
  }

  @override
  String get pictureCreditLabel => 'चित्र श्रेय';

  @override
  String get clearSearchLabel => 'खोज साफ़ करें';

  @override
  String get forwardLabel => 'आगे';

  @override
  String get prayerRecordedAnnouncement => 'प्रार्थना दर्ज हुई';

  @override
  String prayingWithYou(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$countString लोग अभी अनसंपर्कित जनसमूहों के लिए प्रार्थना कर रहे हैं',
      one:
          '$countString व्यक्ति अभी अनसंपर्कित जनसमूहों के लिए प्रार्थना कर रहा है',
    );
    return '$_temp0';
  }

  @override
  String get newReminder => 'नया रिमाइंडर';

  @override
  String get editReminder => 'रिमाइंडर संपादित करें';

  @override
  String get save => 'सहेजें';

  @override
  String get delete => 'हटाएँ';

  @override
  String get time => 'समय';

  @override
  String get daysOfWeek => 'सप्ताह के दिन';

  @override
  String get everyDay => 'हर दिन';

  @override
  String get noDaysSelected => 'कोई दिन चयनित नहीं';

  @override
  String get noRemindersYet => 'अभी कोई रिमाइंडर नहीं';

  @override
  String get reminderNotificationTitle => 'प्रार्थना का समय';

  @override
  String get reminderNotificationBody =>
      'आज की प्रार्थना शुरू करने के लिए DOXA खोलें।';

  @override
  String get notifications => 'सूचनाएँ';

  @override
  String get notificationsEnabledStatus =>
      'सूचनाएँ चालू हैं। आपके प्रार्थना रिमाइंडर आपको मिलते रहेंगे।';

  @override
  String get notificationsDisabledStatus =>
      'सूचनाएँ बंद हैं, इसलिए आपके प्रार्थना रिमाइंडर दिखाई नहीं देंगे।';

  @override
  String get notificationsHowToEnable =>
      'सेटिंग्स खोलने के लिए नीचे टैप करें, फिर DOXA के लिए सूचनाओं की अनुमति दें।';

  @override
  String get exactAlarmsDisabledStatus =>
      'DOXA को सटीक अलार्म की अनुमति नहीं है, इसलिए आपके प्रार्थना रिमाइंडर कुछ मिनट देर से आ सकते हैं।';

  @override
  String get allowExactAlarms => 'सटीक अलार्म की अनुमति दें';

  @override
  String get exactAlarmsPromptBody =>
      'आपके प्रार्थना रिमाइंडर ठीक समय पर आएँ, इसके लिए DOXA को सटीक अलार्म की अनुमति दें।';

  @override
  String get allow => 'अनुमति दें';

  @override
  String get notNow => 'अभी नहीं';

  @override
  String get enableNotifications => 'सूचनाएँ सक्षम करें';

  @override
  String get openSettings => 'सेटिंग्स खोलें';

  @override
  String get nextReminder => 'अगला रिमाइंडर';

  @override
  String nextReminderToday(String time) {
    return 'आज $time पर';
  }

  @override
  String nextReminderTomorrow(String time) {
    return 'कल $time पर';
  }

  @override
  String nextReminderOn(String weekday, String time) {
    return '$weekday को $time';
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
      other: '$countString रिमाइंडर सेट',
      one: '1 रिमाइंडर सेट',
      zero: 'कोई रिमाइंडर सेट नहीं',
    );
    return '$_temp0';
  }

  @override
  String get wizardWelcomeTitle => 'DOXA Prayer में आपका स्वागत है';

  @override
  String get wizardWelcomeBody =>
      'DOXA आपको एक अप्राप्य जनसमूह के लिए प्रार्थना करने में मदद करता है। हम आपको समूह चुनने, रिमाइंडर सेट करने और जुड़े रहने में मदद करेंगे।';

  @override
  String get wizardGetStarted => 'शुरू करें';

  @override
  String get wizardChoosePeopleGroupTitle => 'एक जनसमूह चुनें';

  @override
  String wizardConfirmPeopleGroupTitle(String name) {
    return '“$name” के लिए प्रार्थना करें?';
  }

  @override
  String get wizardConfirmPeopleGroupBody =>
      'हम आपको इस समूह के लिए प्रार्थना सामग्री और रिमाइंडर दिखाएँगे। आप इसे बाद में बदल सकते हैं।';

  @override
  String get wizardSetReminderTitle => 'प्रार्थना रिमाइंडर सेट करें';

  @override
  String get wizardSetReminderBody =>
      'आपके चुने हुए समय पर हम आपको एक कोमल याद दिलाएँगे। आप इसे छोड़ सकते हैं और बाद में रिमाइंडर जोड़ सकते हैं।';

  @override
  String get wizardNewsSignupTitle => 'जुड़े रहें';

  @override
  String get wizardNewsSignupBody =>
      'वैकल्पिक। अपने जनसमूह की ख़बरें और DOXA से अपडेट पाएँ।';

  @override
  String get back => 'वापस';

  @override
  String get continueLabel => 'आगे बढ़ें';

  @override
  String get skip => 'छोड़ें';

  @override
  String get finish => 'समाप्त';

  @override
  String get nameLabel => 'नाम';

  @override
  String get emailLabel => 'ईमेल';

  @override
  String get emailInvalid => 'कृपया एक मान्य ईमेल पता दर्ज करें।';

  @override
  String get nameRequired => 'कृपया अपना नाम दर्ज करें।';

  @override
  String get updatesAboutMyPeopleGroup =>
      'मेरे जनसमूह के बारे में अपडेट प्राप्त करें';

  @override
  String get updatesFromDoxa => 'DOXA से अपडेट प्राप्त करें';

  @override
  String get signUpForUpdates => 'अपडेट के लिए पंजीकरण करें';

  @override
  String get newsSignupSuccessTitle => 'पंजीकरण के लिए धन्यवाद!';

  @override
  String newsSignupSuccessBody(String email) {
    return 'हमने $email पर एक सत्यापन ईमेल भेजा है। कृपया अपना इनबॉक्स खोलें और सदस्यता की पुष्टि के लिए लिंक पर टैप करें।';
  }

  @override
  String get newsSignupError =>
      'कुछ गड़बड़ हो गई। कृपया अपना कनेक्शन जाँचें और फिर कोशिश करें।';

  @override
  String get enableNotificationsPromptBody =>
      'ये अपडेट अपने फ़ोन पर भी पाने के लिए सूचनाएँ सक्षम करें।';

  @override
  String get enableNotificationsButton => 'सूचनाएँ सक्षम करें';

  @override
  String get accountSectionTitle => 'आपका खाता';

  @override
  String get storageSectionTitle => 'स्टोरेज';

  @override
  String get storagePrayerData => 'प्रार्थनाएँ और जनसमूह';

  @override
  String get storagePhotos => 'तस्वीरें';

  @override
  String get storageMap => 'मानचित्र';

  @override
  String get storageTotal => 'कुल';

  @override
  String get storageExplanation =>
      'प्रार्थनाएँ, जनसमूह, तस्वीरें और मानचित्र आपके डिवाइस पर सहेजे जाते हैं, ताकि वे तुरंत खुलें और ऑफ़लाइन भी काम करें।';

  @override
  String get clearCache => 'कैश साफ़ करें';

  @override
  String get clearCacheConfirmTitle => 'कैश साफ़ करें?';

  @override
  String get clearCacheConfirmBody =>
      'जल्दी खोलने के लिए सहेजा गया सब कुछ हटा दिया जाएगा और ज़रूरत पड़ने पर फिर से डाउनलोड होगा। आपके जनसमूह, रिमाइंडर और सेटिंग्स बने रहेंगे।';

  @override
  String get cacheCleared => 'कैश साफ़ हो गया';

  @override
  String get emailVerified => 'सत्यापित';

  @override
  String get emailUnverified => 'सत्यापित नहीं';

  @override
  String get resendVerification => 'सत्यापन ईमेल फिर से भेजें';

  @override
  String get resendVerificationSent =>
      'सत्यापन ईमेल भेजा गया। अपना इनबॉक्स देखें।';

  @override
  String resendVerificationCooldown(int seconds) {
    return 'कृपया दूसरा ईमेल माँगने से पहले $seconds सेकंड प्रतीक्षा करें।';
  }

  @override
  String resendVerificationCountdown(int seconds) {
    return '$seconds सेकंड में फिर से भेजें';
  }

  @override
  String get signUp => 'पंजीकरण करें';

  @override
  String get resendVerificationFailed =>
      'ईमेल नहीं भेजा जा सका। कृपया फिर कोशिश करें।';

  @override
  String get viewProfile => 'प्रोफ़ाइल देखें';

  @override
  String get emailsLoadError => 'आपके ईमेल पते लोड नहीं हो सके।';

  @override
  String get updateAvailableTitle => 'अपडेट उपलब्ध';

  @override
  String get updateAvailableBody => 'DOXA Prayer का नया संस्करण उपलब्ध है।';

  @override
  String get updateRequiredTitle => 'अपडेट आवश्यक';

  @override
  String get updateRequiredBody =>
      'DOXA Prayer का उपयोग जारी रखने के लिए कृपया नवीनतम संस्करण पर अपडेट करें।';

  @override
  String get updateAction => 'अपडेट करें';

  @override
  String get updateDismiss => 'अभी नहीं';

  @override
  String get feedback => 'प्रतिक्रिया';

  @override
  String get feedbackIntro =>
      'हम आपसे सुनना चाहेंगे। बताइए कि आपको ऐप कैसा लगा।';

  @override
  String get feedbackTypeLabel => 'किस प्रकार की प्रतिक्रिया?';

  @override
  String get feedbackTypeCompliment => 'प्रशंसा';

  @override
  String get feedbackTypeSuggestion => 'सुझाव';

  @override
  String get feedbackTypeProblem => 'समस्या';

  @override
  String get feedbackTypeRequired => 'कृपया प्रतिक्रिया का प्रकार चुनें।';

  @override
  String get feedbackNameLabel => 'नाम (वैकल्पिक)';

  @override
  String get feedbackMessageLabel => 'संदेश';

  @override
  String get feedbackMessageRequired => 'कृपया एक संदेश लिखें।';

  @override
  String get feedbackConsentLabel => 'मुझे DOXA की ख़बरों से अवगत रखें';

  @override
  String get feedbackSubmit => 'प्रतिक्रिया भेजें';

  @override
  String get feedbackError =>
      'कुछ गड़बड़ हो गई। कृपया अपना कनेक्शन जाँचें और फिर कोशिश करें।';

  @override
  String get feedbackRateLimited =>
      'आपने हाल ही में बहुत सारी प्रतिक्रियाएँ भेजी हैं। कृपया बाद में कोशिश करें।';

  @override
  String get feedbackSuccessTitle => 'धन्यवाद!';

  @override
  String feedbackSuccessBody(String email) {
    return 'आपकी प्रतिक्रिया $email के रूप में भेजी गई। यदि यह सही पता नहीं है, तो उसे सही पते के साथ फिर से भेजें।';
  }

  @override
  String shareMessage(String name) {
    return 'मेरे साथ $name के लिए प्रार्थना करें — DOXA Prayer ऐप पाएँ:';
  }

  @override
  String get shareLink => 'लिंक साझा करें';

  @override
  String scanToPray(String name) {
    return 'ऐप पाने और “$name” के लिए प्रार्थना करने हेतु स्कैन करें';
  }

  @override
  String appVersion(String version) {
    return 'संस्करण $version';
  }

  @override
  String get previousDay => 'पिछला दिन';

  @override
  String get nextDay => 'अगला दिन';

  @override
  String get dayInTheLifeTitle => 'जीवन का एक दिन';

  @override
  String get myPeopleGroupTitle => 'मेरा जनसमूह';

  @override
  String peopleGroupIntroTitle(String name) {
    return '“$name” के लिए प्रार्थना करें';
  }

  @override
  String get peopleGroupOfTheDay => 'आज का जनसमूह';

  @override
  String get pressBackAgainToExit => 'बाहर निकलने के लिए फिर से बैक दबाएँ';

  @override
  String get notifications_enabled => 'सूचनाएँ सक्षम';

  @override
  String get notifications_disabled => 'सूचनाएँ अक्षम';

  @override
  String get cancel => 'रद्द करें';

  @override
  String addPeopleGroupConfirm(String name) {
    return 'क्या आप “$name” के लिए प्रार्थना करना शुरू करना चाहते हैं?';
  }

  @override
  String get choosePeopleGroup => 'एक जनसमूह चुनें';

  @override
  String get addAnotherPeopleGroup => 'एक और जनसमूह जोड़ें';

  @override
  String peopleGroupLimitTitle(num count) {
    return 'आप $count जनसमूहों के लिए प्रार्थना कर रहे हैं';
  }

  @override
  String peopleGroupLimitBody(String name) {
    return 'एक साथ इतने ही के लिए आप प्रार्थना कर सकते हैं। “$name” को जोड़ने के लिए, चुनें कि किसके लिए प्रार्थना करना बंद करना है।';
  }

  @override
  String get swapPeopleGroupAction => 'बदलें';

  @override
  String removePeopleGroupTitle(String name) {
    return '“$name” के लिए प्रार्थना करना बंद करें?';
  }

  @override
  String get removePeopleGroupBody =>
      'यह आपकी होम स्क्रीन से हटा दिया जाएगा। आप इसे कभी भी फिर से जोड़ सकते हैं।';

  @override
  String removePeopleGroupReminders(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'इसके $count रिमाइंडर हटा दिए जाएँगे।',
      one: 'इसका $count रिमाइंडर हटा दिया जाएगा।',
    );
    return '$_temp0';
  }

  @override
  String get stopPraying => 'प्रार्थना करना बंद करें';

  @override
  String get noPeopleGroupsForReminder =>
      'रिमाइंडर सेट करने से पहले एक जनसमूह चुनें।';

  @override
  String get reminderPeopleGroup => 'जनसमूह';

  @override
  String reminderNotificationBodyForGroup(String name) {
    return '“$name” के लिए प्रार्थना करने हेतु DOXA खोलें।';
  }

  @override
  String nextReminderForGroup(String time, String name) {
    return '“$name” के लिए $time';
  }

  @override
  String prayForNextGroup(String name) {
    return '“$name” के लिए प्रार्थना करें';
  }

  @override
  String switchToPeopleGroup(String name) {
    return '“$name” पर जाएँ';
  }

  @override
  String get map => 'मानचित्र';

  @override
  String mapOf(String name) {
    return '“$name” का मानचित्र';
  }

  @override
  String get recenter => 'फिर से केंद्र में लाएँ';

  @override
  String get mapUnavailableOffline =>
      'ऑफ़लाइन में मानचित्र की छवियाँ उपलब्ध नहीं';

  @override
  String get mapNotConfigured => 'मानचित्र अभी उपलब्ध नहीं है';

  @override
  String get yourPeopleGroups => 'आपके जनसमूह';

  @override
  String get viewMap => 'मानचित्र देखें';

  @override
  String get viewOnMap => 'मानचित्र पर देखें';

  @override
  String get moreInfo => 'अधिक जानकारी';

  @override
  String get glossaryPeopleGroup => 'जनसमूह';

  @override
  String get glossaryPeopleGroupDefinition =>
      'लोगों का एक समूह जिनकी मान्यताएँ, मूल्य और संस्कृति साझा हैं।';

  @override
  String get glossaryPeopleGroupAlternates => 'जनसमूहों';

  @override
  String get locationNotAvailable => 'स्थान उपलब्ध नहीं';

  @override
  String get couldNotLoadMapMessage => 'मानचित्र लोड नहीं हो सका।';

  @override
  String get filters => 'फ़िल्टर';

  @override
  String get sortByName => 'नाम से क्रमबद्ध करें';

  @override
  String get sortAscending => 'आरोही क्रम में लगाएँ (अ–ह)';

  @override
  String get sortDescending => 'अवरोही क्रम में लगाएँ (ह–अ)';

  @override
  String get sortAZ => 'अ–ह';

  @override
  String get sortZA => 'ह–अ';

  @override
  String get prioritizeFewestIntercessors =>
      'सबसे कम मध्यस्थों वाले जनसमूहों को प्राथमिकता दें';

  @override
  String get allLanguages => 'सभी भाषाएँ';

  @override
  String get allReligions => 'सभी धर्म';

  @override
  String get allStatuses => 'कोई भी स्थिति';

  @override
  String nSelected(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count चयनित',
      zero: 'कोई चयनित नहीं',
    );
    return '$_temp0';
  }

  @override
  String get clear => 'साफ़ करें';

  @override
  String get done => 'हो गया';

  @override
  String get clearFilters => 'फ़िल्टर हटाएँ';

  @override
  String get allCountries => 'सभी देश';

  @override
  String get continentAsia => 'एशिया';

  @override
  String get continentAfrica => 'अफ़्रीका';

  @override
  String get continentAmericas => 'अमेरिका';

  @override
  String get continentEurope => 'यूरोप';

  @override
  String get continentOceania => 'ओशिनिया';

  @override
  String get continentOther => 'अन्य';

  @override
  String get wizardGroupIntroBody =>
      'DOXA Prayer आपको अप्राप्य जनसमूहों के लिए प्रार्थना करने में मदद करने के लिए बनाया गया है। सबसे पहले हमें आपके लिए एक जनसमूह ढूँढना है, जिसके लिए आप प्रार्थना करेंगे।';

  @override
  String get wizardGroupIntroSearchOption => 'एक जनसमूह खोजें';

  @override
  String get wizardGroupIntroPickForMeOption => 'मेरे लिए एक जनसमूह चुनें';

  @override
  String get wizardGroupIntroChangeLaterNote => 'आप इसे कभी भी बदल सकते हैं।';

  @override
  String wizardGroupPickedTitle(String name) {
    return 'हमने आपके लिए $name चुना है!';
  }

  @override
  String get wizardGroupPickedQuestion =>
      'क्या आप इसी जनसमूह के साथ आगे बढ़ना चाहेंगे, या कोई दूसरा आज़माना चाहेंगे?';

  @override
  String get wizardGroupPickedContinueButton => 'इसी जनसमूह के साथ आगे बढ़ें';

  @override
  String get wizardGroupPickedRerollButton => 'दूसरा जनसमूह चुनें';

  @override
  String get languageSwitchConfirm => 'क्या आप यही भाषा रखना चाहते हैं?';

  @override
  String get languageSwitchKeep => 'रखें';

  @override
  String languageSwitchUndo(String language) {
    return '$language पर वापस जाएँ';
  }

  @override
  String get chooseDay => 'दिन चुनें';

  @override
  String get starPrayer => 'तारांकित करें';

  @override
  String get prayerStarred => 'तारांकित';

  @override
  String get downloadPrayer => 'डाउनलोड करें';

  @override
  String get prayerDownloaded => 'डाउनलोड हो गई';

  @override
  String get prayerSaveFailed =>
      'यह प्रार्थना सहेजी नहीं जा सकी। अपना कनेक्शन जाँचें और फिर कोशिश करें।';

  @override
  String get savedPrayers => 'सहेजी गई प्रार्थनाएँ';

  @override
  String get savedPrayersEmpty =>
      'जिस प्रार्थना में आपने पवित्र आत्मा को काम करते महसूस किया, उसे तारांकित करें, या ऑफ़लाइन प्रार्थना के लिए किसी को डाउनलोड करें — वह यहाँ दिखाई देगी।';
}
