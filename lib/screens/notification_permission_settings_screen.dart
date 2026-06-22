import 'package:flutter/material.dart';

import '../components/buttons/action_button.dart';
import '../components/misc/titles.dart';
import '../components/nav/details_nav_bar.dart';
import '../l10n/app_localizations.dart';
import '../layouts/page_scaffold.dart';
import '../services/reminders_notifications.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Settings subpage that reports whether OS notification permission is granted
/// and, when it isn't, explains why reminders won't fire and offers a shortcut
/// to the system settings to turn them on.
class NotificationPermissionSettingsScreen extends StatefulWidget {
  const NotificationPermissionSettingsScreen({super.key});

  @override
  State<NotificationPermissionSettingsScreen> createState() =>
      _NotificationPermissionSettingsScreenState();
}

class _NotificationPermissionSettingsScreenState
    extends State<NotificationPermissionSettingsScreen>
    with WidgetsBindingObserver {
  bool? _granted; // null while loading

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
    // Re-check when returning from the OS settings screen, where the user may
    // have just toggled the permission.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final granted = await notificationsAuthorized();
    if (mounted) setState(() => _granted = granted);
  }

  Future<void> _onEnable() async {
    final granted = await promptEnableNotifications();
    if (granted && mounted) setState(() => _granted = true);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: DetailsNavBar(
        title: l.notifications,
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: PageContainer(
          child: SingleChildScrollView(
            child: _granted == null
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(AppSpacing.xxl),
                        child: CircularProgressIndicator(),
                      ),
                    ],
                  )
                : (_granted! ? _buildGranted(l) : _buildDenied(l)),
          ),
        ),
      ),
    );
  }

  Widget _buildGranted(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: AppColors.secondary,
              size: 28,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: H2(l.notifications_enabled)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(l.notificationsEnabledStatus, style: AppTypography.bodyMedium),
      ],
    );
  }

  Widget _buildDenied(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.notifications_off,
              color: AppColors.warning,
              size: 28,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: H2(l.notifications_disabled)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(l.notificationsDisabledStatus, style: AppTypography.bodyMedium),
        const SizedBox(height: AppSpacing.md),
        Text(l.notificationsHowToEnable, style: AppTypography.bodySmall),
        const SizedBox(height: AppSpacing.xxl),
        ActionButton.fullWidth(
          label: l.openSettings,
          color: ActionButtonColor.secondary,
          onPressed: _onEnable,
        ),
      ],
    );
  }
}
