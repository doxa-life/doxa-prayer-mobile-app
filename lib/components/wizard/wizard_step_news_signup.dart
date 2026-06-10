import 'package:doxa_prayer_mobile_app/layouts/page_scaffold.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/wizard_controller.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';
import '../misc/titles.dart';
import '../widgets/news_signup.dart';

class WizardStepNewsSignup extends StatefulWidget {
  const WizardStepNewsSignup({super.key, required this.controller});

  final WizardController controller;

  @override
  State<WizardStepNewsSignup> createState() => _WizardStepNewsSignupState();
}

class _WizardStepNewsSignupState extends State<WizardStepNewsSignup> {
  NewsSignupData? _current;
  bool _submitting = false;

  Future<void> _submit() async {
    final data = _current;
    if (data == null || _submitting) return;
    setState(() => _submitting = true);
    try {
      await widget.controller.finish(context, newsSignup: data);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _skip() async {
    if (_submitting) return;
    await widget.controller.finish(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final canSubmit = _current != null && !_submitting;
    // Scrolls when the keyboard shrinks the viewport (otherwise the column
    // overflows and the buttons become unreachable), while keeping the
    // buttons pinned to the bottom when there is room.
    return PageContainer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    H1(l.wizardNewsSignupTitle, textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l.wizardNewsSignupBody,
                      style: AppTypography.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    NewsSignup(
                      onChanged: (data) => setState(() => _current = data),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    const Expanded(child: SizedBox.shrink()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ActionButton(
                          label: l.skip,
                          color: ActionButtonColor.white,
                          isOutlined: true,
                          onPressed: _submitting ? null : _skip,
                        ),
                        ActionButton(
                          label: l.finish,
                          color: ActionButtonColor.secondary,
                          onPressed: canSubmit ? _submit : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
