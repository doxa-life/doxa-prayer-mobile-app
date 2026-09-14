import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'cache_policy.dart';

/// Disk cache for the people-group map's Mapbox tiles.
///
/// Separate from `AppImageCacheManager` so map tiles can never evict the
/// people-group photos, and so the two can be given very different limits:
/// photos are few and long-lived, tiles are many and short-lived.
///
/// Deliberately small and deliberately expiring. Mapbox's terms allow caching
/// tiles for performance but not building a persistent offline map, so the
/// window is days rather than the photos' month, and only tiles at zoom
/// `MapConfig.maxCachedZoom` or below are written at all.
class MapTileCacheManager {
  MapTileCacheManager._();

  static const _key = 'doxa_map_tile_cache';

  /// At 512 px @1x a `light-v11` tile is roughly 10 KB, so 500 objects is on
  /// the order of 5 MB — about five people groups' worth of browsing.
  static const int maxTiles = 500;

  static final CacheManager instance = CacheManager(
    Config(
      _key,
      stalePeriod: CachePolicy.mapTiles,
      maxNrOfCacheObjects: maxTiles,
    ),
  );

  static Future<void> clear() => instance.emptyCache();
}
