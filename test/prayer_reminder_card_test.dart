import 'package:doxa_prayer_mobile_app/components/cards/prayer_reminder_card.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:doxa_prayer_mobile_app/services/prayer_reminder_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Widget _wrap() {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) =>
            const Scaffold(body: PrayerReminderCard(peopleGroupName: 'Kurds')),
      ),
      // Named 'pray' to match the AppRoute.pray.name target the card tap uses.
      GoRoute(
        name: 'pray',
        path: '/pray',
        builder: (_, _) => const Scaffold(body: Text('pray screen')),
      ),
    ],
  );
  return MaterialApp.router(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: router,
  );
}

void main() {
  setUp(() => prayerReminderDismissedController.value = false);
  tearDown(() => prayerReminderDismissedController.value = false);

  testWidgets('names the people group', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text("Ready for today's prayer?"), findsOneWidget);
    expect(find.text('Tap to pray for Kurds.'), findsOneWidget);
  });

  testWidgets('dismiss "×" marks the reminder dismissed for the session', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(prayerReminderDismissedController.value, isTrue);
  });

  testWidgets('tapping the card navigates to the Pray tab and dismisses it', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text("Ready for today's prayer?"));
    await tester.pumpAndSettle();

    expect(find.text('pray screen'), findsOneWidget);
    // Coming back to the home screen must not show the nudge again.
    expect(prayerReminderDismissedController.value, isTrue);
  });
}
