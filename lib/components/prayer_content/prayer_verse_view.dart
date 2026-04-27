import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// A styled bible-verse block: a left accent bar, the verse text (with
/// superscript verse numbers preserved by the caller), and a small
/// reference + translation line below.
class PrayerVerseView extends StatelessWidget {
  const PrayerVerseView({
    super.key,
    required this.reference,
    required this.translation,
    required this.paragraphs,
  });

  final String reference;
  final String translation;
  final List<List<InlineSpan>> paragraphs;

  @override
  Widget build(BuildContext context) {
    final citation = [
      reference,
      if (translation.isNotEmpty) translation,
    ].where((s) => s.isNotEmpty).join(' · ');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.sm,
        children: [
          for (final spans in paragraphs)
            Text.rich(
              TextSpan(
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontStyle: FontStyle.italic,
                ),
                children: spans,
              ),
            ),
          if (citation.isNotEmpty)
            Text(
              citation,
              style: AppTypography.caption.copyWith(
                color: AppColors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
