// ignore_for_file: invalid_use_of_visible_for_testing_member
// Headless UI benchmark covering the whole app: no phone, no simulator.
//
//   flutter test benchmark/ui_bench_test.dart
//
// Mounts the real app (MyApp + the real router) with seeded data and times the
// CPU work of building, laying out and painting each screen, each tab switch,
// scrolling, and the main interactions and sheets. It does NOT measure GPU
// rasterising, images or the network (all data is seeded, no photos).
//
// Absolute numbers are Dart VM (JIT) milliseconds on this Mac, NOT phone
// milliseconds. Compare one run against another on the same machine. Results go
// to build/benchmark/<timestamp>.md. A scenario that cannot run says so in its
// row instead of stopping the run.

import 'dart:io';

import 'package:doxa_prayer_mobile_app/components/cards/detail_section_card_skeleton.dart';
import 'package:doxa_prayer_mobile_app/components/cards/people_group_hero_card_skeleton.dart';
import 'package:doxa_prayer_mobile_app/components/cards/people_group_list_card.dart';
import 'package:doxa_prayer_mobile_app/components/cards/people_group_list_card_skeleton.dart';
import 'package:doxa_prayer_mobile_app/components/misc/hyphenated_text.dart';
import 'package:doxa_prayer_mobile_app/components/prayer_content/prayer_content_skeleton.dart';
import 'package:doxa_prayer_mobile_app/components/widgets/people_group_details_skeleton.dart';
import 'package:doxa_prayer_mobile_app/components/widgets/people_groups_list.dart';
import 'package:doxa_prayer_mobile_app/components/widgets/people_groups_list_skeleton.dart';
import 'package:doxa_prayer_mobile_app/main.dart' show MyApp;
import 'package:doxa_prayer_mobile_app/models/people_group.dart';
import 'package:doxa_prayer_mobile_app/models/people_group_detail.dart';
import 'package:doxa_prayer_mobile_app/models/prayer_content.dart';
import 'package:doxa_prayer_mobile_app/router.dart';
import 'package:doxa_prayer_mobile_app/services/hyphenation_service.dart';
import 'package:doxa_prayer_mobile_app/services/people_groups_service.dart';
import 'package:doxa_prayer_mobile_app/services/prayer_content_service.dart';
import 'package:doxa_prayer_mobile_app/services/prayer_history_service.dart';
import 'package:doxa_prayer_mobile_app/services/reminders_controller.dart';
import 'package:doxa_prayer_mobile_app/services/response_cache.dart';
import 'package:doxa_prayer_mobile_app/services/subscribed_people_groups_controller.dart';
import 'package:doxa_prayer_mobile_app/services/wizard_completion_controller.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../test/helpers/pump_at_scale.dart';

const int _groups = 300;
const int _warmup = 1;
const int _reps = 5;

// ---------------------------------------------------------------- test data

const _countries = [
  ('Malaysia', 'MYS'),
  ('India', 'IND'),
  ('Indonesia', 'IDN'),
  ('Pakistan', 'PAK'),
  ('Nigeria', 'NGA'),
  ('Brazil', 'BRA'),
];
const _religions = ['Islam - Sunni', 'Hinduism', 'Buddhism', 'Ethnic Religions'];
const _languages = ['Malay', 'Hindi', 'Urdu', 'Hausa', 'Javanese'];

PeopleGroup _group(int i) {
  final c = _countries[i % _countries.length];
  return PeopleGroup(
    name: 'Sample People Group Number $i',
    slug: 'group-$i',
    imageUrl: null,
    countryLabel: c.$1,
    countryCode: c.$2,
    religionLabel: _religions[i % _religions.length],
    religionAlternates: i.isEven ? const ['Muslim'] : const [],
    primaryLanguageLabel: _languages[i % _languages.length],
    population: 1000 * (i + 1),
    engagementStatusValue: i % 3 == 0 ? 'engaged' : 'unengaged',
    regionValue: 'asia',
    peoplePraying: i % 5,
    peopleCommitted: i % 7,
    latitude: 5.0 + (i % 40) * 0.5,
    longitude: 100.0 + (i % 40) * 0.5,
  );
}

