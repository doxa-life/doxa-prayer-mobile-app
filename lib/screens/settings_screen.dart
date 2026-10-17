import 'package:doxa_prayer_mobile_app/components/inputs/language_switcher.dart';
import 'package:doxa_prayer_mobile_app/components/nav/details_nav_bar.dart';
import 'package:doxa_prayer_mobile_app/components/nav/root_pop_scope.dart';
import 'package:doxa_prayer_mobile_app/components/settings/account_settings_section.dart';
import 'package:doxa_prayer_mobile_app/components/settings/storage_settings_section.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:doxa_prayer_mobile_app/layouts/page_scaffold.dart';
import 'package:doxa_prayer_mobile_app/services/reminders_notifications.dart';
import 'package:doxa_prayer_mobile_app/theme/app_colors.dart';
import 'package:doxa_prayer_mobile_app/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../components/misc/hyphenated_text.dart';
import '../theme/app_typography.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<AccountSettingsSectionState> _accountKey =
      GlobalKey<AccountSettingsSectionState>();

  Future<void> _openNewsSignup() async {
    await context.push('/settings/news-signup');
    // Coming back from the signup form: refresh so a newly added email shows.
    _accountKey.currentState?.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: DetailsNavBar(
        context: context,
        title: l.settings,
        onBack: () => safeBack(context),
      ),
      body: SafeArea(
        // A SingleChildScrollView rather than a ListView: the list is short,
        // and a ListView disposes rows that scroll out of view and builds them
        // again on the way back — so every scroll past the storage section
        // walked the whole cache on disk to measure it again, and every pass
        // over the account section refetched its emails from the server.
        child: SingleChildScrollView(
          child: PageContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const LanguageSwitcher(),
                const SizedBox(height: AppSpacing.xl),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: HyphenatedText(l.signUpForUpdates),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _openNewsSignup,
                ),
                // Reminders moved here from the tab bar. Flagged the way
                // its tab used to be when reminders can't fire as set.
                ListenableBuilder(
                  listenable: Listenable.merge([
                    notificationsBlocked,
                    exactAlarmsBlocked,
                  ]),
                  builder: (context, _) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: HyphenatedText(l.reminders),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (notificationsBlocked.value ||
                            exactAlarmsBlocked.value) ...[
                          const Icon(
                            Icons.error,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                        ],
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () => context.push('/reminders'),
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: notificationsBlocked,
                  builder: (context, blocked, _) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: HyphenatedText(l.notifications),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (blocked) ...[
                          const Icon(
                            Icons.error,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                        ],
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () => context.push('/settings/notifications'),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: HyphenatedText(l.feedback),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/feedback'),
                ),
                AccountSettingsSection(key: _accountKey),
                const StorageSettingsSection(),
                const _VersionLabel(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The app's version and build number, as the last line of the settings —
/// "Version 2.2.3 (37)" — so a tester can say exactly which build they have.
class _VersionLabel extends StatefulWidget {
  const _VersionLabel();

  @override
  State<_VersionLabel> createState() => _VersionLabelState();
}

class _VersionLabelState extends State<_VersionLabel> {
  final Future<PackageInfo> _info = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return FutureBuilder<PackageInfo>(
      future: _info,
      builder: (context, snapshot) {
        final info = snapshot.data;
        if (info == null) return const SizedBox.shrink();
        final build = info.buildNumber;
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md),
          child: Text(
            l.appVersion(
              build.isEmpty ? info.version : '${info.version} ($build)',
            ),
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.5),
            ),
          ),
        );
      },
    );
  }
}
