import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/reminders_notifications.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';

/// Text + button offering to enable OS notification permission so the user can
/// also receive push notifications. Shown after signing up for updates and on
/// the updates settings screen for already-signed-up users.
///
/// Self-hiding: renders nothing while the permission state is loading or once
/// notifications are already authorised, so it never nags an enabled user. The
/// button asks for permission on tap (which also registers the OneSignal push
/// token — see [ensureNotificationPermission]).
class EnableNotificationsPrompt extends StatefulWidget {
  const EnableNotificationsPrompt({super.key});

  @override
  State<EnableNotificationsPrompt> createState() =>
      _EnableNotificationsPromptState();
}

class _EnableNotificationsPromptState extends State<EnableNotificationsPrompt>
    with WidgetsBindingObserver {
  bool? _authorized; // null while loading
  bool _requesting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The user may have toggled permission in the OS settings while away.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final granted = await notificationsAuthorized();
    if (mounted) setState(() => _authorized = granted);
  }

  Future<void> _onEnable() async {
    if (_requesting) return;
    setState(() => _requesting = true);
    try {
      // Shows the system popup on a first ask, or falls back to opening the OS
      // settings if the user previously denied. When settings are opened the
      // grant lands after this returns — the resume handler re-checks then.
      final granted = await promptEnableNotifications();
      if (mounted) setState(() => _authorized = granted);
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hide while loading and once already authorised.
    if (_authorized == null || _authorized == true) {
      return const SizedBox.shrink();
    }

    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Own the leading gap so callers can drop the widget in unconditionally
        // without leaving an empty space when it self-hides.
        const SizedBox(height: AppSpacing.xxl),
        Text(
          l.enableNotificationsPromptBody,
          style: AppTypography.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        ActionButton.fullWidth(
          label: l.enableNotificationsButton,
          color: ActionButtonColor.secondary,
          onPressed: _requesting ? null : _onEnable,
        ),
      ],
    );
  }
}
