import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Mapbox settings for the people-group map.
///
/// The token is a *public* (`pk.…`) token read from `.env`, which is bundled as
/// an app asset — so it ships inside the binary and can be extracted. Restrict
/// it in the Mapbox dashboard; that, not secrecy, is what limits its use.
class MapConfig {
  const MapConfig._();

  /// The basemap. `light-v11` is what doxa.life's research map boots with, and
  /// a quiet basemap is what the coloured pins need underneath them.
  static const String styleId = 'light-v11';

  /// Tiles are requested at 512 px @1x rather than @2x. @2x is sharper but
  /// costs four times the bytes, both on the wire and in the tile cache —
  /// which matters because Mapbox bills per tile request.
  static const int tileSize = 512;

  /// Mapbox's 512 px raster tiles are indexed on a grid one zoom level coarser
  /// than the 256 px grid `flutter_map` (like Leaflet) computes tile
  /// coordinates on. Without this offset the basemap is fetched for the wrong
  /// place entirely — pins over Brazil on tiles showing northern Canada.
  static const double tileZoomOffset = -1;

  /// Above this *tile-grid* zoom (so one coarser than the camera's zoom, see
  /// [tileZoomOffset]) tiles are fetched but not written to disk. Deep zooms
  /// burn a lot of tiles for little re-use: the map opens at a regional fit,
  /// and nobody comes back to the same street twice.
  static const int maxCachedZoom = 8;

  /// A launch-time `--dart-define` wins over `.env`, matching how `ApiConfig`
  /// resolves the API base URL.
  static const String _dartDefineToken = String.fromEnvironment('MAPBOX_TOKEN');

  static String get token {
    if (_dartDefineToken.isNotEmpty) return _dartDefineToken;
    return dotenv.maybeGet('MAPBOX_TOKEN', fallback: '') ?? '';
  }

  /// False when no token is configured. The map button hides itself rather than
  /// opening a screen that can only ever show grey squares.
  static bool get isConfigured => token.isNotEmpty;

  /// The raster-tiles template `TileLayer` interpolates `{z}/{x}/{y}` into.
  static String get tileUrlTemplate =>
      'https://api.mapbox.com/styles/v1/mapbox/$styleId/tiles/$tileSize/'
      '{z}/{x}/{y}?access_token=$token';

  /// Mapbox's terms require visible attribution for both Mapbox and the
  /// OpenStreetMap data underneath it.
  static const String mapboxAttribution = '© Mapbox';
  static const String osmAttribution = '© OpenStreetMap';
  static const String mapboxAttributionUrl =
      'https://www.mapbox.com/about/maps/';
  static const String osmAttributionUrl =
      'https://www.openstreetmap.org/copyright';
}
