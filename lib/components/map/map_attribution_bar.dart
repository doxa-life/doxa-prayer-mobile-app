import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/map_config.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Always-visible attribution for the map's tiles.
///
/// Mapbox's terms require their attribution and OpenStreetMap's to be shown on
/// the map, so this is not decoration and must not be collapsed behind an info
/// button. Both entries link out to the pages the terms point at.
///
/// Stateful only to own its tap recognizers: a [TapGestureRecognizer] built
/// inside `build` is never disposed and leaks on every rebuild.
class MapAttributionBar extends StatefulWidget {
  const MapAttributionBar({super.key});

  @override
  State<MapAttributionBar> createState() => _MapAttributionBarState();
}

class _MapAttributionBarState extends State<MapAttributionBar> {
  late final TapGestureRecognizer _mapboxTap;
  late final TapGestureRecognizer _osmTap;

  @override
  void initState() {
    super.initState();
    _mapboxTap = TapGestureRecognizer()
      ..onTap = () => _open(MapConfig.mapboxAttributionUrl);
    _osmTap = TapGestureRecognizer()
      ..onTap = () => _open(MapConfig.osmAttributionUrl);
  }

  @override
  void dispose() {
    _mapboxTap.dispose();
    _osmTap.dispose();
    super.dispose();
  }

  void _open(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.caption.copyWith(color: AppColors.primary);
    final linkStyle = style.copyWith(decoration: TextDecoration.underline);
    return ColoredBox(
      color: AppColors.white.withValues(alpha: 0.8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: MapConfig.mapboxAttribution,
                style: linkStyle,
                recognizer: _mapboxTap,
              ),
              TextSpan(text: '  ', style: style),
              TextSpan(
                text: MapConfig.osmAttribution,
                style: linkStyle,
                recognizer: _osmTap,
              ),
            ],
          ),
          style: style,
        ),
      ),
    );
  }
}
