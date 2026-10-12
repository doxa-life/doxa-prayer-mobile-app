import 'package:flutter/material.dart';

/// Scales [child] down (never up) to fit exactly within whatever space the
/// parent gives it — text, images, and spacing shrink together — instead of
/// letting it overflow or scroll. Giving the child the full available width
/// up front (via the inner [SizedBox]) means [FittedBox] only ever has to
/// shrink for height, not width, so content isn't narrowed more than needed.
///
/// Use this to guarantee a screen fits on one page with no vertical
/// scroll/swipe, regardless of device height, font-scale setting, or how
/// long the content happens to be.
class FitToPage extends StatelessWidget {
  const FitToPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.topCenter,
          child: SizedBox(width: constraints.maxWidth, child: child),
        );
      },
    );
  }
}
