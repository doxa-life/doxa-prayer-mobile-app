import 'package:doxa_prayer_mobile_app/components/misc/prayer_reminder_banner.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:doxa_prayer_mobile_app/services/prayer_history_service.dart';
import 'package:doxa_prayer_mobile_app/services/prayer_reminder_controller.dart';
import 'package:doxa_prayer_mobile_app/services/selected_people_group_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _group = SelectedPeopleGroup(slug: 'kurds', name: 'Kurds', imageUrl: null);

Widget _wrap() {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const PrayerReminderBanner(
          child: Scaffold(body: Text('home content')),
        ),
      ),
      // Named 'pray' to match the AppRoute.pray.name target the banner tap uses.
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
  setUp(() {
    selectedPeopleGroupController.value = null;
    prayedTodayController.value = <String>{};
    prayerReminderDismissedController.value = false;
  });

  tearDown(() {
    selectedPeopleGroupController.value = null;
    prayedTodayController.value = <String>{};
    prayerReminderDismissedController.value = false;
  });

  testWidgets('hidden when no people group is selected', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('home content'), findsOneWidget);
    expect(find.text("Ready for today's prayer?"), findsNothing);
  });

  testWidgets('hidden when the user has already prayed today', (tester) async {
    selectedPeopleGroupController.value = _group;
    prayedTodayController.value = {'kurds'};
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text("Ready for today's prayer?"), findsNothing);
  });

  testWidgets('shown with group name when selected and not prayed', (
    tester,
  ) async {
    selectedPeopleGroupController.value = _group;
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text("Ready for today's prayer?"), findsOneWidget);
    expect(find.text('Tap to pray for Kurds.'), findsOneWidget);
    expect(find.text('home content'), findsOneWidget); // content still behind it
  });

  testWidgets('dismiss "×" hides the banner for the session', (tester) async {
    selectedPeopleGroupController.value = _group;
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();
    expect(find.text("Ready for today's prayer?"), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text("Ready for today's prayer?"), findsNothing);
    expect(prayerReminderDismissedController.value, isTrue);
  });

  testWidgets('tapping the banner navigates to the Pray tab', (tester) async {
    selectedPeopleGroupController.value = _group;
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text("Ready for today's prayer?"));
    await tester.pumpAndSettle();

    expect(find.text('pray screen'), findsOneWidget);
  });
}
