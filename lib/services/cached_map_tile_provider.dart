import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';

import 'map_config.dart';
import 'map_tile_cache_manager.dart';

/// A `flutter_map` tile provider that puts tiles through the app's own disk
/// cache instead of refetching them on every visit.
///
/// Built on `cached_network_image`, which the app already uses for
/// people-group photos, so this adds no dependency — and it avoids
/// `flutter_map_tile_caching`, which is GPL-licensed and therefore unusable
/// here.
///
/// Tiles above [MapConfig.maxCachedZoom] bypass the cache entirely: they are
/// still displayed, just not written to disk. See `map_tile_cache_manager.dart`
/// for why the cache is kept small.
class CachedMapTileProvider extends TileProvider {
  CachedMapTileProvider({super.headers});

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final url = getTileUrl(coordinates, options);
    if (coordinates.z > MapConfig.maxCachedZoom) {
      return NetworkImage(url, headers: headers);
    }
    return CachedNetworkImageProvider(
      url,
      cacheManager: MapTileCacheManager.instance,
      headers: headers,
    );
  }
}
