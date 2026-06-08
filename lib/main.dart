import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'components/misc/update_gate.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';
import 'services/anon_signup_service.dart';
import 'services/identity_service.dart';
import 'services/locale_controller.dart';
import 'services/profile_update_service.dart';
import 'services/reminders_controller.dart';
import 'services/reminders_notifications.dart';
import 'services/selected_people_group_controller.dart';
import 'services/update_controller.dart';
import 'services/wizard_completion_controller.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    loadReminders(),
    loadWizardCompleted(),
    loadLocale(),
    loadIdentity(),
  ]);
  installDeferredAnonSignupListener();
  installProfileUpdateListeners();
  // Fire-and-forget: never block app start on the version check.
  checkForAppUpdate();
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
