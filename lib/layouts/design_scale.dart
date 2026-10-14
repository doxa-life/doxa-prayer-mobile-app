import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// The screen the app's layouts are designed at — a standard iPhone, in
/// logical pixels.
const Size kDesignScreenSize = Size(393, 852);

/// How much larger than [kDesignScreenSize] this screen is, by whichever of its
/// width and height is proportionally smaller, so a design scaled by it always
/// fits. Never below 1: a screen smaller than the design keeps the design's
/// sizes rather than shrinking text and touch targets.
double designScaleOf(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  final scale = math.min(
    size.width / kDesignScreenSize.width,
    size.height / kDesignScreenSize.height,
  );
  return math.max(1, scale);
}

/// Lays [child] out as it would be at 1/[scale] of the space given, then draws
/// it [scale] times larger — text, padding, images and touch targets alike — so
/// a design keeps its proportions on any screen.
///
/// Unlike [Transform.scale], the scaled size is the size layout sees, so
/// neighbours make room for it; and unlike [FittedBox], it answers intrinsic
/// size queries, so it works inside an [IntrinsicHeight].
class UniformScale extends SingleChildRenderObjectWidget {
  const UniformScale({super.key, required this.scale, super.child})
    : assert(scale > 0);

  final double scale;

  @override
  RenderUniformScale createRenderObject(BuildContext context) =>
      RenderUniformScale(scale);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderUniformScale renderObject,
  ) {
    renderObject.scale = scale;
  }
}

class RenderUniformScale extends RenderProxyBox {
  RenderUniformScale(this._scale);

  double get scale => _scale;
  double _scale;
  set scale(double value) {
    if (value == _scale) return;
    _scale = value;
    markNeedsLayout();
  }

  Matrix4 get _transform => Matrix4.diagonal3Values(_scale, _scale, 1);

  @override
  double computeMinIntrinsicWidth(double height) =>
      (child?.getMinIntrinsicWidth(height / _scale) ?? 0) * _scale;

  @override
  double computeMaxIntrinsicWidth(double height) =>
      (child?.getMaxIntrinsicWidth(height / _scale) ?? 0) * _scale;

  @override
  double computeMinIntrinsicHeight(double width) =>
      (child?.getMinIntrinsicHeight(width / _scale) ?? 0) * _scale;

  @override
  double computeMaxIntrinsicHeight(double width) =>
      (child?.getMaxIntrinsicHeight(width / _scale) ?? 0) * _scale;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final child = this.child;
    if (child == null) return constraints.smallest;
    return constraints.constrain(
      child.getDryLayout(constraints / _scale) * _scale,
    );
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child.layout(constraints / _scale, parentUsesSize: true);
    size = constraints.constrain(child.size * _scale);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child == null) return;
    if (_scale == 1) {
      layer = null;
      context.paintChild(child, offset);
      return;
    }
    layer = context.pushTransform(
      needsCompositing,
      offset,
      _transform,
      (context, offset) => context.paintChild(child, offset),
      oldLayer: layer is TransformLayer ? layer as TransformLayer? : null,
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final child = this.child;
    if (child == null) return false;
    return result.addWithPaintTransform(
      transform: _transform,
      position: position,
      hitTest: (result, position) => child.hitTest(result, position: position),
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.multiply(_transform);
  }
}
