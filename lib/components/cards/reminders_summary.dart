import 'package:flutter/material.dart';

import '../../services/reminders_controller.dart';
import '../../services/reminders_format.dart';
import '../../theme/app_spacing.dart';
import 'reminder_card.dart';

class RemindersSummary extends StatelessWidget {
  const RemindersSummary({super.key, required this.reminders});

  final Reminders reminders;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final r in reminders.list)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: ReminderCard(
              time: formatReminderTime(context, r),
              daysSummary: formatReminderDays(context, r),
              enabled: r.enabled,
              onToggle: (v) => setReminderEnabled(r.id, v),
            ),
          ),
      ],
    );
  }
}
