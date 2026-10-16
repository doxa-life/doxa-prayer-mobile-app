import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// What happened to a piece of data.
enum LoadAction {
  /// A request went out.
  request,

  /// A request came back, with its status, size and how long it took.
  response,

  /// A request failed before a response arrived.
  failure,

  /// A second caller asked for something already on its way, and shares that
  /// request rather than making its own.
  joined,

  /// Served from memory, already decoded — no I/O at all.
  memoryHit,

  /// Read from the disk cache.
  diskHit,

  /// Not cached, or cached too long ago: it has to be fetched.
  miss,

  /// Written to the disk cache.
  stored,

  /// A cached copy is being refreshed in the background.
  revalidate,

  /// A background refresh landed and replaced what screens were showing.
  replaced,

  /// The fetch failed and an out-of-date cached copy was served instead.
  stale,

  /// Dropped: pushed out of memory, too old, unreadable, or cleared.
  discarded,
}

/// One entry in the [LoadLog].
class LoadEvent {
  LoadEvent({
    required this.action,
    required this.subject,
    this.bytes,
    this.duration,
    this.status,
    this.note,
  }) : at = DateTime.now();

  final DateTime at;
  final LoadAction action;

  /// What it is about: a URL, or a cache key.
  final String subject;
  final int? bytes;
  final Duration? duration;
  final int? status;
  final String? note;

  @override
  String toString() {
    final parts = <String>[
      _clock(at),
      action.name.padRight(10),
      subject,
      if (status != null) 'HTTP $status',
      if (bytes != null) formatBytes(bytes!),
      if (duration != null) '${duration!.inMilliseconds} ms',
      ?note,
    ];
    return parts.join('  ');
  }
}

/// Everything the app loads, as it loads it: each request with its size and
/// timing, each cache hit and miss, and each time something is refreshed or
/// dropped.
///
/// Every line is also printed with a `[load]` prefix, so it appears in the
/// Xcode console (and `flutter run`, and `adb logcat`) while the app is in use
/// — filter the console on `[load]` to see only these. The debug screen shows
/// the same log on the device, and prints a per-item summary on demand.
///
/// On in debug and profile builds. A release build only logs when built with
/// `--dart-define=LOAD_LOG=true`, so the App Store build pays nothing for it.
class LoadLog {
  LoadLog._();

  static const bool enabled = !kReleaseMode || bool.fromEnvironment('LOAD_LOG');

  /// How many events are kept for the on-device view. The console has them
  /// all.
  static const int capacity = 1000;

  static final List<LoadEvent> _events = <LoadEvent>[];

  /// Bumped on every event, for a view to rebuild on.
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  /// The most recent events, oldest first.
  static List<LoadEvent> get events => List.unmodifiable(_events);

  /// Per subject: how often it was requested, served from cache, and so on.
  static final Map<String, _Tally> _tallies = <String, _Tally>{};

  static void record(
    LoadAction action,
    String subject, {
    int? bytes,
    Duration? duration,
    int? status,
    String? note,
  }) {
    if (!enabled) return;
    final tally = _tallies.putIfAbsent(subject, _Tally.new)..add(action, bytes);
    // A second fetch of the same thing in one session is the case worth
    // spotting, so the line says so.
    final repeat = action == LoadAction.request && tally.requests > 1
        ? 'request #${tally.requests} this session'
        : null;
    final event = LoadEvent(
      action: action,
      subject: subject,
      bytes: bytes,
      duration: duration,
      status: status,
      note: [?note, ?repeat].join('; ').ifEmptyNull,
    );
    _events.add(event);
    if (_events.length > capacity) _events.removeAt(0);
    debugPrint('[load] $event');
    changes.value++;
  }

  /// Forgets everything logged so far.
  static void clear() {
    _events.clear();
    _tallies.clear();
    changes.value++;
  }

  /// One line per subject, most-requested first: how many times it was
  /// fetched over the network, served from memory or disk, and dropped, and
  /// how much it cost in total.
  static List<String> summary() {
    final rows = _tallies.entries.toList()
      ..sort((a, b) {
        final byRequests = b.value.requests.compareTo(a.value.requests);
        return byRequests != 0
            ? byRequests
            : b.value.bytes.compareTo(a.value.bytes);
      });
    return [
      for (final MapEntry(key: subject, value: t) in rows)
        '${t.requests} req · ${t.memoryHits} mem · ${t.diskHits} disk · '
            '${t.discards} dropped · ${formatBytes(t.bytes)}  $subject',
    ];
  }

  /// Prints [summary] to the console.
  static void printSummary() {
    debugPrint('[load] ---- summary: ${_tallies.length} items ----');
    for (final line in summary()) {
      debugPrint('[load] $line');
    }
    debugPrint('[load] ---- end of summary ----');
  }
}

class _Tally {
  int requests = 0;
  int memoryHits = 0;
  int diskHits = 0;
  int discards = 0;

  /// Bytes downloaded.
  int bytes = 0;

  void add(LoadAction action, int? size) {
    switch (action) {
      case LoadAction.request:
        requests++;
      case LoadAction.response:
        bytes += size ?? 0;
      case LoadAction.memoryHit:
        memoryHits++;
      case LoadAction.diskHit:
        diskHits++;
      case LoadAction.discarded:
        discards++;
      default:
        break;
    }
  }
}

/// An HTTP client that logs every request it sends to the [LoadLog]: when it
/// went out, and, once the whole body has arrived, its status, size and how
/// long it took.
///
/// Installed for the whole app in `main` with `http.runWithClient`, so every
/// `http.get`/`http.post` and every `http.Client()` — the API cache, the image
/// and map-tile caches, and the one-off calls such as signup and analytics —
/// goes through it without any of them knowing. Requests made by native code
/// (the Mapbox SDK, Firebase, OneSignal) don't use Dart's HTTP and aren't seen.
class LoggingClient extends http.BaseClient {
  LoggingClient(this._inner);

  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final subject = '${request.method} ${request.url}';
    LoadLog.record(LoadAction.request, subject);
    final watch = Stopwatch()..start();
    final http.StreamedResponse response;
    try {
      response = await _inner.send(request);
    } catch (e) {
      LoadLog.record(
        LoadAction.failure,
        subject,
        duration: watch.elapsed,
        note: '$e',
      );
      rethrow;
    }
    // Counted as the body streams through, so the size is what actually
    // arrived, and the time includes downloading it, not just the headers.
    var received = 0;
    final body = response.stream.transform(
      StreamTransformer<List<int>, List<int>>.fromHandlers(
        handleData: (chunk, sink) {
          received += chunk.length;
          sink.add(chunk);
        },
        handleError: (error, stack, sink) {
          LoadLog.record(
            LoadAction.failure,
            subject,
            bytes: received,
            duration: watch.elapsed,
            status: response.statusCode,
            note: 'body cut off: $error',
          );
          sink.addError(error, stack);
        },
        handleDone: (sink) {
          LoadLog.record(
            LoadAction.response,
            subject,
            bytes: received,
            duration: watch.elapsed,
            status: response.statusCode,
          );
          sink.close();
        },
      ),
    );
    return http.StreamedResponse(
      body,
      response.statusCode,
      contentLength: response.contentLength,
      request: response.request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }

  @override
  void close() => _inner.close();
}

String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
}

String _clock(DateTime t) {
  String two(int n) => n.toString().padLeft(2, '0');
  final ms = t.millisecond.toString().padLeft(3, '0');
  return '${two(t.hour)}:${two(t.minute)}:${two(t.second)}.$ms';
}

extension on String {
  String? get ifEmptyNull => isEmpty ? null : this;
}
