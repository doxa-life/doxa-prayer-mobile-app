// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Doxa Prayer';

  @override
  String get home => 'Home';

  @override
  String get pray => 'Pray';

  @override
  String get peopleGroups => 'People Groups';

  @override
  String nPeopleGroups(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count People Groups',
      one: '1 People Group',
      zero: 'No People Groups',
    );
    return '$_temp0';
  }

  @override
  String get searchPeopleGroups => 'Search People Groups';

  @override
  String get profile => 'Profile';

  @override
  String get reminders => 'Reminders';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get retry => 'Retry';

  @override
  String get couldNotLoadPeopleGroupsMessage => 'Could not load people groups.';

  @override
  String get selectPeopleGroup => 'Select a people group';

  @override
  String get crossCulturalWorkersPresent => 'Cross-cultural workers present';

  @override
  String get workInLocalLanguageAndCulture =>
      'Work in local language & culture';

  @override
  String get discipleAndChurchMultiplication =>
      'Disciple & church multiplication';

  @override
  String get resources => 'Resources';

  @override
  String get bibleTranslation => 'Bible Translation';

  @override
  String get bibleStories => 'Bible Stories';

  @override
  String get jesusFilm => 'Jesus Film';

  @override
  String get radioBroadcast => 'Radio broadcast';

  @override
  String get gospelRecordings => 'Gospel recordings';

  @override
  String get audioScripture => 'Audio scripture';

  @override
  String get overview => 'Overview';

  @override
  String get prayerStatus => 'Prayer Status';

  @override
  String get peopleCommittedToPraying => 'People committed to praying';

  @override
  String get prayerCoverage24h => '24-Hour Prayer Coverage';

  @override
  String get peopleGroup => 'People Group';

  @override
  String get couldNotLoadPeopleGroupDetailsMessage =>
      'Could not load people group details.';

  @override
  String get share => 'Share';

  @override
  String get search => 'Search';

  @override
  String get country => 'Country';

  @override
  String get alternateName => 'Alternate name';

  @override
  String get population => 'Population';

  @override
  String get primaryLanguage => 'Primary language';

  @override
  String get primaryReligion => 'Primary religion';

  @override
  String get religiousPractices => 'Religious practices';

  @override
  String get setReminder => 'Set reminder';

  @override
  String get pauseAndPray => 'Pause & Pray';

  @override
  String get select => 'Select';

  @override
  String get selected => 'Selected';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get status => 'Status';

  @override
  String get engagementStatus => 'Engagement status';

  @override
  String get engaged => 'Engaged';

  @override
  String get adoptionStatus => 'Adoption Status';

  @override
  String get selectPeopleGroupConfirm =>
      'Do you want to select this people group?';

  @override
  String switchPeopleGroupConfirm(String currentName, String newName) {
    return 'Do you want to stop praying for $currentName and start praying for $newName?';
  }

  @override
  String get amen => 'Amen';

  @override
  String get noPeopleGroupSelected => 'Choose a people group to start praying.';

  @override
  String get couldNotLoadPrayerContent => 'Could not load prayer content.';

  @override
  String get noPrayerContentAvailable => 'No prayer content for today.';

  @override
  String get prayerThankYouTitle => 'Thank you for praying';

  @override
  String get prayerThankYouMessage =>
      'Your faithfulness in prayer matters. God hears you, and your prayers make a difference.';

  @override
  String get prayerThankYouVerse =>
      'Rejoice always, pray continually, give thanks in all circumstances; for this is God\'s will for you in Christ Jesus.';

  @override
  String get prayerThankYouVerseReference => '1 Thessalonians 5:16-18';

  @override
  String get prayedToday => 'Prayed today';

  @override
  String get prayerReminderTitle => 'Ready for today\'s prayer?';

  @override
  String prayerReminderBody(String peopleGroup) {
    return 'Tap to pray for $peopleGroup.';
  }

  @override
  String get dismissReminderLabel => 'Dismiss reminder';

  @override
  String get newReminder => 'New reminder';

  @override
  String get editReminder => 'Edit reminder';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get time => 'Time';

  @override
  String get daysOfWeek => 'Days of week';

  @override
  String get everyDay => 'Every day';

  @override
  String get noDaysSelected => 'No days selected';

  @override
  String get noRemindersYet => 'No reminders yet';

  @override
  String get reminderNotificationTitle => 'Time to pray';

  @override
  String get reminderNotificationBody => 'Open Doxa to start today\'s prayer.';

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
  String get exactAlarmsDisabledStatus =>
      'Exact alarms aren\'t allowed for Doxa, so your prayer reminders may arrive several minutes late.';

  @override
  String get allowExactAlarms => 'Allow exact alarms';

  @override
  String get exactAlarmsPromptBody =>
      'For your prayer reminders to arrive right on time, allow Doxa to use exact alarms.';

  @override
  String get allow => 'Allow';

  @override
  String get notNow => 'Not now';

  @override
  String get enableNotifications => 'Enable notifications';

  @override
  String get openSettings => 'Open settings';

  @override
  String get nextReminder => 'Next reminder';

  @override
  String nextReminderToday(String time) {
    return 'Today at $time';
  }

  @override
  String nextReminderTomorrow(String time) {
    return 'Tomorrow at $time';
  }

  @override
  String nextReminderOn(String weekday, String time) {
    return '$weekday at $time';
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
      other: '$countString reminders set',
      one: '1 reminder set',
      zero: 'No reminders set',
    );
    return '$_temp0';
  }

  @override
  String get dismissNextReminder => 'Dismiss next';

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
  String get newsSignupSuccessTitle => 'Thanks for signing up!';

  @override
  String newsSignupSuccessBody(String email) {
    return 'We\'ve sent a verification email to $email. Please open your inbox and tap the link to confirm your subscription.';
  }

  @override
  String get newsSignupError =>
      'Something went wrong. Please check your connection and try again.';

  @override
  String get enableNotificationsPromptBody =>
      'Enable notifications to also receive updates in push notifications.';

  @override
  String get enableNotificationsButton => 'Enable notifications';

  @override
  String get accountSectionTitle => 'Your account';

  @override
  String get emailVerified => 'Verified';

  @override
  String get emailUnverified => 'Not verified';

  @override
  String get resendVerification => 'Resend verification email';

  @override
  String get resendVerificationSent =>
      'Verification email sent. Check your inbox.';

  @override
  String resendVerificationCooldown(int seconds) {
    return 'Please wait ${seconds}s before requesting another email.';
  }

  @override
  String resendVerificationCountdown(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get signUp => 'Sign up';

  @override
  String get resendVerificationFailed =>
      'Couldn\'t send the email. Please try again.';

  @override
  String get viewProfile => 'View profile';

  @override
  String get emailsLoadError => 'Couldn\'t load your emails.';

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
  String get feedbackIntro =>
      'We\'d love to hear from you. Tell us what you think of the app.';

  @override
  String get feedbackTypeLabel => 'What kind of feedback?';

  @override
  String get feedbackTypeCompliment => 'Compliment';

  @override
  String get feedbackTypeSuggestion => 'Suggestion';

  @override
  String get feedbackTypeProblem => 'Problem';

  @override
  String get feedbackTypeRequired => 'Please choose a feedback type.';

  @override
  String get feedbackNameLabel => 'Name (optional)';

  @override
  String get feedbackMessageLabel => 'Message';

  @override
  String get feedbackMessageRequired => 'Please enter a message.';

  @override
  String get feedbackConsentLabel => 'Keep me updated with news from Doxa';

  @override
  String get feedbackSubmit => 'Send feedback';

  @override
  String get feedbackError =>
      'Something went wrong. Please check your connection and try again.';

  @override
  String get feedbackRateLimited =>
      'You\'ve sent a lot of feedback recently. Please try again later.';

  @override
  String get feedbackSuccessTitle => 'Thank you!';

  @override
  String feedbackSuccessBody(String email) {
    return 'Your feedback was sent as $email. If that isn\'t the right address, send it again with the correct one.';
  }

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
