import 'dart:io' show HttpHeaders;

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

/// The [FileService] behind the app's image and map-tile caches: the package's
/// [HttpFileService] plus one guarantee — a body that arrived short is never
/// written to the cache.
///
/// `flutter_cache_manager` pipes a response straight to disk and never compares
/// what it wrote against `Content-Length`. A connection dropped mid-body
/// therefore finishes *without* an error, and the truncated file is committed
/// as a perfectly good cache entry. Every later read is then a cache **hit** on
/// bytes that will not decode, so `AppImage` falls through to its error
/// placeholder — and stays there for the full `CachePolicy.images` window,
/// because nothing invalidates an entry that the cache believes is valid. That
/// is how a handful of people-group photos go permanently missing on one
/// tester's device while every other device is fine.
///
/// Throwing at the end of a short stream turns that silent corruption into a
/// failed save. The failure happens before the cache entry is written, so the
/// bad download is simply not cached and the next attempt refetches it.
class VerifiedHttpFileService extends FileService {
  VerifiedHttpFileService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    final request = http.Request('GET', Uri.parse(url));
    if (headers != null) {
      request.headers.addAll(headers);
    }
    return _LengthCheckedResponse(await _httpClient.send(request));
  }
}

/// Raised when a response body ends at a different length than its
/// `Content-Length` promised. Surfaces as the `error` passed to `AppImage`'s
/// `errorWidget`.
class TruncatedDownloadException implements Exception {
  const TruncatedDownloadException(
    this.url, {
    required this.expected,
    required this.received,
  });

  final String url;
  final int expected;
  final int received;

  @override
  String toString() =>
      'TruncatedDownloadException: $url ended at $received bytes, '
      'Content-Length promised $expected';
}

/// Delegates every header-derived property to the package's own
/// [HttpGetResponse] — only [content] is wrapped.
class _LengthCheckedResponse implements FileServiceResponse {
  _LengthCheckedResponse(this._response)
    : _delegate = HttpGetResponse(_response);

  final http.StreamedResponse _response;
  final HttpGetResponse _delegate;

  @override
  Stream<List<int>> get content {
    final expected = contentLength;
    // Nothing to check against: either the body is chunked (no
    // `Content-Length`), or the client transparently decompressed it, in which
    // case the header describes the compressed size and not the bytes that
    // reach us.
    if (expected == null || _isCompressed) return _delegate.content;
    return _checkedLength(_delegate.content, expected);
  }

  bool get _isCompressed {
    final encoding = _response.headers[HttpHeaders.contentEncodingHeader];
    return encoding != null && encoding.trim().toLowerCase() != 'identity';
  }

  Stream<List<int>> _checkedLength(
    Stream<List<int>> source,
    int expected,
  ) async* {
    var received = 0;
    await for (final chunk in source) {
      received += chunk.length;
      yield chunk;
    }
    if (received != expected) {
      throw TruncatedDownloadException(
        _response.request?.url.toString() ?? '',
        expected: expected,
        received: received,
      );
    }
  }

  @override
  int? get contentLength => _delegate.contentLength;

  @override
  String? get eTag => _delegate.eTag;

  @override
  String get fileExtension => _delegate.fileExtension;

  @override
  int get statusCode => _delegate.statusCode;

  @override
  DateTime get validTill => _delegate.validTill;
}
