import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'image_cache_manager.dart';
import 'load_log.dart';
import 'map_tile_cache_manager.dart';
import 'response_cache.dart';

/// How much space the app's caches take, in bytes, by kind.
class StorageUsage {
  const StorageUsage({
    required this.data,
    required this.photos,
    required this.mapTiles,
  });

  /// Prayer content, the people-group list and profiles.
  final int data;

  /// People-group photos.
  final int photos;

  /// Map tiles.
  final int mapTiles;

  int get total => data + photos + mapTiles;
}

/// Measures the caches on disk. Only what the app downloaded and can download
/// again is counted — not the user's selections, reminders or settings, which
/// clearing the cache never touches.
Future<StorageUsage> measureStorage() async {
  // `flutter_cache_manager` keeps each cache's files in a folder named after
  // its key, in the temporary directory.
  Directory? cacheFolder(String key) => _temp == null
      ? null
      : Directory('${_temp!.path}${Platform.pathSeparator}$key');
  try {
    _temp ??= await getTemporaryDirectory();
  } catch (_) {
    // No platform directories (tests): the managed caches count as empty.
  }
  final sizes = await Future.wait([
    _sizeOf(await ResponseCache.directory()),
    _sizeOf(cacheFolder(AppImageCacheManager.key)),
    _sizeOf(cacheFolder(MapTileCacheManager.key)),
  ]);
  return StorageUsage(data: sizes[0], photos: sizes[1], mapTiles: sizes[2]);
}

Directory? _temp;

/// Empties every cache: responses (in memory too), photos and map tiles.
/// Whatever is needed next is downloaded again.
Future<void> clearAllCaches() async {
  LoadLog.record(LoadAction.discarded, 'all caches', note: 'cleared by user');
  await Future.wait([
    ResponseCache.clear(),
    AppImageCacheManager.clear(),
    MapTileCacheManager.clear(),
  ]);
}

Future<int> _sizeOf(Directory? dir) async {
  if (dir == null) return 0;
  var total = 0;
  try {
    if (!await dir.exists()) return 0;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) total += await entity.length();
    }
  } catch (_) {
    // A file removed mid-count (the cache tidying itself) — the rest still
    // counts.
  }
  return total;
}
