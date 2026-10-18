import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../services/identity_service.dart';
import '../../services/profile_service.dart';
import '../../theme/app_spacing.dart';
import '../misc/hyphenated_text.dart';
import '../misc/titles.dart';
import 'signed_up_email_tile.dart';

/// Settings section for a signed-up user: the email address(es) they signed up
/// with (each with verified/unverified status + resend), plus a link out to
/// their web profile. Renders nothing until the user has a web profile id.
class AccountSettingsSection extends StatefulWidget {
  const AccountSettingsSection({super.key});

  @override
  State<AccountSettingsSection> createState() => AccountSettingsSectionState();
}

class AccountSettingsSectionState extends State<AccountSettingsSection> {
  /// The last email list fetched, per profile id, for this session. Settings
  /// shows it straight away and refreshes behind it, instead of a spinner —
  /// and the section jumping in height — every time it opens.
  static final Map<String, List<SignedUpEmail>> _lastEmails = {};

  Future<List<SignedUpEmail>> _fetch(String profileId) =>
      fetchProfileEmails(profileId).then((emails) {
        _lastEmails[profileId] = emails;
        return emails;
      });

  String? _profileId;
  Future<List<SignedUpEmail>>? _emailsFuture;

  @override
  void initState() {
    super.initState();
    _syncToIdentity();
    identityController.addListener(_syncToIdentity);
  }

  @override
  void dispose() {
    identityController.removeListener(_syncToIdentity);
    super.dispose();
  }

  /// Re-reads the profile id from identity and (re)fetches the email list. Runs
  /// on every identity change — including a fresh signup that keeps the same
  /// profile id but adds a new email — so the list always reflects the latest.
  void _syncToIdentity() {
    final profileId = identityController.value?.profileId;
    setState(() {
      _profileId = profileId;
      _emailsFuture = profileId == null ? null : _fetch(profileId);
    });
  }

  /// Re-fetches the email list. Called when returning to the settings screen so
  /// a just-added email shows without needing an identity change to fire.
  void refresh() {
    final profileId = _profileId;
    if (profileId == null) return;
    setState(() => _emailsFuture = _fetch(profileId));
  }

  Future<void> _openProfile(String profileId) async {
    await launchUrl(
      profileWebUri(profileId),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileId = _profileId;
    if (profileId == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.lg),
        H2(l.accountSectionTitle),
        const SizedBox(height: AppSpacing.sm),
        FutureBuilder<List<SignedUpEmail>>(
          future: _emailsFuture,
          builder: (context, snapshot) {
            // What was fetched last, while the refresh runs or if it fails.
            final emails = snapshot.data ?? _lastEmails[profileId];
            if (emails != null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final email in emails)
                    SignedUpEmailTile(
                      key: ValueKey(email.id),
                      profileId: profileId,
                      email: email,
                    ),
                ],
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: HyphenatedText(l.emailsLoadError),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: HyphenatedText(l.viewProfile),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => _openProfile(profileId),
        ),
      ],
    );
  }
}
