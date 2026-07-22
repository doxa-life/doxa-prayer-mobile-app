import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/crash_reporting_service.dart';
import '../../services/feedback_service.dart';
import '../../services/identity_service.dart';
import '../../services/profile_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../buttons/action_button.dart';
import '../inputs/checkbox_field.dart';
import '../inputs/text_field.dart';
import 'feedback_success.dart';

/// The in-app feedback form. Mirrors the hosted web form's fields (type, name,
/// email, message, marketing consent) and submits via [submitFeedback], which
/// attaches the user's identity and device diagnostics. When the user has a web
/// profile, the email field is pre-filled with their real primary address so
/// they can confirm the feedback is linked to the right account.
class FeedbackForm extends StatefulWidget {
  const FeedbackForm({super.key});

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _message = TextEditingController();

  FeedbackType? _type;
  bool _wantsDoxaUpdates = false;
  bool _submitting = false;
  bool _submitAttempted = false;
  bool _submitted = false;
  String? _submittedEmail;
  String? _errorMessage;

  static final RegExp _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
    _prefillEmail();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _message.dispose();
    super.dispose();
  }

  /// Best-effort pre-fill of the email from the user's profile (plaintext
  /// primary address). Silently leaves the field empty when unavailable or if
  /// the user already started typing.
  Future<void> _prefillEmail() async {
    final profileId = identityController.value?.profileId;
    if (profileId == null) return;
    final email = await fetchPrimaryEmail(profileId);
    if (!mounted || email == null || _email.text.trim().isNotEmpty) return;
    _email.text = email;
  }

  bool get _typeValid => _type != null;
  bool get _emailValid => _emailRe.hasMatch(_email.text.trim());
  bool get _messageValid => _message.text.trim().isNotEmpty;

  Future<void> _submit() async {
    setState(() => _submitAttempted = true);
    if (_submitting) return;
    if (!_typeValid || !_emailValid || !_messageValid) return;

    final email = _email.text.trim();
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      await submitFeedback(
        FeedbackData(
          type: _type!,
          name: _name.text.trim(),
          email: email,
          message: _message.text.trim(),
          wantsDoxaUpdates: _wantsDoxaUpdates,
        ),
      );
      if (mounted) {
        setState(() {
          _submitted = true;
          _submittedEmail = email;
        });
      }
    } on FeedbackRateLimitedException {
      if (mounted) {
        setState(
          () => _errorMessage = AppLocalizations.of(context)!.feedbackRateLimited,
        );
      }
    } catch (e, s) {
      reportError(e, s, reason: 'feedback submit failed');
      if (mounted) {
        setState(
          () => _errorMessage = AppLocalizations.of(context)!.feedbackError,
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (_submitted) {
      return FeedbackSuccess(email: _submittedEmail ?? _email.text.trim());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.feedbackIntro, style: TextStyle(color: AppColors.primaryLight)),
        const SizedBox(height: AppSpacing.xl),
        _TypeSelector(
          label: l.feedbackTypeLabel,
          selected: _type,
          errorText: _submitAttempted && !_typeValid ? l.feedbackTypeRequired : null,
          onSelected: (t) => setState(() => _type = t),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: l.feedbackNameLabel,
          controller: _name,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: l.emailLabel,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          errorText: _submitAttempted && !_emailValid ? l.emailInvalid : null,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: l.feedbackMessageLabel,
          controller: _message,
          minLines: 4,
          maxLines: 8,
          keyboardType: TextInputType.multiline,
          errorText: _submitAttempted && !_messageValid
              ? l.feedbackMessageRequired
              : null,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.lg),
        CheckboxField(
          label: l.feedbackConsentLabel,
          value: _wantsDoxaUpdates,
          onChanged: (v) => setState(() => _wantsDoxaUpdates = v),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(_errorMessage!, style: TextStyle(color: AppColors.scheme.error)),
        ],
        const SizedBox(height: AppSpacing.xxl),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_submitting) ...[
              const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            ActionButton(
              label: l.feedbackSubmit,
              onPressed: _submitting ? null : _submit,
              color: ActionButtonColor.secondary,
            ),
          ],
        ),
      ],
    );
  }
}

/// Three-way feedback-type picker rendered as selectable chips.
class _TypeSelector extends StatelessWidget {
  const _TypeSelector({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.errorText,
  });

  final String label;
  final FeedbackType? selected;
  final ValueChanged<FeedbackType> onSelected;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final items = <(FeedbackType, String, IconData)>[
      (FeedbackType.compliment, l.feedbackTypeCompliment, Icons.favorite_outline),
      (FeedbackType.suggestion, l.feedbackTypeSuggestion, Icons.lightbulb_outline),
      (FeedbackType.problem, l.feedbackTypeProblem, Icons.error_outline),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final (type, itemLabel, icon) in items)
              ChoiceChip(
                showCheckmark: false,
                avatar: Icon(
                  icon,
                  size: 18,
                  color: selected == type ? AppColors.white : AppColors.primary,
                ),
                label: Text(itemLabel),
                selected: selected == type,
                selectedColor: AppColors.secondary,
                labelStyle: TextStyle(
                  color: selected == type ? AppColors.white : AppColors.onSurface,
                ),
                onSelected: (_) => onSelected(type),
              ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorText!,
            style: TextStyle(color: AppColors.scheme.error, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
