import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;

import '../../l10n/app_localizations.dart';
import '../../models/people_group.dart';
import '../../services/map_screen_offsets.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';
import '../buttons/button_link.dart';
import '../misc/engagement_status_pill.dart';
import '../misc/hyphenated_text.dart';
import '../misc/selected_pill.dart';
import 'map_tooltip_image.dart';

/// Widest the tooltip gets. Narrower than the screen on purpose: it is a
/// callout about one pin, and a full-width sheet would hide the neighbours the
/// user is comparing it with.
const double _maxWidth = 300;

/// Gap kept between the tooltip and the screen edges.
const double _edgeInset = AppSpacing.md;

/// Size of the arrow that points from the bubble to its pin.
const double _arrowWidth = 18;
const double _arrowHeight = 10;

/// How close the arrow may get to the bubble's corners — any closer and it
/// runs into the rounded corner.
const double _arrowInset = 24;

/// Space between the arrow's tip and the pin's centre, so the tip lands just
/// clear of the heart rather than on top of it.
const double _pinClearance = 14;

/// Roughly how tall the tooltip is at the default text size. Only decides
/// whether it opens above or below its pin — the layout itself is never fixed
/// to it.
const double _estimatedHeight = 200;

const double _radius = 16;

/// The callout for the selected pin: it grows out of the pin, stays attached
/// to it while the map pans and zooms, and shrinks back into it when closed.
///
/// A child of `FlutterMap`, so it reads the live camera and needs no wiring to
/// follow the map. Opens above its pin, or below when the pin is too close to
/// the top for it to fit, and slides sideways to stay on screen with its arrow
/// still pointing at the pin.
class PeopleGroupPinTooltipLayer extends StatefulWidget {
  const PeopleGroupPinTooltipLayer({
    super.key,
    required this.group,
    required this.isSubscribed,
    required this.onPray,
    required this.onMoreInfo,
    required this.onClose,
  });

  /// The group to show, or null to close the tooltip.
  final PeopleGroup? group;

  final bool Function(PeopleGroup group) isSubscribed;
  final void Function(PeopleGroup group) onPray;
  final void Function(PeopleGroup group) onMoreInfo;
  final VoidCallback onClose;

  @override
  State<PeopleGroupPinTooltipLayer> createState() =>
      _PeopleGroupPinTooltipLayerState();
}

