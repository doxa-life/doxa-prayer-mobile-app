import 'dart:convert';

import 'package:doxa_prayer_mobile_app/services/verified_http_file_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Serves [chunks] as the body, with whatever [headers] the test wants — so a
/// response can promise one length and deliver another, which is exactly the
/// dropped connection this service exists to catch.
MockClient _client(
  List<List<int>> chunks, {
  required Map<String, String> headers,
}) {
  return MockClient.streaming((request, bodyStream) async {
    return http.StreamedResponse(
      Stream.fromIterable(chunks),
      200,
      headers: headers,
      contentLength: int.tryParse(headers['content-length'] ?? ''),
      request: request,
    );
  });
}

Future<List<int>> _download(
  MockClient client, {
  String url = 'https://example.test/photo.jpg',
}) async {
  final service = VerifiedHttpFileService(httpClient: client);
  final response = await service.get(url);
  final bytes = <int>[];
  await for (final chunk in response.content) {
    bytes.addAll(chunk);
  }
  return bytes;
}

void main() {
  group('VerifiedHttpFileService', () {
    test('passes a complete body straight through', () async {
      final body = utf8.encode('a complete jpeg');
      final bytes = await _download(
        _client(
          [body.sublist(0, 5), body.sublist(5)],
          headers: {
            'content-length': '${body.length}',
            'content-type': 'image/jpeg',
          },
        ),
      );
      expect(bytes, body);
    });

    test('throws when the body ends short of Content-Length', () async {
      // The whole point: a connection that drops mid-body ends the stream
      // cleanly, so without this check the truncated bytes would be written to
      // disk and cached as a valid photo.
      expect(
        _download(
          _client(
            [utf8.encode('half a jp')],
            headers: {'content-length': '20', 'content-type': 'image/jpeg'},
          ),
        ),
        throwsA(
          isA<TruncatedDownloadException>()
              .having((e) => e.expected, 'expected', 20)
              .having((e) => e.received, 'received', 9)
              .having((e) => e.url, 'url', 'https://example.test/photo.jpg'),
        ),
      );
    });

    test('emits the partial bytes before throwing', () async {
      // The bytes still reach the sink; it is the error at the end of the
      // stream that stops `flutter_cache_manager` committing the cache entry.
      final seen = <int>[];
      await expectLater(() async {
        final service = VerifiedHttpFileService(
          httpClient: _client(
            [utf8.encode('abc')],
            headers: {'content-length': '10'},
          ),
        );
        final response = await service.get('https://example.test/p.jpg');
        await for (final chunk in response.content) {
          seen.addAll(chunk);
        }
      }(), throwsA(isA<TruncatedDownloadException>()));
      expect(utf8.decode(seen), 'abc');
    });

    test('skips the check when there is no Content-Length', () async {
      // A chunked response has nothing to verify against; it must still work.
      final bytes = await _download(
        _client(
          [utf8.encode('chunked')],
          headers: {'content-type': 'image/jpeg'},
        ),
      );
      expect(utf8.decode(bytes), 'chunked');
    });

    test('skips the check on a compressed body', () async {
      // The client decompresses transparently, so `Content-Length` describes
      // the compressed size and would never match the bytes that arrive.
      final bytes = await _download(
        _client(
          [utf8.encode('decompressed and longer than the header says')],
          headers: {'content-length': '12', 'content-encoding': 'gzip'},
        ),
      );
      expect(
        utf8.decode(bytes),
        'decompressed and longer than the header says',
      );
    });

    test('still checks when Content-Encoding is identity', () async {
      expect(
        _download(
          _client(
            [utf8.encode('short')],
            headers: {'content-length': '99', 'content-encoding': 'identity'},
          ),
        ),
        throwsA(isA<TruncatedDownloadException>()),
      );
    });

    test('carries the headers the cache stores alongside the file', () async {
      final service = VerifiedHttpFileService(
        httpClient: _client(
          [utf8.encode('x')],
          headers: {
            'content-length': '1',
            'content-type': 'image/jpeg',
            'etag': '"abc123"',
            'cache-control': 'max-age=14400',
          },
        ),
      );
      final response = await service.get('https://example.test/p.jpg');
      expect(response.statusCode, 200);
      expect(response.eTag, '"abc123"');
      expect(response.fileExtension, '.jpg');
      expect(
        response.validTill.difference(DateTime.now()).inMinutes,
        closeTo(240, 1),
      );
    });
  });
}
