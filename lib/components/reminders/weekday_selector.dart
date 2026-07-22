import 'package:flutter/material.dart';

import '../../services/reminders_format.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class WeekdaySelector extends StatelessWidget {
  const WeekdaySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    final order = weekdaysInLocaleOrder(context);
    // A Wrap (rather than a Row) so the seven day circles reflow onto a second
    // line instead of overflowing when the available width is tight (e.g. a
    // narrow screen at large font scales).
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.sm,
      children: [
        for (final wd in order)
          _WeekdayCircle(
            weekday: wd,
            selected: selected.contains(wd),
            onTap: () {
              final next = {...selected};
              if (!next.add(wd)) next.remove(wd);
              onChanged(next);
            },
          ),
      ],
    );
  }
}

class _WeekdayCircle extends StatelessWidget {
  const _WeekdayCircle({
    required this.weekday,
    required this.selected,
    required this.onTap,
  });

  static const double _diameter = 40;

  final int weekday;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = shortWeekdayLabel(context, weekday);
    return Material(
      color: selected ? AppColors.secondary : AppColors.mutedSurface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: _diameter,
          height: _diameter,
          child: Center(
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: selected ? AppColors.onSecondary : AppColors.onSurface,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