class _PeopleGroupPinTooltipLayerState extends State<PeopleGroupPinTooltipLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
    reverseDuration: const Duration(milliseconds: 180),
  );

  /// A slight overshoot on the way in, so the bubble springs out of the pin;
  /// a plain ease on the way out, so closing never bounces.
  late final Animation<double> _scale = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeInCubic,
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.6, curve: Curves.easeOut),
    reverseCurve: Curves.easeIn,
  );

  /// What is on screen. Lags [PeopleGroupPinTooltipLayer.group] while the
  /// tooltip shrinks away, so the closing animation still has a group to draw.
  PeopleGroup? _shown;

  @override
  void initState() {
    super.initState();
    _shown = widget.group;
    if (_shown != null) _open();
  }

  @override
  void didUpdateWidget(PeopleGroupPinTooltipLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.group;
    if (next == null) {
      if (_shown != null) _close();
      return;
    }
    if (next.slug != _shown?.slug || _controller.status.isDismissed) {
      // A different pin: the new tooltip grows out of *its* pin from scratch
      // rather than the old one morphing across the map.
      _shown = next;
      _open();
    } else {
      _shown = next;
    }
  }

  /// Read from the platform rather than `MediaQuery`, because the first open
  /// happens in `initState`, before inherited widgets can be looked up.
  bool get _reduceMotion => WidgetsBinding
      .instance
      .platformDispatcher
      .accessibilityFeatures
      .disableAnimations;

  void _open() {
    if (_reduceMotion) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  Future<void> _close() async {
    if (_reduceMotion) {
      _controller.value = 0;
    } else {
      await _controller.reverse();
    }
    // Reopened on another pin while closing: keep that one.
    if (!mounted || widget.group != null) return;
    setState(() => _shown = null);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final group = _shown;
    if (group == null || !group.hasLocation) return const SizedBox.shrink();

    final camera = MapCamera.of(context);
    final mapSize = camera.nonRotatedSize;
    final anchor = nearestScreenOffsetOf(
      camera,
      LatLng(group.latitude!, group.longitude!),
    );

    final width = math.min(_maxWidth, mapSize.width - 2 * _edgeInset);
    // Centred on the pin where there's room, pushed in from the screen edges
    // where there isn't — but never so far that the arrow leaves the bubble,
    // so a pin panned off screen takes its tooltip with it.
    final maxLeft = math.max(_edgeInset, mapSize.width - _edgeInset - width);
    final left = (anchor.dx - width / 2)
        .clamp(_edgeInset, maxLeft)
        .clamp(anchor.dx - width + _arrowInset, anchor.dx - _arrowInset);
    final arrowX = anchor.dx - left;

    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final above =
        anchor.dy - _pinClearance - _estimatedHeight * textScale >= _edgeInset;

    final bubble = _Bubble(
      group: group,
      arrowX: arrowX,
      pointsDown: above,
      isSubscribed: widget.isSubscribed(group),
      onPray: () => widget.onPray(group),
      onMoreInfo: () => widget.onMoreInfo(group),
      onClose: widget.onClose,
    );

    // Grows from the arrow's tip, so it reads as coming out of the pin.
    final origin = Alignment(arrowX / width * 2 - 1, above ? 1 : -1);
    final animated = FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        alignment: origin,
        child: bubble,
      ),
    );

    return SizedBox.expand(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: left,
            width: width,
            top: above ? null : anchor.dy + _pinClearance,
            bottom: above ? mapSize.height - anchor.dy + _pinClearance : null,
            child: animated,
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.group,
    required this.arrowX,
    required this.pointsDown,
    required this.isSubscribed,
    required this.onPray,
    required this.onMoreInfo,
    required this.onClose,
  });

  final PeopleGroup group;
  final double arrowX;
  final bool pointsDown;
  final bool isSubscribed;
  final VoidCallback onPray;
  final VoidCallback onMoreInfo;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final engagement = group.engagementStatusValue;
    const padding = AppSpacing.lg;
    // Taps that land on the bubble but not on one of its buttons stop here;
    // otherwise they would fall through to the map and close it, or select a
    // pin hidden underneath.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Material(
        color: AppColors.surface,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.45),
        shape: _BubbleBorder(arrowX: arrowX, pointsDown: pointsDown),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            padding,
            padding + (pointsDown ? 0 : _arrowHeight),
            AppSpacing.xs,
            padding + (pointsDown ? _arrowHeight : 0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.md,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.md,
                children: [
                  MapTooltipImage(
                    url: group.imageUrl,
                    semanticLabel: group.name,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: AppSpacing.xs,
                      children: [
                        HyphenatedText(
                          group.name,
                          softWrap: true,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: [
                            if (engagement != null)
                              EngagementStatusPill(
                                engaged: engagement == 'engaged',
                              ),
                            if (isSubscribed) SelectedPill(label: l.selected),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox.square(
                    dimension: 36,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 20,
                      icon: const Icon(Icons.close, color: AppColors.primary),
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).closeButtonTooltip,
                      onPressed: onClose,
                    ),
                  ),
                ],
              ),
              // A Wrap so the two reflow onto separate lines instead of
              // overflowing at large font scales, as on the people-group cards.
              Padding(
                padding: const EdgeInsets.only(right: padding - AppSpacing.xs),
                child: SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.sm,
                    children: [
                      ButtonLink(label: l.moreInfo, onPressed: onMoreInfo),
                      ActionButton(
                        label: l.pray,
                        onPressed: onPray,
                        color: ActionButtonColor.secondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A rounded rectangle with an arrow on its top or bottom edge, [arrowX] from
/// its left. One outline rather than a box plus a separate triangle, so the
/// shadow follows the arrow too and the two never show a seam.
class _BubbleBorder extends ShapeBorder {
  const _BubbleBorder({required this.arrowX, required this.pointsDown});

  final double arrowX;
  final bool pointsDown;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only(
    top: pointsDown ? 0 : _arrowHeight,
    bottom: pointsDown ? _arrowHeight : 0,
  );

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final body = pointsDown
        ? Rect.fromLTRB(
            rect.left,
            rect.top,
            rect.right,
            rect.bottom - _arrowHeight,
          )
        : Rect.fromLTRB(
            rect.left,
            rect.top + _arrowHeight,
            rect.right,
            rect.bottom,
          );
    final maxX = math.max(_arrowInset, rect.width - _arrowInset);
    final x = rect.left + arrowX.clamp(_arrowInset, maxX);
    // The arrow's base tucks a pixel inside the box so the union has no gap.
    final baseY = pointsDown ? body.bottom - 1 : body.top + 1;
    final tipY = pointsDown ? rect.bottom : rect.top;
    final arrow = Path()
      ..moveTo(x - _arrowWidth / 2, baseY)
      ..lineTo(x, tipY)
      ..lineTo(x + _arrowWidth / 2, baseY)
      ..close();
    final box = Path()
      ..addRRect(RRect.fromRectAndRadius(body, const Radius.circular(_radius)));
    return Path.combine(PathOperation.union, box, arrow);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;

  @override
  bool operator ==(Object other) =>
      other is _BubbleBorder &&
      other.arrowX == arrowX &&
      other.pointsDown == pointsDown;

  @override
  int get hashCode => Object.hash(arrowX, pointsDown);
}
