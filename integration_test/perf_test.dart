// Performance harness: drives the REAL app through every screen and records,
// per scenario, frame timings (build / raster / total), wall-clock timings
// ("time to content"), and memory.
//
// Run it through the tooling, on a real device in PROFILE mode:
//   tool/perf/run_perf.sh
// Numbers from a debug build or the Simulator are not comparable and the
// script refuses to produce them by default.
//
// Results leave the device through `binding.reportData`, and the host driver
// (test_driver/perf_driver.dart) writes them to disk as JSON. tool/perf/report.dart
// turns that into a table and a comparison against the saved baseline.
//
// Adding a scenario: add a `await run(...)` call in the matching group below.
// Keep scenario names stable (they are the key the baseline is compared on).

import 'dart:io' show Platform, ProcessInfo;
import 'dart:math' as math;
import 'dart:ui' show FrameTiming;

import 'package:flutter/foundation.dart' show kProfileMode, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show SchedulerBinding;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:doxa_prayer_mobile_app/components/cards/people_group_list_card.dart';
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
import 'package:doxa_prayer_mobile_app/screens/wizard_screen.dart';
import 'package:doxa_prayer_mobile_app/services/wizard_completion_controller.dart';

import '../test_driver/screenshot_scenario.dart' show seedState, installOverlayGuards;

// Set by tool/perf/run_perf.sh via --dart-define.
const String _gitSha = String.fromEnvironment('PERF_GIT_SHA');
const String _gitDirty = String.fromEnvironment('PERF_GIT_DIRTY');
const String _label = String.fromEnvironment('PERF_LABEL');
const String _flavor = String.fromEnvironment('PERF_FLAVOR');
const bool _skipMap = bool.fromEnvironment('PERF_SKIP_MAP');