PeopleGroupDetail _detail(String slug) => PeopleGroupDetail(
  raw: {
    'name': 'Sample People Group Number 0',
    'slug': slug,
    'image_url': null,
    'people_committed': 12,
    'people_praying': 3,
    'adopted_by_churches': 2,
    'workers_long_term': true,
    'work_in_local_language': true,
    'disciple_and_church_multiplication': false,
    'engagement_status': {'label': 'Unengaged', 'value': 'unengaged'},
    'country_code': {'label': 'Malaysia'},
    'imb_alternate_name': 'Alt name',
    'population': 1234567,
    'primary_language': {'label': 'Malay'},
    'religion': {'label': 'Islam - Sunni'},
    'imb_bible_available': true,
    'imb_bible_stories_available': false,
    'imb_jesus_film_available': true,
    'imb_radio_broadcast_available': false,
    'imb_gospel_recordings_available': true,
    'imb_audio_scripture_available': false,
    'rop1': {'label': 'Malay'},
    'imb_people_description': List.filled(8, 'A long paragraph about the people group and where they live. ').join(),
  },
);

String _today() {
  final d = DateTime.now();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)}';
}

PrayerContentResponse _prayer(String slug) {
  Map<String, dynamic> para(String t) => {
    'type': 'paragraph',
    'content': [
      {'type': 'text', 'text': t},
    ],
  };
  return PrayerContentResponse.fromJson({
    'people_group': {'id': 1, 'slug': slug, 'title': 'Sample $slug'},
    'date': _today(),
    'language': 'en',
    'availableLanguages': ['en'],
    'hasContent': true,
    'globalStartDate': '2025-01-01',
    'metadata': {'copyright_notices': []},
    'content': [
      {
        'id': 5,
        'title': 'People group',
        'language_code': 'en',
        'content_type': 'people_group',
        'people_group_data': {
          'name': 'Sample $slug',
          'description': List.filled(6, 'Description text for the people group. ').join(),
          'population': 100000,
          'language': 'Malay',
          'religion': 'Islam',
          'country': 'Malaysia',
          'picture_credit': [],
        },
      },
      {
        'id': 7,
        'title': 'Prayer',
        'language_code': 'en',
        'content_type': 'static',
        'content_json': {
          'type': 'doc',
          'content': [
            for (var i = 0; i < 12; i++)
              para('Lord, we pray for this people group, paragraph $i. ' * 3),
          ],
        },
      },
    ],
  });
}

/// Minimal Firebase core stand-in. Crashlytics reads its "collection enabled"
/// flag from the plugin constants, so they are provided here.
class _FirebaseStub implements TestFirebaseCoreHostApi {
  static final _options = CoreFirebaseOptions(
    apiKey: '123',
    projectId: '123',
    appId: '123',
    messagingSenderId: '123',
  );
  static final _constants = <String, Map<Object?, Object?>?>{
    'plugins.flutter.io/firebase_crashlytics': {
      'isCrashlyticsCollectionEnabled': true,
    },
  };

  @override
  Future<CoreInitializeResponse> initializeApp(
    String appName,
    CoreFirebaseOptions initializeAppRequest,
  ) async => CoreInitializeResponse(
    name: appName,
    options: _options,
    pluginConstants: _constants,
  );

  @override
  Future<List<CoreInitializeResponse>> initializeCore() async => [
    CoreInitializeResponse(
      name: '[DEFAULT]',
      options: _options,
      pluginConstants: _constants,
    ),
  ];

  @override
  Future<CoreFirebaseOptions> optionsFromResource() async => _options;
}

class _Result {
  _Result(this.group, this.name, this.unit, this.samples, [this.note]);
  final String group, name, unit;
  final List<double> samples;
  final String? note;

  double _p(double p) {
    final s = [...samples]..sort();
    return s[((s.length - 1) * p).round()];
  }

  double get median => _p(0.5);
  double get p90 => _p(0.9);
  double get max => _p(1.0);
}

