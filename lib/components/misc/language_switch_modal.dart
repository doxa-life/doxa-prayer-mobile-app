import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/locale_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../buttons/action_button.dart';
import 'action_modal.dart';

/// How long the confirmation waits before switching back on its own.
const Duration _revertAfter = Duration(seconds: 15);

/// Switches the app to [next], then asks — already in [next] — whether to keep
/// it.
///
/// Asking after the switch lets the user see the language they picked before
/// committing to it. A user who picked a language they cannot read still has a
/// way out: the undo button names the previous language in its own script, and
/// if nothing is pressed the app switches back once [_revertAfter] runs out,
/// the way a display-resolution change does.
Future<void> switchLanguageWithConfirmation(
  BuildContext context,
  Locale next,
) async {
  final previous = localeController.value;
  if (next.languageCode == previous.languageCode) return;
  await setLocale(next);
  if (!context.mounted) return;
  final keep = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _LanguageSwitchModal(previous: previous),
  );
  if (keep != true) await setLocale(previous);
}

class _LanguageSwitchModal extends StatefulWidget {
  const _LanguageSwitchModal({required this.previous});

  final Locale previous;

  @override
  State<_LanguageSwitchModal> createState() => _LanguageSwitchModalState();
}

class _LanguageSwitchModalState extends State<_LanguageSwitchModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _countdown =
      AnimationController(vsync: this, duration: _revertAfter)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed && mounted) {
            Navigator.of(context).pop(false);
          }
        })
        ..forward();

  @override
  void dispose() {
    _countdown.dispose();
    super.dispose();
  }

  String get _previousName => appLanguages
      .firstWhere(
        (lang) => lang.locale.languageCode == widget.previous.languageCode,
      )
      .nativeName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ActionModal(
      message: l10n.languageSwitchConfirm,
      actionButtons: [
        ActionButton(
          label: l10n.languageSwitchUndo(_previousName),
          onPressed: () => Navigator.of(context).pop(false),
          color: ActionButtonColor.secondaryLight,
          isOutlined: true,
        ),
        ActionButton(
          label: l10n.languageSwitchKeep,
          onPressed: () => Navigator.of(context).pop(true),
          color: ActionButtonColor.white,
        ),
      ],
      // Time left before the switch is undone automatically.
      footer: AnimatedBuilder(
        animation: _countdown,
        builder: (context, _) => ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          child: LinearProgressIndicator(
            value: 1 - _countdown.value,
            minHeight: 3,
            color: AppColors.onSecondary,
            backgroundColor: AppColors.onSecondary.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }
}
