import 'package:flutter_map/flutter_map.dart';

/// A [CameraFit] that frames exactly as [inner] does and then backs off by
/// [zoomOut] zoom levels.
///
/// Padding can only widen the frame by a fraction of a screen before it runs
/// out of room on a phone, so it can't express "open a level further out" —
/// each zoom level halves the scale. This does, and it applies after any
/// `maxZoom` cap, so the pull-back holds for a dense region that hit the cap
/// as much as for a sparse one that didn't.
class PulledBackCameraFit extends CameraFit {
  const PulledBackCameraFit({required this.inner, required this.zoomOut});

  /// The fit to frame on before backing off.
  final CameraFit inner;

  /// How many zoom levels to back off by. One level doubles the width and
  /// height of what's on screen.
  final double zoomOut;

  @override
  MapCamera fit(MapCamera camera) {
    final fitted = inner.fit(camera);
    return fitted.withPosition(
      // Zooming out past the camera's own floor would be clamped later anyway;
      // clamping here keeps the camera this returns self-consistent.
      zoom: fitted.clampZoom(fitted.zoom - zoomOut),
    );
  }
}
