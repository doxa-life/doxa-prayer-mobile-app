import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/reminders_notifications.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';

/// Warning shown on the reminders screen when notifications are allowed but the
/// app can't schedule *exact* alarms (Android 12+ without SCHEDULE_EXACT_ALARM).
/// Reminders still fire in this state, just up to several minutes late, so this
/// explains the consequence and offers a button that opens the system
/// "Alarms & reminders" screen to grant precise timing.
///
/// Self-hiding: renders nothing while exact alarms are permitted (including on
/// iOS and Android < 12, where the permission doesn't apply), so callers can
/// drop it in unconditionally.
class ExactAlarmWarningBanner extends StatelessWidget {
  const ExactAlarmWarningBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: exactAlarmsBlocked,
      builder: (context, blocked, _) =>
          blocked ? const _Banner() : const SizedBox.shrink(),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.alarm_off, color: AppColors.warning),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l.exactAlarmsDisabledStatus,
                    style: AppTypography.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ActionButton.fullWidth(
              label: l.allowExactAlarms,
              color: ActionButtonColor.secondary,
              onPressed: promptEnableExactAlarms,
            ),
          ],
        ),
      ),
    );
  }
}
