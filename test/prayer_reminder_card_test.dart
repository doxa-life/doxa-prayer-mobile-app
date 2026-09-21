import 'package:doxa_prayer_mobile_app/components/cards/prayer_reminder_card.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:doxa_prayer_mobile_app/services/prayer_history_service.dart';
import 'package:doxa_prayer_mobile_app/services/prayer_reminder_controller.dart';
import 'package:doxa_prayer_mobile_app/services/subscribed_people_groups_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

/// A preferences store whose writes take long enough to cross a frame, the way
/// a real device's do. With the instant in-memory store, a widget dismissed
/// before an awaited write is still mounted when the write returns, which hides
/// exactly the kind of use-after-dismiss this card has to survive.
final class _SlowWritePreferences extends InMemorySharedPreferencesAsync {
  _SlowWritePreferences() : super.empty();

  @override
  Future<bool> setString(
    String key,
    String value,
    SharedPreferencesOptions options,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return super.setString(key, value, options);
  }
}

const _kurds = SubscribedPeopleGroup(slug: 'kurds', name: 'Kurds');
const _hui = SubscribedPeopleGroup(slug: 'hui', name: 'Hui');

/// Mirrors the home screen's reminder slot: the card lives inside a builder
/// that drops it as soon as there is no group left to nudge about, so
/// dismissing really does take it out of the tree.
Widget _wrap({SubscribedPeopleGroup? group}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => Scaffold(
          body: ListenableBuilder(
            listenable: Listenable.merge([
              peopleGroupsController,
              prayedTodayController,
              prayerReminderDismissedController,
            ]),
            builder: (_, _) {
              final needsPrayer = group ?? peopleGroupNeedingPrayer();
              if (needsPrayer == null) return const Text('no nudge');
              return PrayerReminderCard(group: needsPrayer);
            },
          ),
        ),
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

void _reset() {
  // setActivePeopleGroup persists through SharedPreferencesAsync, which
  // setMockInitialValues does not reach.
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.empty();
  peopleGroupsController.value = SubscribedPeopleGroups.empty;
  prayedTodayController.value = <String>{};
  prayerReminderDismissedController.value = <String>{};
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(_reset);
  tearDown(_reset);

  group('the card', () {
    testWidgets('names the people group', (tester) async {
      await tester.pumpWidget(_wrap(group: _kurds));
      await tester.pumpAndSettle();

      expect(find.text("Ready for today's prayer?"), findsOneWidget);
      expect(find.text('Tap to pray for Kurds.'), findsOneWidget);
    });

    testWidgets('dismiss "×" silences that group for the session', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(group: _kurds));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(prayerReminderDismissedController.value, {'kurds'});
    });

    testWidgets('tapping navigates to the Pray tab and silences that group', (
      tester,
    ) async {
      peopleGroupsController.value = const SubscribedPeopleGroups(
        list: [_kurds, _hui],
        activeSlug: 'kurds',
      );
      await tester.pumpWidget(_wrap(group: _kurds));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Ready for today's prayer?"));
      await tester.pumpAndSettle();

      expect(find.text('pray screen'), findsOneWidget);
      // Coming back to the home screen must not show this group's nudge again.
      expect(prayerReminderDismissedController.value, {'kurds'});
    });

    testWidgets('tapping a group that is not the active one still navigates', (
      tester,
    ) async {
      // Regression: selecting the group is a persisted, awaited write, and
      // dismissing the nudge takes the card out of the tree — so navigating
      // must not depend on the card's own BuildContext surviving the write.
      // Letting the slot pick the group is the point: it is what unmounts the
      // card once that group is dealt with.
      SharedPreferencesAsyncPlatform.instance = _SlowWritePreferences();
      peopleGroupsController.value = const SubscribedPeopleGroups(
        list: [_kurds, _hui],
        activeSlug: 'kurds',
      );
      prayedTodayController.value = {'kurds'};
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(find.text('Tap to pray for Hui.'), findsOneWidget);

      await tester.tap(find.text("Ready for today's prayer?"));
      // A frame between the dismiss and the write landing, as on a device: the
      // slot has already dropped the card by the time the write returns.
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('pray screen'), findsOneWidget);
      expect(activePeopleGroup?.slug, 'hui');
    });
  });

  group('peopleGroupNeedingPrayer', () {
    test('is null with no subscriptions', () {
      expect(peopleGroupNeedingPrayer(), isNull);
    });

    test('starts at the first subscription, whichever group is active', () {
      peopleGroupsController.value = const SubscribedPeopleGroups(
        list: [_kurds, _hui],
        activeSlug: 'hui',
      );

      expect(peopleGroupNeedingPrayer()?.slug, 'kurds');
    });

    test('moves on to the next group once the first is prayed for', () {
      peopleGroupsController.value = const SubscribedPeopleGroups(
        list: [_kurds, _hui],
      );
      prayedTodayController.value = {'kurds'};

      expect(peopleGroupNeedingPrayer()?.slug, 'hui');
    });

    test('moves on to the next group once the first is dismissed', () {
      peopleGroupsController.value = const SubscribedPeopleGroups(
        list: [_kurds, _hui],
      );
      dismissPrayerReminder('kurds');

      expect(peopleGroupNeedingPrayer()?.slug, 'hui');
    });

    test('is null once every group is prayed for', () {
      peopleGroupsController.value = const SubscribedPeopleGroups(
        list: [_kurds, _hui],
        activeSlug: 'kurds',
      );
      prayedTodayController.value = {'kurds', 'hui'};

      expect(peopleGroupNeedingPrayer(), isNull);
    });

    test('is null once every group is prayed for or dismissed', () {
      peopleGroupsController.value = const SubscribedPeopleGroups(
        list: [_kurds, _hui],
        activeSlug: 'kurds',
      );
      prayedTodayController.value = {'kurds'};
      dismissPrayerReminder('hui');

      expect(peopleGroupNeedingPrayer(), isNull);
    });
  });
}
