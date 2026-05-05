import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_spacing.dart';
import '../buttons/action_button.dart';
import '../inputs/checkbox_field.dart';
import '../inputs/text_field.dart';

class NewsSignupData {
  const NewsSignupData({
    required this.name,
    required this.email,
    required this.wantsPeopleGroupUpdates,
    required this.wantsDoxaUpdates,
  });

  final String name;
  final String email;
  final bool wantsPeopleGroupUpdates;
  final bool wantsDoxaUpdates;
}

class NewsSignup extends StatefulWidget {
  const NewsSignup({
    super.key,
    required this.onSubmit,
    this.onSkip,
    this.submitLabel,
  });

  final Future<void> Function(NewsSignupData) onSubmit;
  final VoidCallback? onSkip;
  final String? submitLabel;

  @override
  State<NewsSignup> createState() => _NewsSignupState();
}

class _NewsSignupState extends State<NewsSignup> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  bool _wantsPeopleGroupUpdates = true;
  bool _wantsDoxaUpdates = true;
  bool _submitting = false;

  static final RegExp _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      !_submitting &&
      _name.text.trim().isNotEmpty &&
      _emailRe.hasMatch(_email.text.trim());

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);
    try {
      await widget.onSubmit(
        NewsSignupData(
          name: _name.text.trim(),
          email: _email.text.trim(),
          wantsPeopleGroupUpdates: _wantsPeopleGroupUpdates,
          wantsDoxaUpdates: _wantsDoxaUpdates,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final submitLabel = widget.submitLabel ?? l.save;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: l.nameLabel,
          controller: _name,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: l.emailLabel,
          controller: _email,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.lg),
        CheckboxField(
          label: l.updatesAboutMyPeopleGroup,
          value: _wantsPeopleGroupUpdates,
          onChanged: (v) => setState(() => _wantsPeopleGroupUpdates = v),
        ),
        CheckboxField(
          label: l.updatesFromDoxa,
          value: _wantsDoxaUpdates,
          onChanged: (v) => setState(() => _wantsDoxaUpdates = v),
        ),
        const SizedBox(height: AppSpacing.xxl),
        _buildButtonRow(l, submitLabel),
      ],
    );
  }

  Widget _buildButtonRow(AppLocalizations l, String submitLabel) {
    final submitButton = ActionButton(
      label: submitLabel,
      onPressed: _canSubmit ? _submit : null,
      color: ActionButtonColor.secondary,
    );
    if (widget.onSkip != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ActionButton(
            label: l.skip,
            color: ActionButtonColor.white,
            isOutlined: true,
            onPressed: _submitting ? null : widget.onSkip,
          ),
          submitButton,
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [submitButton],
    );
  }
}
