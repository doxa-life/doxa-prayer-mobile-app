import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../layouts/page_scaffold.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../nav/sheet_header.dart';
import '../nav/sheet_page.dart';

/// The widest the cards get. On a tablet the page would otherwise run 960
/// wide, with lines too long to read.
const double _kMaxWidth = 720;

/// A people group's profile as one page of cards, stacked top to bottom and
/// scrolled through as a whole. Each card is as tall as its content.
///
/// Shown in a sheet, dragging down from the top of the page pulls the sheet
/// down after it, to dismiss it.
///
/// The loading skeleton is the same page with placeholder cards and
/// [interactive] off, so the profile lands where its placeholder was.
class ProfileStack extends StatelessWidget {
  const ProfileStack({super.key, required this.cards, this.interactive = true});

  final List<Widget> cards;

  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final sheet = interactive ? SheetScope.maybeOf(context) : null;
    final content = SingleChildScrollView(
      physics: interactive
          ? SheetScrollPhysics(sheet: sheet)
          : const NeverScrollableScrollPhysics(),
      // Clear of the home indicator, where there is one.
      padding: EdgeInsets.only(
        bottom: math.max(
          AppSpacing.xl,
          MediaQuery.viewPaddingOf(context).bottom + AppSpacing.lg,
        ),
      ),
      child: PageContainer(
        maxWidth: _kMaxWidth,
        // Close to the screen's edges, so the cards make use of its width.
        horizontalPadding: AppSpacing.sm,
        verticalPadding: AppSpacing.lg,
        bottomPadding: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.lg,
          // Each card is drawn once and kept. Without the boundaries, every
          // frame of a scroll redrew every card — shadows, clipped corners,
          // photo and all the text — just to move them up or down; with them a
          // scroll frame only moves pictures already drawn, and the ones off
          // screen aren't drawn at all.
          children: [for (final card in cards) RepaintBoundary(child: card)],
        ),
      ),
    );
    if (sheet == null) return content;
    return NotificationListener<ScrollEndNotification>(
      onNotification: (n) {
        sheet.end(n.dragDetails?.primaryVelocity ?? 0);
        return false;
      },
      child: content,
    );
  }
}

/// One card of the profile: the app's elevated card, as tall as its content.
///
/// Its [header], when given, sits at the top with a rule under it.
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    this.header,
    required this.child,
    this.padding = AppSpacing.xxxl,
    this.color = AppColors.surface,
    this.ruleColor,
    this.headerSpacing = AppSpacing.lg,
  });

  final Widget? header;
  final Widget child;
  final double padding;
  final Color color;
  final Color? ruleColor;

  /// The space above and below the rule under the [header].
  final double headerSpacing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header != null) ...[
              header!,
              SizedBox(height: headerSpacing),
              ProfileHeadingRule(color: ruleColor),
              SizedBox(height: headerSpacing),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

/// The rule between a card's heading and the rest of it.
class ProfileHeadingRule extends StatelessWidget {
  const ProfileHeadingRule({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: color ?? AppColors.onSurface.withValues(alpha: 0.15),
    );
  }
}
