import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'cache_policy.dart';

/// Bump when a cached payload's shape changes in a way that old entries can't
/// satisfy. The directory name carries the version, so a bump orphans the old
/// files and the startup sweep removes them.
const _cacheDirName = 'api_cache_v1';

/// A cached body together with when it was fetched.
class CacheEntry {
  const CacheEntry(this.body, this.cachedAt);

  final String body;
  final DateTime cachedAt;

  Duration get age => DateTime.now().difference(cachedAt);
}

/// Disk cache for GET responses from the campaigns API.
///
/// One file per cache key, holding the raw response body; the file's
/// modification time is its age, so there is no envelope to parse. Entries live
/// in the OS cache directory, which means the system may reclaim them under
/// storage pressure — correct for a cache, and the app just refetches.
class ResponseCache {
  ResponseCache._();

  static Directory? _dir;

  /// Points the cache at an existing directory instead of resolving the
  /// platform one, which needs a plugin that unit tests don't have.
  @visibleForTesting
  static set debugDirectory(Directory? dir) => _dir = dir;

  static Future<Directory?> _directory() async {
    final existing = _dir;
    if (existing != null) return existing;
    try {
      final base = await getApplicationCacheDirectory();
      final dir = Directory('${base.path}/$_cacheDirName');
      if (!await dir.exists()) await dir.create(recursive: true);
      return _dir = dir;
    } catch (e) {
      // No cache directory (e.g. unit tests without the platform plugin) —
      // every read misses and every write is dropped, so callers still work.
      developer.log(
        'response cache unavailable; running uncached',
        name: 'response_cache',
        error: e,
      );
      return null;
    }
  }

  /// Cache keys are readable paths like `prayer-kurds-2026-08-27-en`, so the
  /// cache directory can be inspected during debugging. Anything outside the
  /// safe set is flattened, which is enough because keys are built from slugs,
  /// language codes and ISO dates.
  static String _fileName(String key) =>
      key.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

  static Future<File?> _file(String key) async {
    final dir = await _directory();
    if (dir == null) return null;
    return File('${dir.path}/${_fileName(key)}');
  }

  /// The cached entry for [key], or null when nothing is cached — or, with
  /// [maxAge], when what is cached is older than that.
  static Future<CacheEntry?> readEntry(String key, {Duration? maxAge}) async {
    try {
      final file = await _file(key);
      if (file == null || !await file.exists()) return null;
      final cachedAt = await file.lastModified();
      if (maxAge != null && DateTime.now().difference(cachedAt) > maxAge) {
        return null;
      }
      return CacheEntry(await file.readAsString(), cachedAt);
    } catch (e) {
      developer.log(
        'cache read failed for $key',
        name: 'response_cache',
        error: e,
      );
      return null;
    }
  }

  /// The cached body for [key]; see [readEntry].
  static Future<String?> read(String key, {Duration? maxAge}) async =>
      (await readEntry(key, maxAge: maxAge))?.body;

  static Future<void> write(String key, String body) async {
    try {
      final file = await _file(key);
      if (file == null) return;
      await file.writeAsString(body, flush: true);
    } catch (e) {
      developer.log(
        'cache write failed for $key',
        name: 'response_cache',
        error: e,
      );
    }
  }

  /// Deletes every cached response, in memory and on disk. Wired to the debug
  /// screen.
  static Future<void> clear() async {
    _memory.clear();
    try {
      final dir = await _directory();
      if (dir == null || !await dir.exists()) return;
      await dir.delete(recursive: true);
      // Re-created here rather than left missing, so later writes still land.
      await dir.create(recursive: true);
    } catch (e) {
      developer.log('cache clear failed', name: 'response_cache', error: e);
    }
  }

  /// Drops entries older than [maxAge] (the longest TTL in [CachePolicy]).
  /// Called fire-and-forget at startup so browsing back through many days of
  /// prayer content — or switching languages, which caches a separate copy of
  /// the people-group list per language — doesn't accumulate files forever.
  static Future<void> prune({
    Duration maxAge = CachePolicy.maxResponseAge,
  }) async {
    try {
      final dir = await _directory();
      if (dir == null || !await dir.exists()) return;
      final now = DateTime.now();
      await for (final entity in dir.list()) {
        if (entity is! File) continue;
        final age = now.difference(await entity.lastModified());
        if (age > maxAge) await entity.delete();
      }
    } catch (e) {
      developer.log('cache prune failed', name: 'response_cache', error: e);
    }
  }
}

/// A value already decoded this session, kept so a screen can paint it in its
/// first frame. The disk copy is authoritative; this only removes the read and
/// decode from the path — which for the ~850 KB people-group list is the
/// difference between a visible skeleton and none.
class _MemoryEntry {
  const _MemoryEntry(this.value, this.cachedAt);

