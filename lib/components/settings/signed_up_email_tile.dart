import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/profile_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// One signed-up email address: its (redacted) value, verified/unverified
/// status, and — while unverified — a "resend verification email" action with a
/// short cooldown that mirrors the server-side guard.
class SignedUpEmailTile extends StatefulWidget {
  const SignedUpEmailTile({
    super.key,
    required this.profileId,
    required this.email,
  });

  final String profileId;
  final SignedUpEmail email;

  @override
  State<SignedUpEmailTile> createState() => _SignedUpEmailTileState();
}

class _SignedUpEmailTileState extends State<SignedUpEmailTile> {
  static const _defaultCooldownSeconds = 60;

  bool _sending = false;
  int _cooldownRemaining = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  /// Counts down [seconds], so the button can show the remaining cooldown.
  void _startCooldown(int seconds) {
    _cooldownTimer?.cancel();
    setState(() => _cooldownRemaining = seconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _cooldownRemaining--;
        if (_cooldownRemaining <= 0) timer.cancel();
      });
    });
  }

  Future<void> _resend() async {
    if (_sending || _cooldownRemaining > 0) return;
    setState(() => _sending = true);
    final result = await resendVerification(widget.profileId, widget.email.id);
    if (!mounted) return;
    setState(() => _sending = false);

    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    switch (result.status) {
      case ResendVerificationStatus.sent:
      case ResendVerificationStatus.alreadyVerified:
        messenger.showSnackBar(
          SnackBar(content: Text(l.resendVerificationSent)),
        );
        _startCooldown(_defaultCooldownSeconds);
      case ResendVerificationStatus.cooldown:
        final seconds = result.retryAfterSeconds ?? _defaultCooldownSeconds;
        messenger.showSnackBar(
          SnackBar(content: Text(l.resendVerificationCooldown(seconds))),
        );
        _startCooldown(seconds);
      case ResendVerificationStatus.failed:
        messenger.showSnackBar(
          SnackBar(content: Text(l.resendVerificationFailed)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final verified = widget.email.verified;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                verified ? Icons.check_circle : Icons.error_outline,
                size: 20,
                color: verified ? AppColors.secondary : AppColors.warning,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.email.value),
                    Text(
                      verified ? l.emailVerified : l.emailUnverified,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: verified
                            ? AppColors.secondary
                            : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!verified)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: (_sending || _cooldownRemaining > 0) ? null : _resend,
                child: _sending
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _cooldownRemaining > 0
                            ? l.resendVerificationCountdown(_cooldownRemaining)
                            : l.resendVerification,
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
