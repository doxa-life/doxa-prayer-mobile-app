import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'image_cache_manager.dart';
import 'map_tile_cache_manager.dart';

/// Tidies the photo and map-tile caches once the app has settled after launch.
///
/// The caches only ever delete what their index lists, and two kinds of file
/// escape that, both counted in Settings' storage figure:
///
///  * **Untracked files.** Every download writes a new file, and the old one
///    is removed only once the index has been updated. Two downloads of the
///    same photo overlapping — which the prefetch did on every launch and
///    every switch of group, before it learnt to skip photos already cached —
///    leave one of the files behind with nothing pointing at it. Nothing
///    expires it, so it stays for good.
///  * **Full-size photos.** Builds from before the server's compressed copies
///    cached each group's original, at well over a megabyte apiece — dozens of
///    MB on a phone that has been through them — and the cache keeps them for
///    the whole `CachePolicy.images` window.
///
/// Silent on failure: this only ever frees space.
Future<void> tidyImageCaches() async {
  // Each cache holds its index open for as long as the app runs, once it is
  // first used. Touched first, so the index is never closed under it by the
  // open/close pairs below.
  AppImageCacheManager.instance;
  MapTileCacheManager.instance;
  for (final config in [
    AppImageCacheManager.config,
    MapTileCacheManager.config,
  ]) {
    await _deleteUntrackedFiles(config);
  }
  await _dropFullSizePhotosOnce();
}

/// A file younger than this may be a download still being written, which the
/// index doesn't list until it is finished.
const Duration _inProgressGrace = Duration(minutes: 5);

Future<void> _deleteUntrackedFiles(Config config) async {
  final repo = config.repo;
  try {
    await repo.open();
  } catch (e) {
    developer.log(
      'cache index unavailable for ${config.cacheKey}',
      name: 'cache_cleanup',
      error: e,
    );
    return;
  }
  try {
    final tracked = {
      for (final object in await repo.getAllObjects()) object.relativePath,
    };
    // Where `flutter_cache_manager` keeps the files: a folder named after the
    // cache, in the temporary directory.
    final base = await getTemporaryDirectory();
    final folder = Directory(
      '${base.path}${Platform.pathSeparator}${config.cacheKey}',
    );
    if (!await folder.exists()) return;
    final cutoff = DateTime.now().subtract(_inProgressGrace);
    var deleted = 0;
    await for (final entity in folder.list(followLinks: false)) {
      if (entity is! File) continue;
      if (tracked.contains(entity.uri.pathSegments.last)) continue;
      if ((await entity.lastModified()).isAfter(cutoff)) continue;
      await entity.delete();
      deleted++;
    }
    if (deleted > 0) {
      developer.log(
        'removed $deleted untracked files from ${config.cacheKey}',
        name: 'cache_cleanup',
      );
    }
  } catch (e) {
    developer.log(
      'cache tidy failed for ${config.cacheKey}',
      name: 'cache_cleanup',
      error: e,
    );
  } finally {
    // Balances the open above; the cache's own connection stays open.
    await repo.close();
  }
}

const String _fullSizeDroppedKey = 'image_cache_full_size_dropped_v1';

/// Larger than any of the server's compressed copies (≤1024 px JPEGs, the
/// biggest around 140 KB), and well under the originals (1 MB and up).
const int _fullSizeThreshold = 512 * 1024;

/// Once per install: compressed copies are what every build now shows, so a
/// photo this big can only be an original left by an older build. Run once
/// rather than every launch, so a group the server ever serves without a
/// compressed copy isn't fetched again on each start.
Future<void> _dropFullSizePhotosOnce() async {
  final prefs = SharedPreferencesAsync();
  try {
    if (await prefs.getBool(_fullSizeDroppedKey) ?? false) return;
    final repo = AppImageCacheManager.config.repo;
    await repo.open();
    final List<CacheObject> objects;
    try {
      objects = await repo.getAllObjects();
    } finally {
      await repo.close();
    }
    for (final object in objects) {
      if ((object.length ?? 0) > _fullSizeThreshold) {
        await AppImageCacheManager.instance.removeFile(object.key);
      }
    }
    await prefs.setBool(_fullSizeDroppedKey, true);
  } catch (e) {
    developer.log(
      'dropping full-size photos failed',
      name: 'cache_cleanup',
      error: e,
    );
  }
}
