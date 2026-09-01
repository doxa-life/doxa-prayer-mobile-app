import 'dart:convert';
import 'dart:io';

import 'package:doxa_prayer_mobile_app/services/response_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Counts requests so tests can assert a cache hit skipped the network.
class _FakeApi {
  _FakeApi({this.body = '{"value":"network"}', this.status = 200});

  String body;
  int status;
  int calls = 0;

  http.Client get client => MockClient((request) async {
    calls++;
    return http.Response(
      body,
      status,
      headers: {'content-type': 'application/json'},
    );
  });
}

void main() {
  late Directory dir;
  final uri = Uri.parse('https://example.test/api/thing');

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('response_cache_test');
    ResponseCache.debugDirectory = dir;
    clearMemoryCache();
  });

  tearDown(() async {
    clearMemoryCache();
    ResponseCache.debugDirectory = null;
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  Future<String> fetch(_FakeApi api, {bool forceRefresh = false}) {
    responseCacheClient = api.client;
    return getJsonCached<String>(
      uri: uri,
      cacheKey: 'thing-en',
      ttl: const Duration(days: 7),
      forceRefresh: forceRefresh,
      decode: (body) => jsonDecode(body)['value'] as String,
      errorMessage: (status) => 'failed ($status)',
    );
  }

  test('first call hits the network and caches the body', () async {
    final api = _FakeApi();
    expect(await fetch(api), 'network');
    expect(api.calls, 1);
    expect(await ResponseCache.read('thing-en'), '{"value":"network"}');
  });

  test('a second call is served from memory', () async {
    final api = _FakeApi();
    await fetch(api);
    expect(await fetch(api), 'network');
    expect(api.calls, 1, reason: 'second call should not hit the network');
  });

  test('a fresh cache entry is served from disk in a new session', () async {
    final api = _FakeApi();
    await fetch(api);
    clearMemoryCache();
    expect(await fetch(api), 'network');
    expect(api.calls, 1, reason: 'second call should come from disk');
  });

  test('forceRefresh goes past a fresh entry', () async {
    final api = _FakeApi();
    await fetch(api);
    api.body = '{"value":"refreshed"}';
    expect(await fetch(api, forceRefresh: true), 'refreshed');
    expect(api.calls, 2);
  });

  test('an expired entry is refetched', () async {
    await ResponseCache.write('thing-en', '{"value":"old"}');
    final stale = File('${dir.path}/thing-en');
    await stale.setLastModified(
      DateTime.now().subtract(const Duration(days: 8)),
    );
    final api = _FakeApi();
    expect(await fetch(api), 'network');
    expect(api.calls, 1);
  });

  test('an expired entry is served when the refetch fails', () async {
    await ResponseCache.write('thing-en', '{"value":"old"}');
    await File(
      '${dir.path}/thing-en',
    ).setLastModified(DateTime.now().subtract(const Duration(days: 8)));
    final api = _FakeApi(status: 500);
    expect(await fetch(api), 'old');
    expect(api.calls, 1);
  });

  test(
    'the error surfaces when there is nothing cached to fall back on',
    () async {
      final api = _FakeApi(status: 500);
      await expectLater(fetch(api), throwsA(isA<Exception>()));
    },
  );

  test('an undecodable cache entry is discarded, not surfaced', () async {
    await ResponseCache.write('thing-en', 'not json at all');
    final api = _FakeApi();
    expect(await fetch(api), 'network');
    expect(api.calls, 1);
  });

  test('concurrent callers share one request', () async {
    final api = _FakeApi();
    responseCacheClient = api.client;
    final results = await Future.wait([fetch(api), fetch(api), fetch(api)]);
    expect(results, ['network', 'network', 'network']);
    expect(api.calls, 1);
  });

  test('prune deletes entries past the max age and keeps the rest', () async {
    await ResponseCache.write('old-entry', 'a');
    await ResponseCache.write('new-entry', 'b');
    await File(
      '${dir.path}/old-entry',
    ).setLastModified(DateTime.now().subtract(const Duration(days: 31)));
    await ResponseCache.prune(maxAge: const Duration(days: 30));
    expect(await ResponseCache.read('old-entry'), isNull);
    expect(await ResponseCache.read('new-entry'), 'b');
  });

  test('clear empties the cache', () async {
    await ResponseCache.write('thing-en', 'a');
    await ResponseCache.clear();
    expect(await ResponseCache.read('thing-en'), isNull);
    // Still writable afterwards — the directory is not left deleted.
    await ResponseCache.write('thing-en', 'b');
    expect(await ResponseCache.read('thing-en'), 'b');
  });

  test('non-UTF8-safe bodies survive the round trip', () async {
    final api = _FakeApi(body: jsonEncode({'value': 'صلوا من أجل'}));
    expect(await fetch(api), 'صلوا من أجل');
    expect(await fetch(api), 'صلوا من أجل', reason: 'read back from disk');
    expect(api.calls, 1);
  });

  group('peek and warm', () {
    test('peekCached is empty until a value is loaded', () async {
      expect(peekCached<String>('thing-en'), isNull);
      await fetch(_FakeApi());
      expect(peekCached<String>('thing-en'), 'network');
    });

    test('peekCached ignores a mismatched type', () async {
      await fetch(_FakeApi());
      expect(peekCached<int>('thing-en'), isNull);
    });

    test('warmCachedValue loads from disk without any request', () async {
      final api = _FakeApi();
      await fetch(api);
      clearMemoryCache();
      responseCacheClient = api.client;
      await warmCachedValue<String>(
        cacheKey: 'thing-en',
        ttl: const Duration(days: 7),
        decode: (body) => jsonDecode(body)['value'] as String,
      );
      expect(peekCached<String>('thing-en'), 'network');
      expect(api.calls, 1, reason: 'warming must never fetch');
    });

    test('a memory entry past its ttl is refetched, not served', () async {
      seedMemoryCache(
        'thing-en',
        'stale',
        cachedAt: DateTime.now().subtract(const Duration(days: 8)),
      );
      final api = _FakeApi();
      expect(await fetch(api), 'network');
      expect(api.calls, 1);
    });

    test('warmCachedValue ignores an entry past its ttl', () async {
      await ResponseCache.write('thing-en', '{"value":"old"}');
      await File(
        '${dir.path}/thing-en',
      ).setLastModified(DateTime.now().subtract(const Duration(days: 8)));
      await warmCachedValue<String>(
        cacheKey: 'thing-en',
        ttl: const Duration(days: 7),
        decode: (body) => jsonDecode(body)['value'] as String,
      );
      expect(peekCached<String>('thing-en'), isNull);
    });
  });

  group('background revalidation', () {
    Future<String> fetchSwr(_FakeApi api) {
      responseCacheClient = api.client;
      return getJsonCached<String>(
        uri: uri,
        cacheKey: 'thing-en',
        ttl: const Duration(days: 7),
        refreshAfter: const Duration(hours: 1),
        decode: (body) => jsonDecode(body)['value'] as String,
        errorMessage: (status) => 'failed ($status)',
      );
    }

    test('a cache hit within refreshAfter makes no request', () async {
      final api = _FakeApi();
      await fetchSwr(api);
      expect(await fetchSwr(api), 'network');
      expect(api.calls, 1);
    });

    test('an older hit returns cached, then refreshes and notifies', () async {
      await ResponseCache.write('thing-en', '{"value":"old"}');
      await File(
        '${dir.path}/thing-en',
      ).setLastModified(DateTime.now().subtract(const Duration(hours: 2)));
      final api = _FakeApi(body: '{"value":"fresh"}');
      final updates = <Object>[];
      void listener(Object value) => updates.add(value);
      addCacheListener('thing-en', listener);
      addTearDown(() => removeCacheListener('thing-en', listener));

      // The caller is handed the cached value immediately...
      expect(await fetchSwr(api), 'old');
      // ...and the refresh lands behind it.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(updates, ['fresh']);
      expect(peekCached<String>('thing-en'), 'fresh');
      expect(api.calls, 1);
    });

    test('a failed revalidation leaves the cached value in place', () async {
      await ResponseCache.write('thing-en', '{"value":"old"}');
      await File(
        '${dir.path}/thing-en',
      ).setLastModified(DateTime.now().subtract(const Duration(hours: 2)));
      final api = _FakeApi(status: 500);
      expect(await fetchSwr(api), 'old');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(peekCached<String>('thing-en'), 'old');
    });

    test('a memory hit still triggers revalidation when old enough', () async {
      await ResponseCache.write('thing-en', '{"value":"old"}');
      await File(
        '${dir.path}/thing-en',
      ).setLastModified(DateTime.now().subtract(const Duration(hours: 2)));
      final api = _FakeApi(body: '{"value":"fresh"}');
      // First call populates memory from the aged disk entry.
      await fetchSwr(api);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(peekCached<String>('thing-en'), 'fresh');
      expect(api.calls, 1);
    });
  });
}
