import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/prayer_stats_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// "X people praying with you" — a global count of prayer sessions in progress
/// right now, across this app and the web prayer pages.
///
/// Fetched once when the Pray screen opens, never polled: the server caches the
/// figure for about five minutes, so re-asking would return the same snapshot.
///
/// Self-hiding. Renders nothing while loading, on any fetch failure, or when the
/// count is zero — an absent line reads better than "0 people praying with you"
/// — so it can be dropped into the layout unconditionally.
class PrayingNowBanner extends StatefulWidget {
  const PrayingNowBanner({super.key});

  @override
  State<PrayingNowBanner> createState() => _PrayingNowBannerState();
}

class _PrayingNowBannerState extends State<PrayingNowBanner> {
  int? _count;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final count = await fetchPrayingNow();
    // The screen can be popped while the request is in flight.
    if (!mounted) return;
    setState(() => _count = count);
  }

  @override
  Widget build(BuildContext context) {
    final count = _count;
    if (count == null || count < 1) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: 0.0),
      child: Row(
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
    );
  }
}
