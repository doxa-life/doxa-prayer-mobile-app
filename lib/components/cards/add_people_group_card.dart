import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../misc/hyphenated_text.dart';
import '../misc/plus_icon.dart';
import 'elevated_card.dart';

/// The last card in the home carousel: an invitation to pray for another
/// people group. Hidden once the user is at the limit, so the carousel never
/// offers something that can only be answered with a swap.
class AddPeopleGroupCard extends StatelessWidget {
  const AddPeopleGroupCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ElevatedAppCard(
      onTap: onTap,
      padding: AppSpacing.xl,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: AppSpacing.lg,
          children: [
            const PlusIcon(color: AppColors.primary, size: 40),
            HyphenatedText(
              l10n.addAnotherPeopleGroup,
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
