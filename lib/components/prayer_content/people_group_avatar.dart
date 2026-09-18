import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../misc/app_image.dart';
import '../misc/hyphenated_text.dart';
import '../misc/prayed_today_pill.dart';

/// One people group in the Pray tab's switcher row: photo, name, and the same
/// prayed-today check the home cards use.
class PeopleGroupAvatar extends StatelessWidget {
  const PeopleGroupAvatar({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.selected,
    required this.prayedToday,
    required this.onTap,
  });

  final String name;
  final String? imageUrl;
  final bool selected;
  final bool prayedToday;
  final VoidCallback onTap;

  static const double _size = 56;

  /// How much horizontal room one avatar takes, including its own padding —
  /// the row uses it to scroll the active avatar into view.
  static const double slotWidth = _size + 12 + AppSpacing.xxs * 2;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      selected: selected,
      label: l10n.switchToPeopleGroup(name),
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // The ring is what says "this is the one you are
                        // praying for"; without it the row reads as decoration.
                        border: Border.all(
                          color: selected
                              ? AppColors.secondary
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                        child: AppImage(
                          url: imageUrl,
                          size: _size,
                          semanticLabel: name,
                        ),
                      ),
                    ),
                    if (prayedToday)
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: PrayedTodayPill(
                          label: l10n.prayedToday,
                          compact: true,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                SizedBox(
                  width: _size + 12,
                  child: HyphenatedText(
                    name,
                    style: AppTypography.caption.copyWith(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