/// How long to wait for a screen's content before recording a timeout.
const Duration _contentTimeout = Duration(seconds: 20);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Frames are produced as fast as the device wants them, not one per pump().
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  WidgetsApp.debugAllowBannerOverride = false;

  testWidgets('performance walkthrough', (tester) async {
    final results = <Map<String, Object?>>[];
    final recorder = _FrameRecorder();

    /// Runs [body] as one named scenario and records everything about it.
    /// [body] gets a [_Scenario] to drop named time marks on ("first card").
    Future<void> run(
      String group,
      String name,
      Future<void> Function(_Scenario s) body,
    ) async {
      // Let the previous scenario's frames and async work drain first, so they
      // are not billed to this one.
      await _pumpFor(tester, const Duration(milliseconds: 400));
      final rssBefore = ProcessInfo.currentRss;
      final imagesBefore = PaintingBinding.instance.imageCache.currentSizeBytes;
      final scenario = _Scenario(tester);
      recorder.start();
      scenario.watch.start();
      Object? error;
      try {
        await body(scenario);
      } catch (e) {
        error = e;
      }
      scenario.watch.stop();
      // FrameTiming is delivered in batches; give the last batch time to land.
      await _pumpFor(tester, const Duration(milliseconds: 300));
      final frames = recorder.stop();
      results.add({
        'group': group,
        'name': name,
        'wallMs': scenario.watch.elapsedMicroseconds / 1000,
        'marks': scenario.marks,
        'timedOut': scenario.timedOut,
        if (error != null) 'error': error.toString(),
        'frames': frames.toJson(_budgetMs()),
        'rssMb': ProcessInfo.currentRss / (1024 * 1024),
        'rssDeltaMb': (ProcessInfo.currentRss - rssBefore) / (1024 * 1024),
        'imageCacheMb':
            PaintingBinding.instance.imageCache.currentSizeBytes /
            (1024 * 1024),
        'imageCacheDeltaMb':
            (PaintingBinding.instance.imageCache.currentSizeBytes -
                imagesBefore) /
            (1024 * 1024),
      });
    }

    // ---- Boot, onboarding, and the move into the app -----------------------
    // Start un-onboarded so the wizard is measured, then complete it in-run
    // (the router redirects /wizard -> /home), exactly like the screenshots.
    await seedState();

    await run('startup', 'app_main_to_wizard', (s) async {
      await app.main();
      installOverlayGuards();
      await s.waitFor(find.byType(WizardScreen), mark: 'wizard_visible');
    });

    await run('startup', 'wizard_idle_3s', (s) async {
      await _pumpFor(tester, const Duration(seconds: 3));
    });

    await run('startup', 'wizard_to_home', (s) async {
      await markWizardCompleted();
      await s.waitFor(find.byType(HomeScreen), mark: 'home_visible');
      await _pumpFor(tester, const Duration(seconds: 2));
    });

    // ---- Home --------------------------------------------------------------
    await run('home', 'home_idle_3s', (s) async {
      // A static screen. Anything above ~0 frames here is a background
      // animation or a leaking ticker (skeleton pulses, shimmer...).
      await _pumpFor(tester, const Duration(seconds: 3));
    });
    await run('home', 'home_scroll', (s) async {
      await _scrollBothWays(tester, find.byType(Scrollable), flings: 3);
    });

    // ---- Tab switching -----------------------------------------------------
    // Time to content for each bottom-nav destination.
    await run('tabs', 'tab_pray', (s) async {
      appRouter.go('/pray');
      await s.waitFor(find.byType(PrayScreen), mark: 'screen_visible');
      await _pumpFor(tester, const Duration(seconds: 2));
    });
    await run('tabs', 'pray_scroll', (s) async {
      await _scrollBothWays(tester, find.byType(Scrollable), flings: 3);
    });
    await run('tabs', 'tab_reminders', (s) async {
      appRouter.go('/reminders');
      await s.waitFor(find.byType(RemindersScreen), mark: 'screen_visible');
      await _pumpFor(tester, const Duration(seconds: 1));
    });
    await run('tabs', 'reminders_scroll', (s) async {
      await _scrollBothWays(tester, find.byType(Scrollable), flings: 2);
    });
    await run('tabs', 'tab_home', (s) async {
      appRouter.go('/home');
      await s.waitFor(find.byType(HomeScreen), mark: 'screen_visible');
    });

    // ---- Search page (the one that prompted this harness) ------------------
    await run('search', 'open_search_tab', (s) async {
      appRouter.go('/people-groups');
      await s.waitFor(
        find.byType(PeopleGroupListCard),
        mark: 'first_card_visible',
      );
      await _pumpFor(tester, const Duration(seconds: 2));
    });
    await run('search', 'search_idle_3s', (s) async {
      await _pumpFor(tester, const Duration(seconds: 3));
    });

    final cards = find.byType(PeopleGroupListCard);
    // The list's own scrollable: the nearest Scrollable above a card.
    final listScrollable = find
        .ancestor(of: cards.first, matching: find.byType(Scrollable))
        .first;

    await run('search', 'scroll_down_slow', (s) async {
      for (var i = 0; i < 4; i++) {
        await tester.fling(listScrollable, const Offset(0, -300), 600);
        await _pumpFor(tester, const Duration(milliseconds: 900));
      }
    });
    await run('search', 'scroll_down_fast', (s) async {
      for (var i = 0; i < 5; i++) {
        await tester.fling(listScrollable, const Offset(0, -500), 3500);
        await _pumpFor(tester, const Duration(milliseconds: 1400));
      }
    });
    await run('search', 'scroll_up_fast', (s) async {
      for (var i = 0; i < 5; i++) {
        await tester.fling(listScrollable, const Offset(0, 500), 3500);
        await _pumpFor(tester, const Duration(milliseconds: 1400));
      }
    });
    await run('search', 'scroll_deep_then_back', (s) async {
      // Past the first screenfuls, where cards are built for the first time
      // and the image cache has to evict, then straight back to the top.
      for (var i = 0; i < 12; i++) {
        await tester.fling(listScrollable, const Offset(0, -600), 4500);
        await _pumpFor(tester, const Duration(milliseconds: 700));
      }
      for (var i = 0; i < 12; i++) {
        await tester.fling(listScrollable, const Offset(0, 600), 4500);
        await _pumpFor(tester, const Duration(milliseconds: 700));
      }
    });
    await run('search', 'drag_slowly_200px_steps', (s) async {
      // Finger-tracking scroll (no fling): the case where every frame must
      // build the next card as it creeps into view.
      for (var i = 0; i < 20; i++) {
        await tester.drag(listScrollable, const Offset(0, -200));
        await _pumpFor(tester, const Duration(milliseconds: 100));
      }
    });
    // Back to the top, unmeasured, so typing starts from a known state.
    for (var i = 0; i < 6; i++) {
      await tester.fling(listScrollable, const Offset(0, 800), 6000);
      await _pumpFor(tester, const Duration(milliseconds: 600));
    }

    // Typing, one keystroke per scenario so a slow query stands out.
    final searchField = find.byType(TextField).first;
    var typed = '';
    for (final query in ['a', 'al', 'ind', 'india', 'muslim']) {
      typed = query;
      await run('search', 'type_$typed', (s) async {
        await tester.enterText(searchField, typed);
        await _pumpFor(tester, const Duration(milliseconds: 400));
      });
    }
    await run('search', 'scroll_while_filtered', (s) async {
      await _scrollBothWays(
        tester,
        find
            .ancestor(of: cards.first, matching: find.byType(Scrollable))
            .first,
        flings: 2,
      );
    });
    await run('search', 'clear_search', (s) async {
      await tester.enterText(searchField, '');
      await _pumpFor(tester, const Duration(milliseconds: 600));
    });

    // Filter panel and sort.
    await run('search', 'filter_panel_open', (s) async {
      await _tapIfPresent(tester, find.byIcon(Icons.tune));
      await _pumpFor(tester, const Duration(milliseconds: 800));
    });
    await run('search', 'filter_panel_idle_2s', (s) async {
      await _pumpFor(tester, const Duration(seconds: 2));
    });
    await run('search', 'filter_panel_close', (s) async {
      await _tapIfPresent(tester, find.byIcon(Icons.tune));
      await _pumpFor(tester, const Duration(milliseconds: 800));
    });
    await run('search', 'sort_toggle', (s) async {
      await _tapIfPresent(tester, find.byIcon(Icons.arrow_downward));
      await _pumpFor(tester, const Duration(milliseconds: 1200));
    });
    await run('search', 'sort_toggle_back', (s) async {
      await _tapIfPresent(tester, find.byIcon(Icons.arrow_downward));
      await _pumpFor(tester, const Duration(milliseconds: 1200));
    });

    // ---- People group details ---------------------------------------------
    await run('details', 'open_details_from_card', (s) async {
      await tester.tap(find.byType(PeopleGroupListCard).first);
      await s.waitFor(
        find.byType(PeopleGroupDetailsScreen),
        mark: 'screen_visible',
      );
      await _pumpFor(tester, const Duration(seconds: 3));
    });
    await run('details', 'details_scroll', (s) async {
      await _scrollBothWays(
        tester,
        find
            .descendant(
              of: find.byType(PeopleGroupDetailsScreen),
              matching: find.byType(Scrollable),
            )
            .first,
        flings: 3,
      );
    });
    await run('details', 'details_back_to_search', (s) async {
      appRouter.pop();
      await s.waitFor(
        find.byType(PeopleGroupListCard),
        mark: 'list_visible',
      );
    });

    // ---- Map (Mapbox tiles; slow and network-bound) ------------------------
    if (!_skipMap) {
      await run('map', 'open_map', (s) async {
        appRouter.go('/people-groups/adi/map');
        await s.waitFor(
          find.byType(PeopleGroupMapScreen),
          mark: 'screen_visible',
        );
        await _pumpFor(tester, const Duration(seconds: 12));
      });
      await run('map', 'map_pan', (s) async {
        final map = find.byType(PeopleGroupMapScreen);
        for (var i = 0; i < 6; i++) {
          await tester.drag(map, Offset(i.isEven ? -150 : 150, 60));
          await _pumpFor(tester, const Duration(milliseconds: 500));
        }
      });
      await run('map', 'map_leave', (s) async {
        appRouter.go('/home');
        await s.waitFor(find.byType(HomeScreen), mark: 'home_visible');
      });
    }

    // ---- Settings and the rest --------------------------------------------
    await run('settings', 'open_settings', (s) async {
      appRouter.go('/settings');
      await s.waitFor(find.byType(SettingsScreen), mark: 'screen_visible');
      await _pumpFor(tester, const Duration(seconds: 1));
    });
    await run('settings', 'settings_scroll', (s) async {
      await _scrollBothWays(tester, find.byType(Scrollable), flings: 2);
    });
    await run('settings', 'open_notifications_settings', (s) async {
      appRouter.go('/settings/notifications');
      await s.waitFor(
        find.byType(NotificationPermissionSettingsScreen),
        mark: 'screen_visible',
      );
      await _pumpFor(tester, const Duration(seconds: 1));
    });
    await run('settings', 'open_news_signup', (s) async {
      appRouter.go('/settings/news-signup');
      await s.waitFor(
        find.byType(NewsSignupSettingsScreen),
        mark: 'screen_visible',
      );
      await _pumpFor(tester, const Duration(seconds: 1));
    });
    await run('settings', 'open_feedback', (s) async {
      appRouter.go('/feedback');
      await s.waitFor(find.byType(FeedbackScreen), mark: 'screen_visible');
      await _pumpFor(tester, const Duration(seconds: 1));
    });

    // ---- Round trip --------------------------------------------------------
    // The same four tabs back-to-back, the way a user flips between them.
    // Warm now (everything is cached), so this isolates navigation cost.
    await run('tabs', 'tab_cycle_warm_x3', (s) async {
      for (var i = 0; i < 3; i++) {
        for (final path in ['/pray', '/people-groups', '/reminders', '/home']) {
          appRouter.go(path);
          await _pumpFor(tester, const Duration(milliseconds: 600));
        }
      }
    });

    binding.reportData = {
      'meta': {
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'gitSha': _gitSha,
        'gitDirty': _gitDirty == 'true',
        'label': _label,
        'flavor': _flavor,
        'buildMode': kProfileMode
            ? 'profile'
            : kDebugMode
            ? 'debug'
            : 'release',
        'os': Platform.operatingSystem,
        'osVersion': Platform.operatingSystemVersion,
        'refreshRateHz': _refreshRate(),
        'frameBudgetMs': _budgetMs(),
        'devicePixelRatio':
            tester.view.devicePixelRatio, // physical pixels per logical
      },
      'scenarios': results,
    };
  }, timeout: const Timeout(Duration(minutes: 20)));
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

