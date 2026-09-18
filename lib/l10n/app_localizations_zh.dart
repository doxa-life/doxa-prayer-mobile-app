// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'DOXA Prayer';

  @override
  String get home => '首页';

  @override
  String get pray => '祷告';

  @override
  String get peopleGroups => '族群';

  @override
  String nPeopleGroups(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个族群',
      zero: '没有族群',
    );
    return '$_temp0';
  }

  @override
  String get searchPeopleGroups => '搜索族群';

  @override
  String get profile => '个人资料';

  @override
  String get reminders => '提醒';

  @override
  String get settings => '设置';

  @override
  String get language => '语言';

  @override
  String get retry => '重试';

  @override
  String get couldNotLoadPeopleGroupsMessage => '无法加载族群。';

  @override
  String get selectPeopleGroup => '选择一个族群';

  @override
  String get crossCulturalWorkersPresent => '有跨文化工人';

  @override
  String get unselect => '取消选择';

  @override
  String get workInLocalLanguageAndCulture => '以当地语言和文化开展工作';

  @override
  String get discipleAndChurchMultiplication => '门徒与教会倍增';

  @override
  String get resources => '资源';

  @override
  String get bibleTranslation => '圣经译本';

  @override
  String get bibleStories => '圣经故事';

  @override
  String get jesusFilm => '耶稣传';

  @override
  String get radioBroadcast => '广播节目';

  @override
  String get gospelRecordings => '福音录音';

  @override
  String get audioScripture => '有声圣经';

  @override
  String get overview => '概览';

  @override
  String get prayerStatus => '祷告状态';

  @override
  String get peopleCommittedToPraying => '承诺祷告的人数';

  @override
  String get dailyPrayerCoverage => '每日祷告覆盖';

  @override
  String get peopleGroup => '族群';

  @override
  String get couldNotLoadPeopleGroupDetailsMessage => '无法加载族群详情。';

  @override
  String get share => '分享';

  @override
  String get search => '搜索';

  @override
  String get country => '国家';

  @override
  String get alternateName => '别名';

  @override
  String get population => '人口';

  @override
  String get primaryLanguage => '主要语言';

  @override
  String get primaryReligion => '主要宗教';

  @override
  String get religiousPractices => '宗教习俗';

  @override
  String get setReminder => '设置提醒';

  @override
  String get pauseAndPray => '停下来祷告';

  @override
  String get select => '选择';

  @override
  String get selected => '已选择';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get partial => '部分';

  @override
  String get status => '状态';

  @override
  String get engagementStatus => '宣教参与状态';

  @override
  String get engaged => '已参与宣教';

  @override
  String get adoptionStatus => '认领状态';

  @override
  String get selectPeopleGroupConfirm => '要选择这个族群吗？';

  @override
  String switchPeopleGroupConfirm(String currentName, String newName) {
    return '要停止为“$currentName”祷告，改为为“$newName”祷告吗？';
  }

  @override
  String get amen => '阿们';

  @override
  String get noPeopleGroupSelected => '选择一个族群，开始祷告。';

  @override
  String get couldNotLoadPrayerContent => '无法加载祷告内容。';

  @override
  String get noPrayerContentAvailable => '今天没有祷告内容。';

  @override
  String get prayerThankYouTitle => '感谢你的祷告';

  @override
  String get prayedToday => '今天已祷告';

  @override
  String get prayerReminderTitle => '准备好今天的祷告了吗？';

  @override
  String prayerReminderBody(String peopleGroup) {
    return '点击为“$peopleGroup”祷告。';
  }

  @override
  String get dismissReminderLabel => '关闭提醒';

  @override
  String prayForPeopleGroupLabel(String peopleGroup) {
    return '为“$peopleGroup”祷告';
  }

  @override
  String get pictureCreditLabel => '图片来源';

  @override
  String get clearSearchLabel => '清除搜索';

  @override
  String get forwardLabel => '前进';

  @override
  String get prayerRecordedAnnouncement => '祷告已记录';

  @override
  String prayingWithYou(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '此刻有 $countString 人与你一同祷告',
      one: '此刻有 1 人与你一同祷告',
    );
    return '$_temp0';
  }

  @override
  String get newReminder => '新建提醒';

  @override
  String get editReminder => '编辑提醒';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get time => '时间';

  @override
  String get daysOfWeek => '星期';

  @override
  String get everyDay => '每天';

  @override
  String get noDaysSelected => '未选择日期';

  @override
  String get noRemindersYet => '还没有提醒';

  @override
  String get reminderNotificationTitle => '祷告时间到了';

  @override
  String get reminderNotificationBody => '打开 DOXA，开始今天的祷告。';

  @override
  String get notifications => '通知';

  @override
  String get notificationsEnabledStatus => '通知已开启。你将收到祷告提醒。';

  @override
  String get notificationsDisabledStatus => '通知已关闭，因此你的祷告提醒不会出现。';

  @override
  String get notificationsHowToEnable => '点击下方打开设置，然后允许 DOXA 发送通知。';

  @override
  String get exactAlarmsDisabledStatus => 'DOXA 未获准使用精确闹钟，因此祷告提醒可能会晚几分钟送达。';

  @override
  String get allowExactAlarms => '允许精确闹钟';

  @override
  String get exactAlarmsPromptBody => '为使祷告提醒准时送达，请允许 DOXA 使用精确闹钟。';

  @override
  String get allow => '允许';

  @override
  String get notNow => '暂不';

  @override
  String get enableNotifications => '开启通知';

  @override
  String get openSettings => '打开设置';

  @override
  String get nextReminder => '下一个提醒';

  @override
  String nextReminderToday(String time) {
    return '今天 $time';
  }

  @override
  String nextReminderTomorrow(String time) {
    return '明天 $time';
  }

  @override
  String nextReminderOn(String weekday, String time) {
    return '$weekday $time';
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
      other: '已设置 $countString 个提醒',
      zero: '未设置提醒',
    );
    return '$_temp0';
  }

  @override
  String get wizardWelcomeTitle => '欢迎使用 DOXA Prayer';

  @override
  String get wizardWelcomeBody => 'DOXA 帮助你为一个未得之族祷告。我们会帮你选择族群、设置提醒并保持关注。';

  @override
  String get wizardGetStarted => '开始';

  @override
  String get wizardChoosePeopleGroupTitle => '选择一个族群';

  @override
  String wizardConfirmPeopleGroupTitle(String name) {
    return '为“$name”祷告吗？';
  }

  @override
  String get wizardConfirmPeopleGroupBody => '我们会为你显示这个族群的祷告内容和提醒。你之后可以更改。';

  @override
  String get wizardSetReminderTitle => '设置祷告提醒';

  @override
  String get wizardSetReminderBody => '我们会在你选择的时间轻轻提醒你。你可以跳过这一步，稍后再添加提醒。';

  @override
  String get wizardNewsSignupTitle => '保持关注';

  @override
  String get wizardNewsSignupBody => '可选。接收你的族群的消息以及 DOXA 的最新动态。';

  @override
  String get back => '返回';

  @override
  String get continueLabel => '继续';

  @override
  String get skip => '跳过';

  @override
  String get finish => '完成';

  @override
  String get nameLabel => '姓名';

  @override
  String get emailLabel => '电子邮件';

  @override
  String get emailInvalid => '请输入有效的电子邮件地址。';

  @override
  String get nameRequired => '请输入你的姓名。';

  @override
  String get updatesAboutMyPeopleGroup => '接收我的族群的最新消息';

  @override
  String get updatesFromDoxa => '接收 DOXA 的最新消息';

  @override
  String get signUpForUpdates => '订阅最新消息';

  @override
  String get newsSignupSuccessTitle => '感谢你的订阅！';

  @override
  String newsSignupSuccessBody(String email) {
    return '我们已向 $email 发送验证邮件。请打开收件箱并点击链接以确认订阅。';
  }

  @override
  String get newsSignupError => '出错了。请检查网络连接后重试。';

  @override
  String get enableNotificationsPromptBody => '开启通知，也可在手机上收到这些更新。';

  @override
  String get enableNotificationsButton => '开启通知';

  @override
  String get accountSectionTitle => '你的账户';

  @override
  String get emailVerified => '已验证';

  @override
  String get emailUnverified => '未验证';

  @override
  String get resendVerification => '重新发送验证邮件';

  @override
  String get resendVerificationSent => '验证邮件已发送。请查看收件箱。';

  @override
  String resendVerificationCooldown(int seconds) {
    return '请等待 $seconds 秒后再申请新邮件。';
  }

  @override
  String resendVerificationCountdown(int seconds) {
    return '$seconds 秒后可重新发送';
  }

  @override
  String get signUp => '注册';

  @override
  String get resendVerificationFailed => '邮件发送失败。请重试。';

  @override
  String get viewProfile => '查看个人资料';

  @override
  String get emailsLoadError => '无法加载你的电子邮件地址。';

  @override
  String get updateAvailableTitle => '有可用更新';

  @override
  String get updateAvailableBody => 'DOXA Prayer 有新版本可用。';

  @override
  String get updateRequiredTitle => '需要更新';

  @override
  String get updateRequiredBody => '请更新到最新版本以继续使用 DOXA Prayer。';

  @override
  String get updateAction => '更新';

  @override
  String get updateDismiss => '暂不';

  @override
  String get feedback => '反馈';

  @override
  String get feedbackIntro => '我们很想听听你的想法。告诉我们你对这个应用的看法。';

  @override
  String get feedbackTypeLabel => '哪一类反馈？';

  @override
  String get feedbackTypeCompliment => '赞赏';

  @override
  String get feedbackTypeSuggestion => '建议';

  @override
  String get feedbackTypeProblem => '问题';

  @override
  String get feedbackTypeRequired => '请选择反馈类型。';

  @override
  String get feedbackNameLabel => '姓名（可选）';

  @override
  String get feedbackMessageLabel => '留言';

  @override
  String get feedbackMessageRequired => '请输入留言。';

  @override
  String get feedbackConsentLabel => '请向我发送 DOXA 的最新消息';

  @override
  String get feedbackSubmit => '发送反馈';

  @override
  String get feedbackError => '出错了。请检查网络连接后重试。';

  @override
  String get feedbackRateLimited => '你最近发送了很多反馈。请稍后再试。';

  @override
  String get feedbackSuccessTitle => '谢谢你！';

  @override
  String feedbackSuccessBody(String email) {
    return '你的反馈已以 $email 的名义发送。如果这不是正确的地址，请用正确的地址重新发送。';
  }

  @override
  String shareMessage(String name) {
    return '与我一同为“$name”祷告——下载 DOXA Prayer 应用：';
  }

  @override
  String get shareLink => '分享链接';

  @override
  String scanToPray(String name) {
    return '扫码获取应用，并为“$name”祷告';
  }

  @override
  String appVersion(String version) {
    return '版本 $version';
  }

  @override
  String get previousDay => '前一天';

  @override
  String get nextDay => '后一天';

  @override
  String get dayInTheLifeTitle => '他们的一天';

  @override
  String get myPeopleGroupTitle => '我的族群';

  @override
  String peopleGroupIntroTitle(String name) {
    return '为“$name”祷告';
  }

  @override
  String get peopleGroupOfTheDay => '今日族群';

  @override
  String get pressBackAgainToExit => '再按一次返回键退出';

  @override
  String get notifications_enabled => '通知已开启';

  @override
  String get notifications_disabled => '通知已关闭';

  @override
  String get cancel => '取消';

  @override
  String addPeopleGroupConfirm(String name) {
    return '要开始为“$name”祷告吗？';
  }

  @override
  String get choosePeopleGroup => '选择一个族群';

  @override
  String get addAnotherPeopleGroup => '添加另一个族群';

  @override
  String peopleGroupLimitTitle(num count) {
    return '你正在为 $count 个族群祷告';
  }

  @override
  String peopleGroupLimitBody(String name) {
    return '这已是你能同时代祷的上限。要添加“$name”，请选择一个不再为其祷告的族群。';
  }

  @override
  String get swapPeopleGroupAction => '替换';

  @override
  String removePeopleGroupTitle(String name) {
    return '不再为“$name”祷告？';
  }

  @override
  String get removePeopleGroupBody => '它将从你的主屏幕移除。你可以随时重新添加。';

  @override
  String removePeopleGroupReminders(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '它的 $count 个提醒将被删除。',
      one: '它的提醒将被删除。',
    );
    return '$_temp0';
  }

  @override
  String get stopPraying => '停止祷告';

  @override
  String get noPeopleGroupsForReminder => '设置提醒前请先选择一个族群。';

  @override
  String get reminderPeopleGroup => '族群';

  @override
  String reminderNotificationBodyForGroup(String name) {
    return '打开 DOXA，为“$name”祷告。';
  }

  @override
  String nextReminderForGroup(String time, String name) {
    return '$time 为“$name”';
  }

  @override
  String prayForNextGroup(String name) {
    return '为“$name”祷告';
  }

  @override
  String switchToPeopleGroup(String name) {
    return '切换到“$name”';
  }

  @override
  String get map => '地图';

  @override
  String mapOf(String name) {
    return '“$name”的地图';
  }

  @override
  String get nearbyPeopleGroups => '附近的族群';

  @override
  String get recenter => '重新居中';

  @override
  String get mapUnavailableOffline => '离线时无法显示地图图像';

  @override
  String get yourPeopleGroups => '你的族群';

  @override
  String get locationNotAvailable => '位置不可用';

  @override
  String get couldNotLoadMapMessage => '无法加载地图。';
}
