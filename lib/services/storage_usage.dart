import 'dart:io';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/painting.dart' show PaintingBinding;

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
  final paths = [
    (await ResponseCache.directory())?.path,
    cacheFolder(AppImageCacheManager.key)?.path,
    cacheFolder(MapTileCacheManager.key)?.path,
  ];
  // Walked on a background isolate: the photo and tile caches hold thousands
  // of files, and stat-ing each one on the UI isolate costs frames.
  // A top-level function rather than a closure, so nothing else of this
  // scope is sent along.
  final sizes = await compute(_sizesOf, paths);
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
  // The photo and map caches only delete the files their own index lists. A
  // file it lost track of — a download cut off, or one refused as short —
  // stayed on disk, still counted in Settings, and the button seemed to do
  // nothing. Each folder belongs to its cache alone, and its index is empty
  // now, so whatever is left in it goes too.
  try {
    _temp ??= await getTemporaryDirectory();
  } catch (_) {
    return; // No platform directories (tests).
  }
  for (final key in [AppImageCacheManager.key, MapTileCacheManager.key]) {
    final folder = Directory('${_temp!.path}${Platform.pathSeparator}$key');
    try {
      if (!await folder.exists()) continue;
      await for (final entity in folder.list(followLinks: false)) {
        await entity.delete(recursive: true);
      }
    } catch (_) {
      // A file in use or already gone: the rest is still cleared.
    }
  }
  // Decoded photos held in memory, so screens opened next read them afresh
  // rather than from what was just cleared.
  PaintingBinding.instance.imageCache.clear();
}

Future<List<int>> _sizesOf(List<String?> paths) => Future.wait([
  for (final path in paths) _sizeOf(path == null ? null : Directory(path)),
]);

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
