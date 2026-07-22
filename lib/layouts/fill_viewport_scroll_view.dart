import 'package:flutter/material.dart';

/// A scroll view whose content fills the viewport when short and scrolls when
/// tall (e.g. at large accessibility font scales).
///
/// The child column can bottom-pin widgets with an
/// `Expanded(child: SizedBox.shrink())` spacer: when everything fits, the
/// spacer absorbs the slack and the widgets after it sit at the bottom; when
/// the content is taller than the viewport, the spacer collapses and the view
/// scrolls instead of overflowing.
///
/// With [padKeyboardInset] (the default), bottom scroll padding equal to the
/// keyboard height is added so content can be scrolled up above an overlaying
/// keyboard (use with `resizeToAvoidBottomInset: false` on the Scaffold).
///
/// The content is measured with [IntrinsicHeight], which imposes two rules on
/// the subtree built by [builder]:
/// - No lazy scrollables ([ListView] & co.) — they cannot report an intrinsic
///   height. Screens with a scrolling list should lay out the list themselves
///   instead of using this widget.
/// - No inner [LayoutBuilder]s — they throw during intrinsic measurement.
///   [builder] receives the available `maxWidth` so widgets that would
///   otherwise measure themselves (e.g. `ButtonBarWrap`) can be given it
///   explicitly: `ButtonBarWrap(maxWidth: maxWidth, ...)`.
class FillViewportScrollView extends StatelessWidget {
  const FillViewportScrollView({
    super.key,
    required this.builder,
    this.padKeyboardInset = true,
  });

  /// Builds the content column. `maxWidth` is the width the content is laid
  /// out in — pass it to any child that needs to measure the available width
  /// (a [LayoutBuilder] would break the intrinsic-height measurement).
  final Widget Function(BuildContext context, double maxWidth) builder;

  /// Whether to add bottom scroll padding equal to the keyboard inset, so the
  /// content can be scrolled above a keyboard that overlays the view.
  final bool padKeyboardInset;

  @override
  Widget build(BuildContext context) {
    final keyboardInset = padKeyboardInset
        ? MediaQuery.viewInsetsOf(context).bottom
        : 0.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: keyboardInset),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: builder(context, constraints.maxWidth),
            ),
          ),
        );
      },
    );
  }
}
