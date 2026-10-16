import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../services/storage_usage.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';
import '../misc/hyphenated_text.dart';
import '../misc/titles.dart';

/// Settings section showing how much space the app's downloads take — prayer
/// and people-group data, photos, map — and a button to clear them all.
class StorageSettingsSection extends StatefulWidget {
  const StorageSettingsSection({super.key});

  @override
  State<StorageSettingsSection> createState() => _StorageSettingsSectionState();
}

class _StorageSettingsSectionState extends State<StorageSettingsSection> {
  StorageUsage? _usage;
  bool _clearing = false;

  @override
  void initState() {
    super.initState();
    _measure();
  }

  Future<void> _measure() async {
    final usage = await measureStorage();
    if (mounted) setState(() => _usage = usage);
  }

  Future<void> _confirmClear() async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: HyphenatedText(l.clearCacheConfirmTitle),
        content: HyphenatedText(l.clearCacheConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: HyphenatedText(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: HyphenatedText(l.clearCache),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _clearing = true);
    await clearAllCaches();
    await _measure();
    if (!mounted) return;
    setState(() => _clearing = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: HyphenatedText(l.cacheCleared)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final usage = _usage;
    final locale = Localizations.localeOf(context).toLanguageTag();
    String size(int bytes) => usage == null ? '…' : _formatSize(bytes, locale);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.lg),
        H2(l.storageSectionTitle),
        const SizedBox(height: AppSpacing.sm),
        _row(l.storagePrayerData, size(usage?.data ?? 0)),
        _row(l.storagePhotos, size(usage?.photos ?? 0)),
        _row(l.storageMap, size(usage?.mapTiles ?? 0)),
        const Divider(height: AppSpacing.lg),
        _row(l.storageTotal, size(usage?.total ?? 0), bold: true),
        const SizedBox(height: AppSpacing.md),
        HyphenatedText(l.storageExplanation, style: AppTypography.caption),
        const SizedBox(height: AppSpacing.md),
        ActionButton.fullWidth(
          label: l.clearCache,
          color: ActionButtonColor.secondary,
          onPressed: _clearing || usage == null || usage.total == 0
              ? null
              : _confirmClear,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    final style = AppTypography.bodySmall.copyWith(
      fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          Expanded(child: HyphenatedText(label, style: style)),
          const SizedBox(width: AppSpacing.md),
          Text(value, style: style),
        ],
      ),
    );
  }
}

/// A size as "0 KB", "840 KB" or "12.3 MB", with the number in [locale]'s own
/// digits and separators.
String _formatSize(int bytes, String locale) {
  const kb = 1024;
  const mb = 1024 * 1024;
  if (bytes < mb) {
    return '${NumberFormat.decimalPattern(locale).format((bytes / kb).round())} KB';
  }
  return '${NumberFormat('0.0', locale).format(bytes / mb)} MB';
}
