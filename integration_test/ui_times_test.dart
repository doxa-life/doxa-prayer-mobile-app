// Times every part of the UI, in milliseconds, and hands back a flat list of
// "element -> ms". Nothing else: no grading, no summary.
//
//   tool/perf/run_ui_times.sh
//
// One number per element: the time from the tap until the result is on screen
// and nothing is still animating (capped at 3s of animation). Each element is
// done 3 times; the number is the median. An element that can't be found or
// errors gets a note instead of a number, and the run carries on.
//
// Things that can't be undone or contact outside services (sending feedback,
// submitting the news signup, "Amen" on a prayer) are only opened, never sent.
// Select/unselect and save/delete reminder are done in pairs so the account ends
// up as it started.

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show SchedulerBinding;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:doxa_prayer_mobile_app/components/cards/add_people_group_card.dart';
import 'package:doxa_prayer_mobile_app/components/cards/people_group_list_card.dart';
import 'package:doxa_prayer_mobile_app/components/cards/reminder_card.dart';
import 'package:doxa_prayer_mobile_app/components/misc/share_people_group_modal.dart';
import 'package:doxa_prayer_mobile_app/main.dart' as app;
import 'package:doxa_prayer_mobile_app/router.dart';
import 'package:doxa_prayer_mobile_app/screens/feedback_screen.dart';
import 'package:doxa_prayer_mobile_app/screens/home_screen.dart';
import 'package:doxa_prayer_mobile_app/screens/news_signup_settings_screen.dart';
import 'package:doxa_prayer_mobile_app/screens/notification_permission_settings_screen.dart';
import 'package:doxa_prayer_mobile_app/screens/people_group_details_screen.dart';
import 'package:doxa_prayer_mobile_app/screens/people_group_map_screen.dart';
import 'package:doxa_prayer_mobile_app/screens/pray_screen.dart';
import 'package:doxa_prayer_mobile_app/screens/reminders_screen.dart';
import 'package:doxa_prayer_mobile_app/screens/settings_screen.dart';
import 'package:doxa_prayer_mobile_app/services/wizard_completion_controller.dart';

import '../test_driver/screenshot_scenario.dart'
    show seedState, installOverlayGuards;

const int _reps = 3;

/// Steps that can send the app to the background (notification permission
/// prompts, iOS Settings) or change data. Off by default; see run_ui_times.sh
/// --include-risky.
const bool _risky = bool.fromEnvironment('UI_RISKY');

