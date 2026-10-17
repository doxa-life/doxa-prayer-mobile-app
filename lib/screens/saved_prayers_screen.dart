import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../components/misc/app_icon.dart';
import '../components/misc/app_image.dart';
import '../components/misc/hyphenated_text.dart';
import '../components/nav/details_nav_bar.dart';
import '../components/nav/root_pop_scope.dart';
import '../l10n/app_localizations.dart';
import '../layouts/page_scaffold.dart';
import '../services/saved_prayers_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Every prayer the user has starred or downloaded, newest day first. Tapping
/// one reopens that day's prayer; the star and download marks can be toggled
/// from the row, and a prayer leaves the list once neither is set.
class SavedPrayersScreen extends StatelessWidget {
  const SavedPrayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: DetailsNavBar(
        context: context,
        title: l.savedPrayers,
        onBack: () => safeBack(context),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<Map<String, SavedPrayer>>(
          valueListenable: savedPrayersController,
          builder: (context, saved, _) {
            if (saved.isEmpty) {
              return PageContainer(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: AppSpacing.lg,
                    children: [
                      const Icon(
                        Icons.star_border_rounded,
                        size: 48,
                        color: AppColors.primaryLight,
                      ),
                      HyphenatedText(
                        l.savedPrayersEmpty,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );
            }
            final list = saved.values.toList()
              ..sort((a, b) {
                final byDay = b.date.compareTo(a.date);
                return byDay != 0 ? byDay : a.groupName.compareTo(b.groupName);
              });
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              itemCount: list.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) => _SavedPrayerTile(prayer: list[i]),
            );
          },
        ),
      ),
    );
  }
}

class _SavedPrayerTile extends StatelessWidget {
  const _SavedPrayerTile({required this.prayer});

  final SavedPrayer prayer;

  Future<void> _toggle(
    BuildContext context, {
    bool? starred,
    bool? downloaded,
  }) async {
    try {
      await updateSavedPrayer(
        slug: prayer.slug,
        date: prayer.day,
        language: prayer.language,
        groupName: prayer.groupName,
        imageUrl: prayer.imageUrl,
        starred: starred,
        downloaded: downloaded,
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.prayerSaveFailed),
          ),
        );
    }
  }

  void _open(BuildContext context) {
    context.push(
      '/people-groups/${prayer.slug}/pray',
      extra: {'name': prayer.groupName, 'date': prayer.day},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final material = MaterialLocalizations.of(context);
    return PageContainer(
      verticalPadding: 0,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: () => _open(context),
        leading: ClipOval(
          child: AppImage(url: prayer.imageUrl, size: 44, radius: 0),
        ),
        title: Text(
          prayer.groupName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          material.formatFullDate(prayer.day),
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.primaryLight,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: prayer.starred ? l.prayerStarred : l.starPrayer,
              isSelected: prayer.starred,
              onPressed: () => _toggle(context, starred: !prayer.starred),
              icon: Icon(
                prayer.starred ? Icons.star_rounded : Icons.star_border_rounded,
                color: prayer.starred
                    ? AppColors.warning
                    : AppColors.primaryLight,
              ),
            ),
            IconButton(
              tooltip: prayer.downloaded
                  ? l.prayerDownloaded
                  : l.downloadPrayer,
              isSelected: prayer.downloaded,
              onPressed: () => _toggle(context, downloaded: !prayer.downloaded),
              icon: AppIcon(
                AppIconName.download,
                size: 22,
                color: prayer.downloaded
                    ? AppColors.secondary
                    : AppColors.primaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