  final Object value;

  /// When the *body* behind this value was fetched — carried over from the file
  /// so a disk hit doesn't look freshly fetched, which would defer
  /// revalidation forever.
  final DateTime cachedAt;
}

/// Insertion-ordered, so the first key is the least recently stored: enough of
/// an LRU to bound memory while a user browses many days or many groups.
final Map<String, _MemoryEntry> _memory = <String, _MemoryEntry>{};

/// Holds the people-group list, a day or two of prayer content and a handful of
/// detail pages at once — past that, the oldest is dropped and re-read from
/// disk on demand.
const int _memoryCapacity = 24;

void _remember(String cacheKey, Object value, DateTime cachedAt) {
  // Re-inserted so it counts as most-recently-used.
  _memory.remove(cacheKey);
  _memory[cacheKey] = _MemoryEntry(value, cachedAt);
  while (_memory.length > _memoryCapacity) {
    _memory.remove(_memory.keys.first);
  }
}

/// The value cached in memory for [cacheKey], if one was loaded this session.
///
/// Synchronous by design: a widget calls this in `initState` to decide whether
/// it has anything to paint, so a cached screen never builds its skeleton. Age
/// is deliberately ignored — showing cached content immediately is always
/// better than showing a skeleton, and the fetch running alongside it replaces
/// anything stale.
T? peekCached<T>(String cacheKey) {
  final entry = _memory[cacheKey];
  final value = entry?.value;
  return value is T ? value : null;
}

/// Loads [cacheKey] from disk into memory without ever touching the network, so
/// a later screen can peek it synchronously. Used by the startup warm-up: a
/// missing entry is left missing rather than downloaded, so warming costs no
/// data.
Future<void> warmCachedValue<T>({
  required String cacheKey,
  required Duration ttl,
  required FutureOr<T> Function(String body) decode,
}) async {
  if (_memory.containsKey(cacheKey)) return;
  final entry = await ResponseCache.readEntry(cacheKey, maxAge: ttl);
  if (entry == null) return;
  try {
    _remember(cacheKey, (await decode(entry.body)) as Object, entry.cachedAt);
  } catch (e) {
    developer.log('could not warm $cacheKey', name: 'response_cache', error: e);
  }
}

/// Callbacks per cache key, notified when a background revalidation replaces a
/// cached value. Lets a screen that painted from cache update itself when the
/// refreshed copy lands — how the people-praying counts stay current under a
/// long TTL.
final Map<String, Set<void Function(Object)>> _listeners =
    <String, Set<void Function(Object)>>{};

void addCacheListener(String cacheKey, void Function(Object value) listener) {
  (_listeners[cacheKey] ??= <void Function(Object)>{}).add(listener);
}

void removeCacheListener(String cacheKey, void Function(Object) listener) {
  final set = _listeners[cacheKey];
  if (set == null) return;
  set.remove(listener);
  if (set.isEmpty) _listeners.remove(cacheKey);
}

void _notifyRevalidated(String cacheKey, Object value) {
  final set = _listeners[cacheKey];
  if (set == null) return;
  // Copied: a listener may remove itself while being notified.
  for (final listener in set.toList(growable: false)) {
    listener(value);
  }
}

/// The client every cached GET goes through. Held as an instance (rather than
/// the package-level `http.get`) so requests share a connection, and so tests
/// can swap in a `MockClient`.
http.Client _client = http.Client();

@visibleForTesting
set responseCacheClient(http.Client client) => _client = client;

/// Bodies currently being fetched, keyed by cache key, so two callers asking
/// for the same thing at once (the startup prefetch and the Pray tab opening a
/// moment later) share a single request.
final Map<String, Future<String>> _inFlight = <String, Future<String>>{};