/// Progress goes to the console as it happens, so if the app dies the log shows
/// exactly which step it was on.
// ignore: avoid_print
void _log(String s) => print('UI_TIMES $s');
const Duration _loadTimeout = Duration(seconds: 20);
const Duration _animCap = Duration(seconds: 3);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  WidgetsApp.debugAllowBannerOverride = false;

  testWidgets('ui times', (tester) async {
    final rows = <Map<String, Object?>>[];

    bool animating() =>
        SchedulerBinding.instance.transientCallbackCount > 0 ||
        SchedulerBinding.instance.hasScheduledFrame;

    Future<void> pumpUntil(Finder f) async {
      final end = DateTime.now().add(_loadTimeout);
      while (!tester.any(f) && DateTime.now().isBefore(end)) {
        await tester.pump(const Duration(milliseconds: 16));
      }
    }

    Future<void> settleQuietly() async {
      final end = DateTime.now().add(_animCap);
      do {
        await tester.pump(const Duration(milliseconds: 16));
      } while (animating() && DateTime.now().isBefore(end));
    }

    Future<void> safe(Future<void> Function()? f) async {
      if (f == null) return;
      try {
        await f();
        await settleQuietly();
      } catch (_) {}
    }

    // Closes a sheet, menu or dialog by tapping outside it.
    Future<void> dismiss() async {
      await tester.tapAt(const Offset(4, 120));
      await settleQuietly();
    }

    Future<void> back() async {
      await tester.tap(find.byTooltip('Back').first);
    }

    /// Times one action [_reps] times and records the median.
    /// [before] / [undo] run outside the timing to set up and restore state.
    Future<void> step(
      String element,
      Future<void> Function() action, {
      Finder? ready,
      Future<void> Function()? before,
      Future<void> Function()? undo,
      int reps = _reps,
    }) async {
      final times = <double>[];
      String? note;
      _log('START $element');
      for (var i = 0; i < reps; i++) {
        await safe(before);
        await Future<void>.delayed(const Duration(milliseconds: 300));
        await tester.pump();
        final sw = Stopwatch()..start();
        try {
          await action();
          await tester.pump();
          double? readyAt;
          final loadEnd = DateTime.now().add(_loadTimeout);
          final animEnd = DateTime.now().add(_animCap);
          var waiting = ready != null;
          while (true) {
            if (waiting && tester.any(ready!)) {
              readyAt = sw.elapsedMicroseconds / 1000;
              waiting = false;
            }
            if (!waiting && !animating()) {
              times.add(sw.elapsedMicroseconds / 1000);
              break;
            }
            final now = DateTime.now();
            if (waiting && now.isAfter(loadEnd)) {
              note = 'timed out waiting for the screen';
              break;
            }
            if (!waiting && now.isAfter(animEnd)) {
              // Something loops forever (a shimmer): use when the content
              // appeared, else the cap.
              times.add(readyAt ?? sw.elapsedMicroseconds / 1000);
              note ??= 'still animating after 3s';
              break;
            }
            await tester.pump(const Duration(milliseconds: 4));
          }
        } catch (e) {
          note = e.toString().split('\n').first;
          if (note.contains('Bad state') || note.contains('zero elements')) {
            note = 'not found';
          }
          break;
        }
        await safe(undo);
      }
      times.sort();
      final ms = times.isEmpty ? null : times[times.length ~/ 2];
      _log('DONE  $element = ${ms?.round()}${note == null ? '' : ' ($note)'}');
      rows.add({'element': element, 'ms': ms, 'note': ?note});
    }

    Future<void> tapText(String t) => tester.tap(find.text(t).first);
    Future<void> tapTip(String t) => tester.tap(find.byTooltip(t).first);
    Future<void> tapIcon(IconData i) => tester.tap(find.byIcon(i).first);

    Future<void> go(String path, Finder ready) async {
      appRouter.go(path);
      await pumpUntil(ready);
      await settleQuietly();
    }

    final home = find.byType(HomeScreen);
    final pray = find.byType(PrayScreen);
    final reminders = find.byType(RemindersScreen);
    final details = find.byType(PeopleGroupDetailsScreen);
    final cards = find.byType(PeopleGroupListCard);
    final settings = find.byType(SettingsScreen);

    // ---- Onboarding wizard (best effort) ----------------------------------
    await seedState();
    {
      final sw = Stopwatch()..start();
      await app.main();
      installOverlayGuards();
      final wizardStep = find.byWidgetPredicate(
        (w) => w.runtimeType.toString().startsWith('WizardStep'),
      );
      await pumpUntil(wizardStep);
      rows.add({
        'element': 'Wizard: first screen shown (from app start)',
        'ms': sw.elapsedMicroseconds / 1000,
      });
      _log('DONE  Wizard first screen');
      // The frame test sat on this screen for 3s before moving on and ran fine;
      // do the same, and log each stage so a death names the stage.
      final idleEnd = DateTime.now().add(const Duration(seconds: 3));
      while (DateTime.now().isBefore(idleEnd)) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      _log('wizard idle finished');

      // Walk forward with whatever main button each step offers.
      for (var i = 1; _risky && i <= 8 && !tester.any(home); i++) {
        final stepName = tester.any(wizardStep)
            ? tester.widget(wizardStep.first).runtimeType.toString()
            : 'unknown';
        final select = find.text('Select');
        final buttons = find.byWidgetPredicate(
          (w) =>
              (w.runtimeType.toString() == 'ActionButton' ||
                  w.runtimeType.toString() == 'CtaButton') &&
              (w is StatelessWidget),
        );
        final target = tester.any(select) ? select.first : buttons.first;
        if (!tester.any(target)) break;
        final before = wizardStep.evaluate().isEmpty
            ? null
            : tester.widget(wizardStep.first).runtimeType;
        final t = Stopwatch()..start();
        try {
          await tester.tap(target);
          final end = DateTime.now().add(_animCap);
          do {
            await tester.pump(const Duration(milliseconds: 8));
          } while (animating() && DateTime.now().isBefore(end));
          rows.add({
            'element': 'Wizard: $stepName -> next',
            'ms': t.elapsedMicroseconds / 1000,
            if (before != null &&
                tester.any(wizardStep) &&
                tester.widget(wizardStep.first).runtimeType == before)
              'note': 'screen did not change',
          });
        } catch (e) {
          rows.add({
            'element': 'Wizard: $stepName -> next',
            'ms': null,
            'note': 'not found',
          });
          break;
        }
      }
      if (!tester.any(home)) {
        final t = Stopwatch()..start();
        _log('marking wizard completed');
        await markWizardCompleted();
        _log('wizard marked completed; waiting for Home');
        await pumpUntil(home);
        _log('Home is showing');
        rows.add({
          'element': 'Wizard: finish -> Home (forced)',
          'ms': t.elapsedMicroseconds / 1000,
        });
      }
      await settleQuietly();
    }

    // ---- Bottom navigation -------------------------------------------------
    Future<void> toHome() => go('/home', home);
    await step('Bottom nav: Pray', () => tapText('PRAY'), ready: pray, before: toHome);
    await step(
      'Bottom nav: Search',
      () => tapText('SEARCH'),
      ready: cards,
      before: toHome,
    );
    await step(
      'Bottom nav: Reminders',
      () => tapText('REMINDERS'),
      ready: reminders,
      before: toHome,
    );
    await step(
      'Bottom nav: Home',
      () => tapText('HOME'),
      ready: home,
      before: () => go('/pray', pray),
    );

    // ---- Home --------------------------------------------------------------
    await toHome();
    await step(
      'Home: carousel Pray button',
      () => tapText('PRAY'),
      ready: pray,
      before: toHome,
    );
    await step(
      'Home: carousel Profile button',
      () => tapText('PROFILE'),
      ready: details,
      before: toHome,
      undo: back,
    );
    await step(
      'Home: carousel Share button (open)',
      () => tapText('SHARE'),
      ready: find.byType(SharePeopleGroupModal),
      before: toHome,
      undo: dismiss,
    );
    await step(
      'Home: carousel Map button',
      () => tapText('MAP'),
      ready: find.byType(PeopleGroupMapScreen),
      before: toHome,
      undo: back,
    );
    await step(
      'Home: add people group card',
      () => tester.tap(find.byType(AddPeopleGroupCard).first),
      ready: cards,
      before: toHome,
    );

    // ---- Settings ----------------------------------------------------------
    Future<void> openSettings() => tapTip('Settings');
    await toHome();
    await step(
      'Top bar: Settings button',
      openSettings,
      ready: settings,
      before: toHome,
      undo: back,
    );
    await step(
      'Settings: Back button',
      back,
      ready: home,
      before: () async {
        await toHome();
        await openSettings();
        await pumpUntil(settings);
      },
    );
    await toHome();
    await openSettings();
    await pumpUntil(settings);
    await step(
      'Settings: Language field (open)',
      () => tester.tap(find.byType(DropdownButtonFormField<Locale>).first),
      undo: dismiss,
    );
    await step(
      'Settings: Sign up for updates row',
      () => tapText('Sign up for updates'),
      ready: find.byType(NewsSignupSettingsScreen),
      undo: back,
    );
    await step(
      'Settings: Notifications row',
      () => tapText('Notifications'),
      ready: find.byType(NotificationPermissionSettingsScreen),
      undo: back,
    );
    await step(
      'Settings: Feedback row',
      () => tapText('Feedback'),
      ready: find.byType(FeedbackScreen),
      undo: back,
    );
    await toHome();

    // ---- Pray tab ----------------------------------------------------------
    await go('/pray', pray);
    final switchTip = find.byWidgetPredicate(
      (w) => w is Tooltip && (w.message ?? '').startsWith('Switch to'),
    );
    await step(
      'Pray: group switcher (open)',
      () => tester.tap(switchTip.first),
      undo: () => tester.tap(switchTip.first),
    );
    await step(
      'Pray: Previous day',
      () => tapTip('Previous day'),
      undo: () => tapTip('Next day'),
    );
    await step(
      'Pray: Next day',
      () => tapTip('Next day'),
      undo: () => tapTip('Previous day'),
    );

    // ---- Search page -------------------------------------------------------
    await go('/people-groups', cards);
    final field = find.byType(TextField).first;
    Future<void> clearText() => tester.enterText(field, '');
    for (final q in ['a', 'india', 'muslim']) {
      await step(
        'Search: type "$q"',
        () => tester.enterText(field, q),
        before: clearText,
      );
    }
    await step(
      'Search: Clear (x) button',
      () => tapTip('Clear search'),
      before: () => tester.enterText(field, 'india'),
    );
    await clearText();

    final tune = find.byIcon(Icons.tune);
    await step(
      'Search: Filters button (open panel)',
      () => tester.tap(tune.first),
      undo: () => tester.tap(tune.first),
    );
    await step(
      'Search: Filters button (close panel)',
      () => tester.tap(tune.first),
      before: () => tester.tap(tune.first),
    );
    // Filter sections live in the open panel.
    await tester.tap(tune.first);
    await settleQuietly();
    for (final section in [
      'Primary language',
      'Primary religion',
      'Country',
    ]) {
      await step(
        'Search filter: $section (open picker)',
        () => tapText(section),
        undo: dismiss,
      );
    }
    await step(
      'Search filter: Population (expand)',
      () => tapText('Population'),
      undo: () => tapText('Population'),
    );
    await step(
      'Search filter: Status "Engaged"',
      () => tapText('Engaged'),
      undo: () => tapText('Engaged'),
    );
    await step(
      'Search filter: fewest-intercessors checkbox',
      () => tapText('Prioritize groups with the fewest intercessors'),
      undo: () => tapText('Prioritize groups with the fewest intercessors'),
    );
    await tester.tap(tune.first);
    await settleQuietly();

    await step(
      'Search: sort button',
      () => tapIcon(Icons.arrow_downward),
      undo: () => tapIcon(Icons.arrow_downward),
    );
    final listScroll = find
        .ancestor(of: cards.first, matching: find.byType(Scrollable))
        .first;
    await step(
      'Search: list drag (300px)',
      () => tester.drag(listScroll, const Offset(0, -300)),
      undo: () => tester.drag(listScroll, const Offset(0, 300)),
    );
    await step(
      'Search: tap a group card (open details)',
      () => tester.tap(cards.first),
      ready: details,
      before: () => go('/people-groups', cards),
      undo: back,
    );

    // ---- Group details -----------------------------------------------------
    await go('/people-groups', cards);
    await tester.tap(cards.first);
    await pumpUntil(details);
    await settleQuietly();
    await step(
      'Details: Select/Unselect button (toggle, then toggle back)',
      () => tapText(tester.any(find.text('Select')) ? 'Select' : 'Unselect'),
      undo: () async {
        await tapText(tester.any(find.text('Select')) ? 'Select' : 'Unselect');
      },
      reps: 1,
    );
    await step(
      'Details: Back button',
      back,
      ready: cards,
      before: () async {
        if (!tester.any(details)) {
          await go('/people-groups', cards);
          await tester.tap(cards.first);
          await pumpUntil(details);
        }
      },
    );

    // ---- Reminders ---------------------------------------------------------
    await go('/reminders', reminders);
    final editorOpen = find.text('Days of week');
    await step(
      'Reminders: New reminder button (open editor)',
      () => tapTip('New reminder'),
      ready: editorOpen,
      undo: dismiss,
    );
    await step(
      'Reminders: Time field (open picker)',
      () => tapIcon(Icons.access_time),
      before: () async {
        await tapTip('New reminder');
        await pumpUntil(editorOpen);
      },
      undo: () async {
        await dismiss();
        await dismiss();
      },
      reps: 2,
    );
    if (_risky) {
    await tapTip('New reminder');
      await pumpUntil(editorOpen);
      await settleQuietly();
      await step('Reminders: Save (new reminder)', () => tapText('Save'), reps: 1);
      await step(
        'Reminders: tap a reminder (open editor)',
        () => tester.tap(find.byType(ReminderCard).last),
        ready: find.text('Delete'),
        reps: 1,
      );
      await step('Reminders: Delete', () => tapText('Delete'), reps: 1);
    }

    // ---- Map ---------------------------------------------------------------
    await step(
      'Map: open screen (not tiles)',
      () async => appRouter.go('/people-groups/adi/map'),
      ready: find.byType(PeopleGroupMapScreen),
      before: toHome,
    );
    await toHome();

    binding.reportData = {
      'os': '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
      'rows': rows,
    };
  }, timeout: const Timeout(Duration(minutes: 15)));
}
