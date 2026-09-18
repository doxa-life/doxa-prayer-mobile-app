import 'package:doxa_prayer_mobile_app/services/image_failure_reporter.dart';
import 'package:flutter_test/flutter_test.dart';

/// Captured reports, in the order they were made.
final List<({Object error, String? reason})> _captured = [];

Future<void> _capture(Object error, StackTrace stack, {String? reason}) async {
  _captured.add((error: error, reason: reason));
}

void main() {
  setUp(() {
    _captured.clear();
    resetImageFailureReports();
    imageFailureReporter = _capture;
  });

  group('reportImageFailure', () {
    test('reports the url and the underlying error', () {
      final error = Exception('truncated');
      reportImageFailure('https://example.test/a.jpg', error);

      expect(_captured, hasLength(1));
      expect(_captured.single.error, same(error));
      expect(_captured.single.reason, contains('https://example.test/a.jpg'));
    });

    test('reports a url only once per launch', () {
      // errorWidget rebuilds every time the card scrolls back into view, so
      // without this one bad photo would report on every frame it is visible.
      for (var i = 0; i < 5; i++) {
        reportImageFailure('https://example.test/a.jpg', Exception('nope'));
      }
      expect(_captured, hasLength(1));
    });

    test('reports each distinct url', () {
      reportImageFailure('https://example.test/a.jpg', Exception('nope'));
      reportImageFailure('https://example.test/b.jpg', Exception('nope'));

      expect(_captured, hasLength(2));
      expect(_captured.first.reason, contains('a.jpg'));
      expect(_captured.last.reason, contains('b.jpg'));
    });

    test('stops after the session cap', () {
      // A user who is simply offline would otherwise report every photo they
      // scroll past; the first few say everything the rest would.
      for (var i = 0; i < 50; i++) {
        reportImageFailure('https://example.test/$i.jpg', Exception('offline'));
      }
      expect(_captured, hasLength(10));
    });

    test('a reset clears the session, as a fresh launch would', () {
      reportImageFailure('https://example.test/a.jpg', Exception('nope'));
      expect(_captured, hasLength(1));

      resetImageFailureReports();
      reportImageFailure('https://example.test/a.jpg', Exception('nope'));
      expect(_captured, hasLength(2));
    });
  });
}
