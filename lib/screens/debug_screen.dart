import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import '../components/buttons/action_button.dart';
import '../components/inputs/text_field.dart';
import '../components/misc/hyphenated_text.dart';
import '../components/misc/titles.dart';
import '../components/nav/details_nav_bar.dart';
import '../components/nav/root_pop_scope.dart';
import '../layouts/page_scaffold.dart';
import '../layouts/section.dart';
import '../services/cache_policy.dart';
import '../services/crash_reporting_service.dart';
import '../services/identity_service.dart';
import '../services/image_cache_manager.dart';
import '../services/install_referrer_service.dart';
import '../services/locale_controller.dart';
import '../services/referral_controller.dart';
import '../services/prayer_history_service.dart';
import '../services/response_cache.dart';
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
      'https://play.google.com/store/apps/details?id=life.doxa.pray',
);

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DetailsNavBar(
        context: context,
        title: 'Debug',
        onBack: () => safeBack(context),
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
                  HyphenatedText(
                    'Clear individual saved preferences to test cold-start flows.',
                    style: AppTypography.bodyMedium,
                  ),
                  _prefsSection(context),
                  _cacheSection(context),
                  const _SimulateReferralCard(),
                  _updateSection(context),
                  _crashlyticsSection(context),
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
        _clearRow(
          context,
          label: 'Referred people group',
          description:
              'Forgets the slug deferred from a "Pray on the app" link / install '
              'referrer, so the wizard stops auto-selecting it.',
          onClear: clearReferredPeopleGroup,
        ),
        _clearRow(
          context,
          label: 'Install-referrer checked flag',
          description:
              'Re-arms the once-per-install Play install-referrer read so the next '
              'launch checks it again — re-test the deferred deep link without a '
              'full reinstall.',
          onClear: clearInstallReferrerChecked,
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
                clearReferredPeopleGroup(),
                clearInstallReferrerChecked(),
              ]);
            },
          ),
        ),
      ],
    ),
  );

  Widget _cacheSection(BuildContext context) => Section(
    title: 'Caches',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md,
      children: [
        HyphenatedText(
          'Fetched data is held on disk: prayer content and photos for '
          '${CachePolicy.prayerContent.inDays} days, the people-group list and '
          'detail pages for ${CachePolicy.peopleGroupList.inDays} — those two '
          'also refresh in the background once the cached copy is over '
          '${CachePolicy.peopleGroupCounts.inHours}h old, to keep the praying '
          'counts current. Clear a cache to force the next screen to refetch.',
          style: AppTypography.caption,
        ),
        _clearRow(
          context,
          label: 'API responses',
          description:
              'Prayer content, the UUPG list, and people-group details.',
          onClear: ResponseCache.clear,
        ),
        _clearRow(
          context,
          label: 'Cached images',
          description: 'People-group photos held on disk.',
          onClear: AppImageCacheManager.clear,
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
        HyphenatedText(
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
              const SnackBar(
                content: HyphenatedText('Triggered optional update banner'),
              ),
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
              const SnackBar(content: HyphenatedText('Cleared update prompt')),
            );
          },
        ),
      ],
    ),
  );

  Widget _crashlyticsSection(BuildContext context) => Section(
    title: 'Crashlytics',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md,
      children: [
        HyphenatedText(
          'Verify crash reporting. Collection is disabled in debug builds, so '
          'reports only reach the Firebase console from a profile/release build '
          '(e.g. flutter run --profile --flavor staging). A fatal crash uploads '
          'on the next launch.',
          style: AppTypography.caption,
        ),
        ActionButton.fullWidth(
          label: 'Log test non-fatal',
          onPressed: () {
            reportError(
              Exception('Test non-fatal from debug screen'),
              StackTrace.current,
              reason: 'debug screen test non-fatal',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: HyphenatedText('Recorded test non-fatal'),
              ),
            );
          },
        ),
        ActionButton.fullWidth(
          label: 'Force test crash',
          onPressed: () => FirebaseCrashlytics.instance.crash(),
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
              HyphenatedText(label, style: AppTypography.titleMedium),
              if (description != null)
                HyphenatedText(description, style: AppTypography.caption),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        ActionButton(
          label: 'Clear',
          onPressed: () => _runClear(context, label: label, action: onClear),
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
    messenger.showSnackBar(
      SnackBar(content: HyphenatedText('Cleared: $label')),
    );
  }
}

/// Stashes a referred people-group slug exactly as the Play install referrer
/// would, so the deferred-deep-link wizard branch (auto-select on the confirm
/// step) can be exercised on a sideloaded debug build — which never receives a
/// real Play referrer. Pair with clearing "Wizard completion" to re-run onboarding.
class _SimulateReferralCard extends StatefulWidget {
  const _SimulateReferralCard();

  @override
  State<_SimulateReferralCard> createState() => _SimulateReferralCardState();
}

class _SimulateReferralCardState extends State<_SimulateReferralCard> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final slug = _controller.text.trim();
    if (slug.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    await setReferredPeopleGroup(slug);
    messenger.showSnackBar(
      SnackBar(content: HyphenatedText('Referred people group set to "$slug"')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Section(
      title: 'Simulate deferred referral',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md,
        children: [
          ValueListenableBuilder<String?>(
            valueListenable: referredPeopleGroupController,
            builder: (_, referredSlug, _) {
              return ValueListenableBuilder<SelectedPeopleGroup?>(
                valueListenable: selectedPeopleGroupController,
                builder: (_, selected, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HyphenatedText(
                        'Referred (deferred) slug: ${referredSlug ?? '(none)'}',
                        style: AppTypography.titleMedium,
                      ),
                      HyphenatedText(
                        'Selected people group: ${selected?.slug ?? '(none)'}',
                        style: AppTypography.titleMedium,
                      ),
                    ],
                  );
                },
              );
            },
          ),
          HyphenatedText(
            'Stash a people-group slug as if it arrived via a "Pray on the app" '
            'install referrer. Clear "Wizard completion" too, then relaunch: the '
            'wizard should auto-select this group on the confirm step.',
            style: AppTypography.caption,
          ),
          AppTextField(
            label: 'People group slug',
            hint: 'e.g. somali-bantu',
            controller: _controller,
          ),
          ActionButton.fullWidth(
            label: 'Set referred people group',
            onPressed: _apply,
          ),
        ],
      ),
    );
  }
}
