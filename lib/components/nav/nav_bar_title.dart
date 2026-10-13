import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../services/hyphenation_service.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../misc/hyphenated_text.dart';

/// The title inside a nav bar, wrapping over as many lines as it needs.
///
/// [AppBar] wraps its title in a `DefaultTextStyle` with `softWrap: false` and
/// `overflow: ellipsis`, and takes a fixed [kToolbarHeight] — so a long title is
/// cut to one line with an ellipsis, and once anything does force a second line
/// (an explicit newline, or a hyphenated break) the bar is too short to show it.
///
/// This overrides the wrapping, and [preferredSizeFor] gives the bar the height
/// the wrapped title actually needs. Callers must pass that same height to
/// `AppBar(toolbarHeight:)` as well as to `preferredSize`, or the two disagree
/// and it clips again.
///
/// Measurement and layout have to agree, so the title is laid out in exactly the
/// width that was measured — [widthFor] deliberately under-estimates what the
/// toolbar allows rather than risk an extra line the height does not cover.
class NavBarTitle extends StatelessWidget {
  const NavBarTitle(
    this.title, {
    super.key,
    required this.color,
    required this.width,
  });

  final String title;
  final Color color;

  /// The width to lay the title out in — from [widthFor].
  final double width;

  /// Space above and below the title inside the bar.
  static const double _verticalPadding = AppSpacing.sm;

  /// A pathological title cannot be allowed to eat the whole viewport.
  static const int maxLines = 3;

  /// Trimmed off [widthFor] so the title can never be given less room than it
  /// was measured in.
  static const double _safetyMargin = 2;

  /// The title style, deliberately **not** inheriting.
  ///
  /// [AppBar] supplies its own `titleTextStyle` through a `DefaultTextStyle`,
  /// and that style carries a line-height multiplier. Inheriting it would make
  /// the rendered text taller per line than [preferredSizeFor] measured, and the
  /// bar would clip by exactly that difference. Not inheriting makes the two
  /// identical by construction, and matches the `h2` used for headings
  /// elsewhere in the app.
  static TextStyle styleFor(Color color) =>
      AppTypography.h2.copyWith(color: color, inherit: false);

  /// The width a centred [AppBar] title gets, given how many icon buttons sit
  /// either side of it.
  ///
  /// The wider of the leading and trailing slots is reserved on *both* sides.
  /// `NavigationToolbar` only centres the middle slot on the screen when it
  /// clears both slots; a title box sized to what is left after a back button
  /// alone is too wide for that, so the toolbar pushes the box against the back
  /// button and the centred text inside it lands right of the screen's middle.
  static double widthFor(
    BuildContext context, {
    required bool hasLeading,
    int actionCount = 0,
  }) {
    const leadingWidth = 56.0;
    const actionWidth = 48.0;
    const spacing = NavigationToolbar.kMiddleSpacing;
    final sideWidth = math.max(
      hasLeading ? leadingWidth : 0.0,
      actionCount * actionWidth,
    );
    final available =
        MediaQuery.sizeOf(context).width -
        2 * sideWidth -
        2 * spacing -
        _safetyMargin;
    return math.max(available, 0);
  }

  /// The height the bar needs for [title], never less than [kToolbarHeight].
  ///
  /// Pass the result to both `AppBar(toolbarHeight:)` and `preferredSize`.
  static Size preferredSizeFor(
    BuildContext context, {
    String? title,
    required bool hasLeading,
    int actionCount = 0,
  }) {
    if (title == null || title.isEmpty) {
      return const Size.fromHeight(kToolbarHeight);
    }
    final width = widthFor(
      context,
      hasLeading: hasLeading,
      actionCount: actionCount,
    );
    final style = _measureStyle(context);
    final painter = TextPainter(
      text: TextSpan(
        text: _laidOut(context, title, style, width),
        style: style,
      ),
      textDirection: Directionality.of(context),
      maxLines: maxLines,
    )..layout(maxWidth: width);
    final height = painter.height;
    painter.dispose();
    return Size.fromHeight(
      math.max(kToolbarHeight, height + 2 * _verticalPadding),
    );
  }

  /// The title style with the text scale factor baked in, so a [TextPainter]
  /// measures what [HyphenatedText] will render.
  static TextStyle _measureStyle(BuildContext context) {
    final style = styleFor(const Color(0xFF000000));
    return style.copyWith(
      fontSize: MediaQuery.textScalerOf(context).scale(style.fontSize!),
    );
  }

  /// [title] with the hyphens and newlines the rendered widget will have.
  static String _laidOut(
    BuildContext context,
    String title,
    TextStyle style,
    double width,
  ) {
    final locale = Localizations.maybeLocaleOf(context);
    final hyphenator = locale == null ? null : hyphenatorFor(locale);
    if (hyphenator == null) return title;
    return hyphenateForWidth(
      text: title,
      style: style,
      maxWidth: width,
      hyphenator: hyphenator,
      localeCode: locale!.languageCode,
      textDirection: Directionality.of(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: SizedBox(
        width: width,
        child: HyphenatedText(
          title,
          style: styleFor(color),
          textAlign: TextAlign.center,
          // Overrides the AppBar's own softWrap: false / ellipsis.
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          maxLines: maxLines,
        ),
      ),
    );
  }
}
