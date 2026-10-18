import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/prayer_stats_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// "X praying for the unengaged now" — a global count of prayer sessions in
/// progress, across this app and the web prayer pages.
///
/// Reads [prayingNowController] rather than fetching for itself. The Pray tab
/// lives in an `IndexedStack`, so this widget is never disposed and an
/// `initState` fetch would run exactly once per app launch — leaving a number
/// that never moved. `_startSession` refreshes the controller instead, which
/// fires on first open, on app resume, and whenever the Pray tab becomes
/// current.
///
/// Self-hiding. Renders nothing before the first successful fetch or when the
/// count is zero — an absent line reads better than "0 praying for the unengaged
/// now" — so it can be dropped into the layout unconditionally.
class PrayingNowBanner extends StatelessWidget {
  const PrayingNowBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder<int?>(
      valueListenable: prayingNowController,
      builder: (context, count, _) {
        final shown = count != null && count >= 1;
        // Eases in and out, and between counts, rather than appearing out of
        // nowhere and pushing the prayer down a line when the count arrives.
        return AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: !shown
                ? const SizedBox(key: ValueKey('none'), width: double.infinity)
                : Row(
                    key: ValueKey(count),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: AppTypography.sm,
                        color: AppColors.primaryLight,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Flexible(
                        child: Text(
                          l10n.prayingWithYou(count),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