double _refreshRate() {
  final display = WidgetsBinding.instance.platformDispatcher.displays.firstOrNull;
  final hz = display?.refreshRate ?? 60;
  return hz > 0 ? hz : 60;
}

/// The time one frame may take before it counts as a dropped frame.
double _budgetMs() => 1000 / _refreshRate();

/// Pumps frames in 16ms steps for [duration] of real time.
Future<void> _pumpFor(WidgetTester tester, Duration duration) async {
  final end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

Future<void> _tapIfPresent(WidgetTester tester, Finder finder) async {
  if (tester.any(finder)) await tester.tap(finder.first);
}

/// Flings [scrollable] away from the top [flings] times, then back.
Future<void> _scrollBothWays(
  WidgetTester tester,
  Finder scrollable, {
  required int flings,
}) async {
  if (!tester.any(scrollable)) return;
  final target = scrollable.first;
  for (final dy in [-500.0, 500.0]) {
    for (var i = 0; i < flings; i++) {
      await tester.fling(target, Offset(0, dy), 2500);
      await _pumpFor(tester, const Duration(milliseconds: 1000));
    }
  }
}

/// Per-scenario clock plus named marks.
class _Scenario {
  _Scenario(this.tester);

  final WidgetTester tester;
  final Stopwatch watch = Stopwatch();
  final Map<String, double> marks = {};
  final List<String> timedOut = [];

  /// Pumps until [finder] matches, then records how long that took as [mark]
  /// (ms since the scenario began). On timeout, records the name in
  /// [timedOut] rather than failing, so one slow screen doesn't hide the rest.
  Future<void> waitFor(Finder finder, {required String mark}) async {
    final deadline = DateTime.now().add(_contentTimeout);
    while (!tester.any(finder)) {
      if (DateTime.now().isAfter(deadline)) {
        timedOut.add(mark);
        return;
      }
      await tester.pump(const Duration(milliseconds: 16));
    }
    marks[mark] = watch.elapsedMicroseconds / 1000;
  }
}

/// Collects the engine's FrameTiming reports between [start] and [stop].
class _FrameRecorder {
  List<FrameTiming> _frames = [];
  bool _recording = false;

  void _callback(List<FrameTiming> timings) {
    if (_recording) _frames.addAll(timings);
  }

  bool _registered = false;

  void start() {
    if (!_registered) {
      SchedulerBinding.instance.addTimingsCallback(_callback);
      _registered = true;
    }
    _frames = [];
    _recording = true;
  }

  _FrameStats stop() {
    _recording = false;
    return _FrameStats(_frames);
  }
}

class _FrameStats {
  _FrameStats(List<FrameTiming> frames)
    : build = [for (final f in frames) _ms(f.buildDuration)],
      raster = [for (final f in frames) _ms(f.rasterDuration)],
      total = [for (final f in frames) _ms(f.totalSpan)];

  final List<double> build;
  final List<double> raster;
  final List<double> total;

  static double _ms(Duration d) => d.inMicroseconds / 1000;

  Map<String, Object?> toJson(double budgetMs) => {
    'count': total.length,
    'build': _summary(build),
    'raster': _summary(raster),
    'total': _summary(total),
    // A frame is "dropped" when its thread overran the vsync budget.
    'droppedBuild': build.where((v) => v > budgetMs).length,
    'droppedRaster': raster.where((v) => v > budgetMs).length,
    'droppedTotal': total.where((v) => v > budgetMs).length,
    // Frames more than 2x over budget are the visible hitches.
    'severeTotal': total.where((v) => v > budgetMs * 2).length,
  };

  static Map<String, double> _summary(List<double> values) {
    if (values.isEmpty) {
      return {'avg': 0, 'p50': 0, 'p90': 0, 'p99': 0, 'max': 0};
    }
    final sorted = [...values]..sort();
    double pct(double p) =>
        sorted[math.min(sorted.length - 1, (sorted.length * p).floor())];
    return {
      'avg': values.reduce((a, b) => a + b) / values.length,
      'p50': pct(0.5),
      'p90': pct(0.9),
      'p99': pct(0.99),
      'max': sorted.last,
    };
  }
}
