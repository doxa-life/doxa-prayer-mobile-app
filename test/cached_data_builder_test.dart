import 'dart:async';

import 'package:doxa_prayer_mobile_app/components/misc/cached_data_builder.dart';
import 'package:doxa_prayer_mobile_app/services/response_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A fetch that never resolves, so whatever is on screen came from the cache.
Future<String> _never({bool forceRefresh = false}) =>
    Completer<String>().future;

void main() {
  setUp(clearMemoryCache);
  tearDown(clearMemoryCache);

  /// Counts skeleton builds, so a test can assert one was never built at all.
  int loadingBuilds = 0;

  Widget subject({
    required String cacheKey,
    required Future<String> Function({bool forceRefresh}) fetch,
  }) {
    return MaterialApp(
      home: CachedDataBuilder<String>(
        cacheKey: cacheKey,
        fetch: fetch,
        loading: (context) {
          loadingBuilds++;
          return const Text('skeleton');
        },
        error: (context, retry) =>
            TextButton(onPressed: retry, child: const Text('retry')),
        builder: (context, data) => Text(data),
      ),
    );
  }

  setUp(() => loadingBuilds = 0);

  testWidgets('shows the skeleton while nothing is cached', (tester) async {
    await tester.pumpWidget(subject(cacheKey: 'thing', fetch: _never));
    expect(find.text('skeleton'), findsOne);
  });

  testWidgets('paints cached data in the first frame, never the skeleton', (
    tester,
  ) async {
    seedMemoryCache('thing', 'cached');
    await tester.pumpWidget(subject(cacheKey: 'thing', fetch: _never));
    expect(find.text('cached'), findsOne);
    expect(find.text('skeleton'), findsNothing);
    expect(loadingBuilds, 0, reason: 'the skeleton must not be built at all');
  });

  testWidgets('a resolved fetch replaces what the cache showed', (
    tester,
  ) async {
    seedMemoryCache('thing', 'cached');
    await tester.pumpWidget(
      subject(
        cacheKey: 'thing',
        fetch: ({bool forceRefresh = false}) async => 'fetched',
      ),
    );
    expect(find.text('cached'), findsOne);
    await tester.pumpAndSettle();
    expect(find.text('fetched'), findsOne);
    expect(loadingBuilds, 0);
  });

  testWidgets('a failing fetch keeps cached data instead of erroring', (
    tester,
  ) async {
    seedMemoryCache('thing', 'cached');
    await tester.pumpWidget(
      subject(
        cacheKey: 'thing',
        fetch: ({bool forceRefresh = false}) async =>
            throw Exception('offline'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('cached'), findsOne);
    expect(find.text('retry'), findsNothing);
  });

  testWidgets('errors only when there is nothing cached, and retries', (
    tester,
  ) async {
    var attempts = 0;
    final forced = <bool>[];
    await tester.pumpWidget(
      subject(
        cacheKey: 'thing',
        fetch: ({bool forceRefresh = false}) async {
          attempts++;
          forced.add(forceRefresh);
          if (attempts == 1) throw Exception('offline');
          return 'second try';
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('retry'), findsOne);

    await tester.tap(find.text('retry'));
    await tester.pumpAndSettle();
    expect(find.text('second try'), findsOne);
    expect(forced, [false, true], reason: 'retry must bypass the cache');
  });

  testWidgets('a new cacheKey re-peeks, so a cached day shows instantly', (
    tester,
  ) async {
    seedMemoryCache('day-1', 'monday');
    seedMemoryCache('day-2', 'tuesday');

    await tester.pumpWidget(subject(cacheKey: 'day-1', fetch: _never));
    expect(find.text('monday'), findsOne);

    await tester.pumpWidget(subject(cacheKey: 'day-2', fetch: _never));
    expect(find.text('tuesday'), findsOne);
    expect(loadingBuilds, 0);
  });

  testWidgets('repaints when a background revalidation lands', (tester) async {
    // What the counts refresh does: the screen painted from cache, then the
    // refreshed copy arrives behind it and replaces it in place.
    seedMemoryCache('thing', 'old count');
    await tester.pumpWidget(subject(cacheKey: 'thing', fetch: _never));
    expect(find.text('old count'), findsOne);

    debugNotifyRevalidated('thing', 'new count');
    await tester.pump();
    expect(find.text('new count'), findsOne);
    expect(loadingBuilds, 0);
  });

  testWidgets('stops listening once disposed', (tester) async {
    seedMemoryCache('thing', 'cached');
    await tester.pumpWidget(subject(cacheKey: 'thing', fetch: _never));
    await tester.pumpWidget(const MaterialApp(home: Text('gone')));
    // Would throw on a setState after dispose if the listener leaked.
    debugNotifyRevalidated('thing', 'ignored');
    await tester.pump();
    expect(find.text('gone'), findsOne);
  });
}
