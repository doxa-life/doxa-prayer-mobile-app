import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../misc/collapsible.dart';
import '../misc/hyphenated_text.dart';

/// One category in the people-groups filter panel. The header shows only the
/// title — the current choice stays out of sight until the user opens it —
/// plus a small mark that pops in while [isActive], so an applied filter is
/// visible at a glance.
///
/// The header works one of three ways:
///  - with a [child], tapping it slides that body open and shut;
///  - with a [trailing] widget (a toggle, say), the control sits in the
///    header itself and the header isn't tappable;
///  - otherwise tapping it calls [onTap], e.g. to open a picker sheet.
class FilterSection extends StatelessWidget {
  const FilterSection({
    super.key,
    required this.title,
    this.isActive = false,
    this.onTap,
    this.expanded = false,
    this.child,
    this.trailing,
    this.semanticValue,
  });

  final String title;
  final bool isActive;
  final VoidCallback? onTap;
  final bool expanded;
  final Widget? child;
  final Widget? trailing;

  /// The current choice, read out by screen readers since it isn't shown.
  final String? semanticValue;

  @override
  Widget build(BuildContext context) {
    final body = child;
    final control = trailing;
    final titleRow = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.xs,
      children: [
        Flexible(
          child: HyphenatedText(
            title,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _ModifiedMark(visible: isActive),
      ],
    );

    if (control != null) {
      return Semantics(
        value: semanticValue,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          // Wraps the control under the title when both don't fit.
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [titleRow, control],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: body != null ? expanded : null,
          value: semanticValue,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Row(
                spacing: AppSpacing.md,
                children: [
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: titleRow,
                    ),
                  ),
                  if (body != null)
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: Collapsible.duration,
                      curve: Curves.easeOutCubic,
                      child: const Icon(Icons.expand_more),
                    )
                  else
                    const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ),
        if (body != null)
          Collapsible(
            expanded: expanded,
            child: Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.xs,
                bottom: AppSpacing.md,
              ),
              child: body,
            ),
          ),
      ],
    );
  }
}

/// The little check beside a filter's title once it's been changed. It pops
/// in and fades out rather than appearing abruptly.
class _ModifiedMark extends StatelessWidget {
  const _ModifiedMark({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : Collapsible.duration;
    return ExcludeSemantics(
      child: AnimatedScale(
        scale: visible ? 1 : 0,
        duration: duration,
        curve: visible ? Curves.easeOutBack : Curves.easeInCubic,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: duration,
          child: Icon(
            Icons.check_circle,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
