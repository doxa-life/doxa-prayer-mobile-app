import 'package:doxa_prayer_mobile_app/components/inputs/language_switcher.dart';
import 'package:doxa_prayer_mobile_app/components/nav/details_nav_bar.dart';
import 'package:doxa_prayer_mobile_app/components/settings/account_settings_section.dart';
import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:doxa_prayer_mobile_app/layouts/page_scaffold.dart';
import 'package:doxa_prayer_mobile_app/services/reminders_notifications.dart';
import 'package:doxa_prayer_mobile_app/theme/app_colors.dart';
import 'package:doxa_prayer_mobile_app/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
        title: l.settings,
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: PageContainer(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const LanguageSwitcher(),
                    const SizedBox(height: AppSpacing.xl),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l.signUpForUpdates),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _openNewsSignup,
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: notificationsBlocked,
                      builder: (context, blocked, _) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l.notifications),
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
                    AccountSettingsSection(key: _accountKey),
                  ],
                ),
              ),
              const _VersionLabel(),
            ],
          ),
        ),
      ),
    );
  }
}

class _VersionLabel extends StatelessWidget {
  const _VersionLabel();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return PageContainer(
      child: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final version = snapshot.data?.version;
          if (version == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Text(
              l.appVersion(version),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
