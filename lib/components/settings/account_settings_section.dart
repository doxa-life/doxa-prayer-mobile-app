import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../services/identity_service.dart';
import '../../services/profile_service.dart';
import '../../theme/app_spacing.dart';
import '../misc/titles.dart';
import 'signed_up_email_tile.dart';

/// Settings section for a signed-up user: the email address(es) they signed up
/// with (each with verified/unverified status + resend), plus a link out to
/// their web profile. Renders nothing until the user has a web profile id.
class AccountSettingsSection extends StatefulWidget {
  const AccountSettingsSection({super.key});

  @override
  State<AccountSettingsSection> createState() => _AccountSettingsSectionState();
}

class _AccountSettingsSectionState extends State<AccountSettingsSection> {
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

  /// Refetches emails when the signed-up profile id appears or changes.
  void _syncToIdentity() {
    final profileId = identityController.value?.profileId;
    if (profileId == _profileId) return;
    setState(() {
      _profileId = profileId;
      _emailsFuture =
          profileId == null ? null : fetchProfileEmails(profileId);
    });
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
                child: Text(l.emailsLoadError),
              );
            }
            final emails = snapshot.data ?? const [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final email in emails)
                  SignedUpEmailTile(profileId: profileId, email: email),
              ],
            );
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.viewProfile),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => _openProfile(profileId),
        ),
      ],
    );
  }
}