/// GETs [uri] through the memory and disk caches, decoding bodies with [decode].
///
/// Resolution order:
///   1. A value already decoded this session — returned without any I/O.
///   2. A disk entry younger than [ttl] — decoded and returned, no request.
///   3. The network, and the response is cached.
/// When the request fails, an expired disk entry is used rather than surfacing
/// the error: stale content beats an error screen, and it makes the app work
/// offline.
///
/// [refreshAfter], when set and shorter than [ttl], makes a cache hit older
/// than it kick off a background refresh — the cached value is returned
/// immediately and listeners registered with [addCacheListener] get the fresh
/// one when it arrives. This is how data that must stay roughly current (the
/// people-praying counts) lives inside a long TTL without ever making the user
/// wait.
///
/// [forceRefresh] skips both caches, for an explicit user retry.
/// [errorMessage] builds the exception message for a non-200 with no fallback.
Future<T> getJsonCached<T>({
  required Uri uri,
  required String cacheKey,
  required Duration ttl,
  required FutureOr<T> Function(String body) decode,
  required String Function(int statusCode) errorMessage,
  Duration? refreshAfter,
  bool forceRefresh = false,
}) async {
  void scheduleRevalidation(DateTime cachedAt) {
    if (refreshAfter == null) return;
    if (DateTime.now().difference(cachedAt) <= refreshAfter) return;
    unawaited(
      _revalidate<T>(
        uri: uri,
        cacheKey: cacheKey,
        decode: decode,
        errorMessage: errorMessage,
      ),
    );
  }

  if (!forceRefresh) {
    final remembered = _memory[cacheKey];
    final value = remembered?.value;
    // The age is checked here too, not just on the disk read: a session that
    // stays alive for days (backgrounded, then resumed) must not keep serving a
    // value from memory after its TTL has passed.
    if (remembered != null &&
        value is T &&
        DateTime.now().difference(remembered.cachedAt) <= ttl) {
      scheduleRevalidation(remembered.cachedAt);
      return value;
    }
    final entry = await ResponseCache.readEntry(cacheKey, maxAge: ttl);
    if (entry != null) {
      try {
        final decoded = await decode(entry.body);
        _remember(cacheKey, decoded as Object, entry.cachedAt);
        scheduleRevalidation(entry.cachedAt);
        return decoded;
      } catch (e) {
        // Unreadable payload (truncated write, or a shape this build no longer
        // understands). Treat it as a miss and refetch.
        developer.log(
          'discarding undecodable cache entry $cacheKey',
          name: 'response_cache',
          error: e,
        );
      }
    }
  }

  try {
    final body = await (_inFlight[cacheKey] ??= _fetchBody(
      uri: uri,
      cacheKey: cacheKey,
      errorMessage: errorMessage,
    ));
    final decoded = await decode(body);
    _remember(cacheKey, decoded as Object, DateTime.now());
    return decoded;
  } catch (error) {
    final stale = await ResponseCache.read(cacheKey);
    if (stale != null) {
      try {
        final value = await decode(stale);
        developer.log(
          'serving stale cache for $cacheKey after fetch failure',
          name: 'response_cache',
          error: error,
        );
        return value;
      } catch (_) {
        // Fall through to the original network error.
      }
    }
    rethrow;
  }
}

/// Refreshes [cacheKey] in the background and notifies listeners. Silent on
/// failure: the caller has already been given the cached value, and there is no
/// user action to prompt.
Future<void> _revalidate<T>({
  required Uri uri,
  required String cacheKey,
  required FutureOr<T> Function(String body) decode,
  required String Function(int statusCode) errorMessage,
}) async {
  if (_inFlight.containsKey(cacheKey)) return;
  try {
    final body = await (_inFlight[cacheKey] ??= _fetchBody(
      uri: uri,
      cacheKey: cacheKey,
      errorMessage: errorMessage,
    ));
    final decoded = (await decode(body)) as Object;
    _remember(cacheKey, decoded, DateTime.now());
    _notifyRevalidated(cacheKey, decoded);
  } catch (e) {
    developer.log(
      'background revalidation of $cacheKey failed',
      name: 'response_cache',
      error: e,
    );
  }
}

Future<String> _fetchBody({
  required Uri uri,
  required String cacheKey,
  required String Function(int statusCode) errorMessage,
}) async {
  try {
    final response = await _client.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception(errorMessage(response.statusCode));
    }
    // Decoded from `bodyBytes` as UTF-8 rather than via `response.body`, which
    // falls back to latin1 when a response omits its charset — that would
    // mangle Arabic and Russian prayer text on the way into the cache.
    final body = utf8.decode(response.bodyBytes);
    await ResponseCache.write(cacheKey, body);
    return body;
  } finally {
    _inFlight.remove(cacheKey);
  }
}

/// Empties the in-memory layer only, leaving the disk cache alone. For tests.
@visibleForTesting
void clearMemoryCache() {
  _memory.clear();
  _listeners.clear();
}

/// Puts [value] straight into the in-memory layer, as if it had been fetched at
/// [cachedAt]. Lets a widget test exercise the cached-data path without the
/// real file I/O that `testWidgets`' fake-async zone can't complete.
@visibleForTesting
void seedMemoryCache(String cacheKey, Object value, {DateTime? cachedAt}) =>
    _remember(cacheKey, value, cachedAt ?? DateTime.now());

/// Fires the listeners for [cacheKey] as a completed background revalidation
/// would. For tests; the real path is [getJsonCached] with `refreshAfter`.
@visibleForTesting
void debugNotifyRevalidated(String cacheKey, Object value) =>
    _notifyRevalidated(cacheKey, value);
