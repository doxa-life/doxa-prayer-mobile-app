import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'cache_policy.dart';

/// Disk cache for the people-group photos rendered by `AppImage`.
///
/// The default [DefaultCacheManager] keeps files for 30 days already, but the
/// app declares its own manager so the retention window is stated next to the
/// other cache policies and can be cleared on its own from the debug screen.
class AppImageCacheManager {
  AppImageCacheManager._();

  static const _key = 'doxa_image_cache';

  static final CacheManager instance = CacheManager(
    Config(
      _key,
      stalePeriod: CachePolicy.images,
      // Roughly the full UUPG list plus the photos in a month of prayer
      // content, so ordinary browsing never evicts an image before its time.
      maxNrOfCacheObjects: 400,
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
