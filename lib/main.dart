import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'components/misc/update_gate.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';
import 'services/analytics_service.dart';
import 'services/anon_signup_service.dart';
import 'services/crash_reporting_service.dart';
import 'services/identity_service.dart';
import 'services/install_referrer_service.dart';
import 'services/locale_controller.dart';
import 'services/pray_override_controller.dart';
import 'services/prayer_history_service.dart';
import 'services/profile_update_service.dart';
import 'services/push_notifications_service.dart';
import 'services/referral_controller.dart';
import 'services/reminders_controller.dart';
import 'services/reminders_notifications.dart';
import 'services/selected_people_group_controller.dart';
import 'services/update_controller.dart';
import 'services/wizard_completion_controller.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Crash reporting first: initialise Firebase and install the error handlers
  // before the rest of startup so crashes during bootstrap are captured too.
  await Firebase.initializeApp();
  await initCrashReporting();
  try {
    await dotenv.load();
  } catch (e) {
    developer.log(
      'failed to load .env (continuing with empty environment)',
      name: 'main',
      error: e,
    );
  }
  await initRemindersNotifications();
  await Future.wait([
    loadSelectedPeopleGroup(),
    refreshPrayedToday(),
    loadReminders(),
    loadWizardCompleted(),
    loadLocale(),
    loadIdentity(),
    loadReferredPeopleGroup(),
  ]);
  // Push notifications: init after identity is loaded so the first
  // OneSignal.login() uses the right external id. Receive-only for now; no
  // permission prompt here (that stays owned by the reminders flow). No-ops
  // cleanly when ONESIGNAL_APP_ID is unset.
  await initPushNotifications();
  // Android-only Play install-referrer lookup. Fire-and-forget after the persisted
  // referred slug is loaded, so it can't be clobbered; it updates the referral
  // controller within a second or two — before the user finishes the welcome step.
  unawaited(fetchInstallReferrer());
  installDeferredAnonSignupListener();
  installProfileUpdateListeners();
  // Revert the Pray tab to the user's own selection once they leave it after a
  // `/<slug>/prayer` deep link.
  attachPrayOverrideAutoClear();
  // Fire-and-forget: never block app start on the version check.
  checkForAppUpdate();
  // Record the cold-start app-open (foreground resumes are tracked in AppShell).
  trackAppOpen();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeController,
      builder: (context, locale, _) {
        return MaterialApp.router(
          title: 'Doxa Prayer',
          theme: AppTheme.light,
          routerConfig: appRouter,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: appLanguages.map((l) => l.locale),
          locale: locale,
          builder: (context, child) =>
              UpdateGate(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
