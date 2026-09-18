import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'cache_policy.dart';
import 'verified_http_file_service.dart';

/// Disk cache for the people-group photos rendered by `AppImage`.
///
/// The default [DefaultCacheManager] keeps files for 30 days already, but the
/// app declares its own manager so the retention window is stated next to the
/// other cache policies and can be cleared on its own from the debug screen.
class AppImageCacheManager {
  AppImageCacheManager._();

  static const _key = 'doxa_image_cache';

  /// The whole UUPG browse list is 938 *distinct* photo URLs, not one per
  /// group: 2,107 groups share them, and 1,100-odd of those fall back to one
  /// of 14 generic per-continent images. The cache is keyed by URL, so 938
  /// entries hold every photo the browse list can show. The rest is headroom
  /// for a month of prayer-content photos.
  ///
  /// The previous 400 claimed to be "roughly the full UUPG list" and was less
  /// than half of it, so scrolling browse evicted photos the user was still
  /// looking at and refetched them on the way back up.
  static const int maxPhotos = 1200;

  static final CacheManager instance = CacheManager(
    Config(
      _key,
      stalePeriod: CachePolicy.images,
      maxNrOfCacheObjects: maxPhotos,
      // Refuses to cache a download that arrived short — see the class doc.
      // Without it a single dropped connection poisons that photo for the
      // whole `CachePolicy.images` window.
      fileService: VerifiedHttpFileService(),
    ),
  );

  /// Downloads [url] into the cache without displaying it — used by the startup
  /// prefetch so the first paint of the Pray tab has its photos already local.
  /// Failures are swallowed: this is best-effort warming.
  static Future<void> warm(String? url) async {
    if (url == null || url.isEmpty) return;
    try {
      await instance.downloadFile(url);
    } catch (_) {
      // Offline, or a bad URL — the widget will show its placeholder.
    }
  }

  static Future<void> clear() => instance.emptyCache();
}
