import 'package:flutter/material.dart';

import '../components/buttons/action_button.dart';
import '../components/misc/titles.dart';
import '../components/nav/details_nav_bar.dart';
import '../layouts/page_scaffold.dart';
import '../layouts/section.dart';
import '../services/identity_service.dart';
import '../services/locale_controller.dart';
import '../services/prayer_history_service.dart';
import '../services/reminders_controller.dart';
import '../services/selected_people_group_controller.dart';
import '../services/update_controller.dart';
import '../services/version_check_service.dart';
import '../services/wizard_completion_controller.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// A canned /api/app/version response used by the debug buttons to preview the
/// update UI without hitting the backend or installing a newer build.
const _fakeUpdateInfo = AppVersionInfo(
  latestVersion: '9.9.9',
  minSupportedVersion: '9.9.9',
  iosAppStoreUrl: 'https://apps.apple.com/app/id000000000',
  androidPlayUrl:
      'https://play.google.com/store/apps/details?id=app.prayer.doxa',
);

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DetailsNavBar(
        title: 'Debug',
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            PageContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.xl,
                children: [
                  const H1('Debug'),
                  Text(
                    'Clear individual saved preferences to test cold-start flows.',
                    style: AppTypography.bodyMedium,
                  ),
                  _prefsSection(context),
                  _updateSection(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _prefsSection(BuildContext context) => Section(
    title: 'SharedPreferences',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md,
      children: [
        _clearRow(
          context,
          label: 'Saved language',
          description: 'Falls back to system locale on next launch.',
          onClear: clearLocale,
        ),
        _clearRow(
          context,
          label: 'Wizard completion',
          description: 'Re-runs the wizard on next launch.',
          onClear: clearWizardCompleted,
        ),
        _clearRow(
          context,
          label: 'Selected people group',
          onClear: clearSelectedPeopleGroup,
        ),
        _clearRow(
          context,
          label: 'Reminders',
          description: 'Also cancels all scheduled notifications.',
          onClear: clearReminders,
        ),
        _clearRow(
          context,
          label: 'Prayer history',
          onClear: clearPrayerHistory,
        ),
        _clearRow(
          context,
          label: 'Signup identity',
          description:
              'Forgets tracking_id, profile_id, and subscription_id. '
              'Next people-group selection will trigger a fresh anon-signup.',
          onClear: clearIdentity,
        ),
        const SizedBox(height: AppSpacing.md),
        ActionButton.fullWidth(
          label: 'Clear all',
          onPressed: () => _runClear(
            context,
            label: 'All preferences',
            action: () async {
              await Future.wait([
                clearLocale(),
                clearWizardCompleted(),
                clearSelectedPeopleGroup(),
                clearReminders(),
                clearPrayerHistory(),
                clearIdentity(),
              ]);
            },
          ),
        ),
      ],
    ),
  );

  Widget _updateSection(BuildContext context) => Section(
    title: 'App update prompts',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md,
      children: [
        Text(
          'Simulate a /api/app/version response to preview the update UI. '
          'The blocking modal can only be cleared by relaunching the app or '
          'tapping the store button.',
          style: AppTypography.caption,
        ),
        ActionButton.fullWidth(
          label: 'Show optional banner',
          onPressed: () {
            updateController.value = const UpdateStatus(
              UpdateState.optional,
              _fakeUpdateInfo,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Triggered optional update banner')),
            );
          },
        ),
        ActionButton.fullWidth(
          label: 'Show blocking modal',
          onPressed: () {
            updateController.value = const UpdateStatus(
              UpdateState.forced,
              _fakeUpdateInfo,
            );
          },
        ),
        ActionButton.fullWidth(
          label: 'Clear update prompt',
          onPressed: () {
            updateController.value = UpdateStatus.none;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cleared update prompt')),
            );
          },
        ),
      ],
    ),
  );

  Widget _clearRow(
    BuildContext context, {
    required String label,
    String? description,
    required Future<void> Function() onClear,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.titleMedium),
              if (description != null)
                Text(description, style: AppTypography.caption),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        ActionButton(
          label: 'Clear',
          onPressed: () =>
              _runClear(context, label: label, action: onClear),
        ),
      ],
    );
  }

  Future<void> _runClear(
    BuildContext context, {
    required String label,
    required Future<void> Function() action,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    await action();
    messenger.showSnackBar(SnackBar(content: Text('Cleared: $label')));
  }
}