void main() {
  final results = <_Result>[];
  var hyphenation = 'off';

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    dotenv.testLoad();
    // The app reads prefs and logs route breadcrumbs to Crashlytics; give both
    // harmless stand-ins so the real router and screens can run headless.
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    TestFirebaseCoreHostApi.setUp(_FirebaseStub());
    await Firebase.initializeApp();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/firebase_crashlytics'),
          (call) async => null,
        );
    try {
      await preloadHyphenator(const Locale('en'));
      hyphenation = hyphenatorFor(const Locale('en')) != null ? 'on' : 'off';
    } catch (_) {}
  });

  void seed() {
    wizardCompletedController.value = true;
    const slugs = ['group-0', 'group-1', 'group-2'];
    peopleGroupsController.value = SubscribedPeopleGroups(
      list: [
        for (final s in slugs)
          SubscribedPeopleGroup(slug: s, name: 'Sample $s'),
      ],
      activeSlug: 'group-0',
    );
    prayedTodayController.value = {'group-1'};
    remindersController.value = Reminders(
      list: [
        for (var i = 0; i < 6; i++)
          Reminder(
            id: 'r$i',
            slug: slugs[i % 3],
            hour: 6 + i,
            minute: 30,
            weekdays: const [1, 2, 3, 4, 5],
            enabled: i.isEven,
          ),
      ],
    );
    seedMemoryCache(peopleGroupListCacheKey('en'), [
      for (var i = 0; i < _groups; i++) _group(i),
    ]);
    for (final s in slugs) {
      seedMemoryCache(peopleGroupDetailCacheKey(s, 'en'), _detail(s));
      seedMemoryCache(
        prayerContentCacheKey(slug: s, date: DateTime.now(), language: 'en'),
        _prayer(s),
      );
    }
  }

  setUp(() {
    clearMemoryCache();
    seed();
  });
  tearDown(clearMemoryCache);

  testWidgets('benchmark', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    Future<void> frames(int n) async {
      for (var i = 0; i < n; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
    }

    Future<void> mountApp(String path) async {
      seed();
      appRouter.go(path);
      await tester.pumpWidget(const MyApp());
      await tester.pump();
      await frames(30);
    }

    Future<void> unmount() async {
      await tester.pumpWidget(const SizedBox());
      clearMemoryCache();
    }

    Future<void> noop() async {}

    /// Runs one scenario. [measure] returns the samples for ONE rep; any error
    /// is recorded in the row and the run carries on.
    Future<void> bench(
      String group,
      String name,
      String unit,
      Future<List<double>> Function() measure, {
      Future<void> Function()? setup,
      Future<void> Function()? teardown,
    }) async {
      final samples = <double>[];
      try {
        for (var i = 0; i < _warmup + _reps; i++) {
          await (setup ?? noop)();
          final one = await measure();
          if (i >= _warmup) samples.addAll(one);
          await (teardown ?? noop)();
        }
        results.add(_Result(group, name, unit, samples));
      } catch (e) {
        tester.takeException();
        results.add(
          _Result(group, name, unit, [0], 'could not run: ${e.toString().split('\n').first}'),
        );
        try {
          await unmount();
        } catch (_) {}
      }
    }

    Future<List<double>> timeIt(Future<void> Function() action) async {
      final sw = Stopwatch()..start();
      await action();
      sw.stop();
      return [sw.elapsedMicroseconds / 1000];
    }

    Future<List<double>> timeFrames(
      Future<void> Function(Future<void> Function() frame) run,
    ) async {
      final out = <double>[];
      Future<void> frame() async {
        final sw = Stopwatch()..start();
        await tester.pump(const Duration(milliseconds: 16));
        sw.stop();
        out.add(sw.elapsedMicroseconds / 1000);
      }

      await run(frame);
      return out;
    }

    Future<void> tapIfFound(Finder f) async {
      if (!tester.any(f)) {
        final texts = tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => t.data)
            .whereType<String>()
            .take(25)
            .join(' | ');
        throw 'not found: $f. Screen text: $texts';
      }
      await tester.tap(f.first);
      await tester.pump();
      await frames(30);
    }

    // ===== 1. Every screen, opened fresh through the real router ==========
    const screens = {
      'Home': '/home',
      'Pray': '/pray',
      'Search': '/people-groups',
      'Reminders': '/reminders',
      'Settings': '/settings',
      'Settings > Notifications': '/settings/notifications',
      'Settings > News signup': '/settings/news-signup',
      'Feedback': '/feedback',
      'Group details': '/people-groups/group-0',
      'Group map': '/people-groups/group-0/map',
      'Prayer deep link': '/group-0/prayer',
      'Component gallery': '/gallery',
      'Debug': '/debug',
    };
    for (final e in screens.entries) {
      await bench(
        'Screens',
        'Open ${e.key} (app shell + screen, first 31 frames)',
        'ms per open',
        () => timeIt(() => mountApp(e.value)),
        teardown: unmount,
      );
    }

    // Onboarding wizard: its first screen, then each step forward.
    await bench(
      'Screens',
      'Open Wizard (first step)',
      'ms per open',
      () => timeIt(() async {
        wizardCompletedController.value = false;
        appRouter.go('/wizard');
        await tester.pumpWidget(const MyApp());
        await tester.pump();
        await frames(30);
      }),
      teardown: () async {
        await unmount();
        wizardCompletedController.value = true;
      },
    );

    // ===== 2. Switching tabs inside a running app ==========================
    await mountApp('/home');
    for (final e in {
      'Pray': '/pray',
      'Search': '/people-groups',
      'Reminders': '/reminders',
      'Home': '/home',
    }.entries) {
      await bench(
        'Tab switches',
        'Switch to ${e.key} (change + 30 frames)',
        'ms per switch',
        () => timeIt(() async {
          appRouter.go(e.value);
          await tester.pump();
          await frames(30);
        }),
      );
    }
    await unmount();

    // ===== 3. Scrolling every scrollable screen =============================
    for (final e in {
      'Home': '/home',
      'Pray': '/pray',
      'Reminders': '/reminders',
      'Group details': '/people-groups/group-0',
      'Settings': '/settings',
      'Component gallery': '/gallery',
    }.entries) {
      await bench(
        'Scrolling',
        '${e.key}: fling down and back (80 frames)',
        'ms per frame',
        () => timeFrames((frame) async {
          final s = find.byType(Scrollable).first;
          await tester.fling(s, const Offset(0, -500), 2500);
          for (var i = 0; i < 40; i++) {
            await frame();
          }
          await tester.fling(s, const Offset(0, 500), 2500);
          for (var i = 0; i < 40; i++) {
            await frame();
          }
        }),
        setup: () => mountApp(e.value),
        teardown: unmount,
      );
    }

    // ===== 4. Search page: list, typing, filters, sort =====================
    Future<void> mountList() async {
      seed();
      await pumpAtScale(
        tester,
        const PeopleGroupsList(),
        scale: 1.0,
        viewport: const Size(390, 844),
      );
      await tester.pump();
      await frames(30);
    }

    final listView = find.byType(ListView);
    await bench(
      'Search page',
      'First build of the list ($_groups groups)',
      'ms per build',
      () => timeIt(mountList),
      teardown: unmount,
    );
    await bench(
      'Search page',
      'Slow scroll (40 frames, 30px each)',
      'ms per frame',
      () => timeFrames((frame) async {
        for (var i = 0; i < 40; i++) {
          await tester.drag(listView, const Offset(0, -30));
          await frame();
        }
      }),
      setup: mountList,
      teardown: unmount,
    );
    await bench(
      'Search page',
      'Fast fling (60 frames)',
      'ms per frame',
      () => timeFrames((frame) async {
        await tester.fling(listView, const Offset(0, -600), 3500);
        for (var i = 0; i < 60; i++) {
          await frame();
        }
      }),
      setup: mountList,
      teardown: unmount,
    );
    for (final q in ['a', 'india', 'muslim']) {
      await bench(
        'Search page',
        'Type "$q" (change + 30 frames)',
        'ms per action',
        () => timeIt(() async {
          await tester.enterText(find.byType(TextField).first, q);
          await tester.pump();
          await frames(30);
        }),
        setup: mountList,
        teardown: unmount,
      );
    }
    await bench(
      'Search page',
      'Clear search after "india" (change + 30 frames)',
      'ms per action',
      () => timeIt(() async {
        await tester.enterText(find.byType(TextField).first, '');
        await tester.pump();
        await frames(30);
      }),
      setup: () async {
        await mountList();
        await tester.enterText(find.byType(TextField).first, 'india');
        await frames(40);
      },
      teardown: unmount,
    );
    await bench(
      'Search page',
      'Open filter panel (tap + 30 frames)',
      'ms per action',
      () => timeIt(() => tapIfFound(find.byIcon(Icons.tune))),
      setup: mountList,
      teardown: unmount,
    );
    for (final section in ['Primary language', 'Primary religion', 'Country', 'Population']) {
      await bench(
        'Search page',
        'Filter section "$section" (tap + 30 frames)',
        'ms per action',
        () => timeIt(() => tapIfFound(find.text(section))),
        setup: () async {
          await mountList();
          await tester.tap(find.byIcon(Icons.tune));
          await frames(30);
        },
        teardown: unmount,
      );
    }
    await bench(
      'Search page',
      'Sort toggle (tap + 30 frames)',
      'ms per action',
      () => timeIt(() => tapIfFound(find.byIcon(Icons.arrow_downward))),
      setup: mountList,
      teardown: unmount,
    );

    // ===== 5. Sheets, modals and menus (opened inside the app) ==============
    Future<void> sheetBench(String name, String path, Finder trigger) =>
        bench(
          'Sheets and menus',
          name,
          'ms per open',
          () => timeIt(() => tapIfFound(trigger)),
          setup: () => mountApp(path),
          teardown: unmount,
        );
    await sheetBench('Reminder editor (new reminder button)', '/reminders', find.byTooltip('New reminder'));
    await sheetBench('Reminder editor (tap an existing reminder)', '/reminders', find.byType(Switch));
    await sheetBench('Share people group (Home card)', '/home', find.text('SHARE'));
    await sheetBench('Language menu (Settings)', '/settings', find.byType(DropdownButtonFormField<Locale>));
    await sheetBench('Settings (top bar button)', '/home', find.byTooltip('Settings'));

    // ===== 6. Components: cards, text and every skeleton ====================
    Future<void> mountWidget(
      Widget w, {
      double height = 6000,
      bool scroll = true,
    }) async {
      await pumpAtScale(
        tester,
        scroll ? SingleChildScrollView(child: w) : w,
        scale: 1.0,
        viewport: Size(390, height),
      );
      await tester.pump();
    }

    await bench(
      'Components',
      'Build 30 list cards',
      'ms per build',
      () => timeIt(
        () => mountWidget(
          Column(
            children: [
              for (var i = 0; i < 30; i++)
                PeopleGroupListCard(
                  name: 'Sample People Group Number $i',
                  imageUrl: null,
                  countryLabel: 'Malaysia',
                  countryCode: 'MYS',
                  engagementStatusValue: 'unengaged',
                  peoplePraying: i,
                  onDetails: () {},
                ),
            ],
          ),
        ),
      ),
      teardown: unmount,
    );
    await bench(
      'Components',
      'Build 150 HyphenatedText labels',
      'ms per build',
      () => timeIt(
        () => mountWidget(
          Column(
            children: [
              for (var i = 0; i < 150; i++)
                HyphenatedText('Sample People Group Number $i'),
            ],
          ),
        ),
      ),
      teardown: unmount,
    );
    for (final s in <String, Widget>{
      'Search list skeleton': const PeopleGroupsListSkeleton(),
      'Group details skeleton': const PeopleGroupDetailsSkeleton(),
      'Prayer content skeleton': const PrayerContentSkeleton(),
      'Hero card skeleton': const PeopleGroupHeroCardSkeleton(),
      'List card skeleton': const PeopleGroupListCardSkeleton(),
      'Detail section skeleton': const DetailSectionCardSkeleton(),
    }.entries) {
      await bench(
        'Components',
        '${s.key} (build + 30 animating frames)',
        'ms per build',
        () => timeIt(() async {
          await mountWidget(s.value, height: 844, scroll: false);
          await frames(30);
        }),
        teardown: unmount,
      );
    }

    // ===== Report ============================================================
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final stamp =
        '${now.year}-${two(now.month)}-${two(now.day)} ${two(now.hour)}:${two(now.minute)}:${two(now.second)}';
    final b = StringBuffer()
      ..writeln('Timestamp: $stamp')
      ..writeln('Machine: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}')
      ..writeln('Headless (flutter test, Dart VM JIT) - compare runs, not phone ms')
      ..writeln('Data: $_groups people groups, 3 subscribed, 6 reminders - hyphenation $hyphenation - $_reps reps after $_warmup warm-up')
      ..writeln()
      ..writeln('| Group | Scenario | unit | median | p90 | max |')
      ..writeln('|---|---|---|--:|--:|--:|');
    for (final r in results) {
      if (r.note != null) {
        b.writeln('| ${r.group} | ${r.name} | - | - | - | ${r.note} |');
      } else {
        b.writeln(
          '| ${r.group} | ${r.name} | ${r.unit} | ${r.median.toStringAsFixed(2)} | ${r.p90.toStringAsFixed(2)} | ${r.max.toStringAsFixed(2)} |',
        );
      }
    }
    final dir = Directory('build/benchmark')..createSync(recursive: true);
    final file = File(
      '${dir.path}/${now.year}${two(now.month)}${two(now.day)}-${two(now.hour)}${two(now.minute)}${two(now.second)}.md',
    )..writeAsStringSync(b.toString());
    // ignore: avoid_print
    print('\n$b\nSaved: ${file.path}');
  }, timeout: const Timeout(Duration(minutes: 15)));
}
