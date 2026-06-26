import 'package:doxa_prayer_mobile_app/layouts/page_scaffold.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/wizard_controller.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';
import '../buttons/wizard_button_bar.dart';
import '../misc/titles.dart';
import '../widgets/news_signup.dart';

class WizardStepNewsSignup extends StatefulWidget {
  const WizardStepNewsSignup({super.key, required this.controller});

  final WizardController controller;

  @override
  State<WizardStepNewsSignup> createState() => _WizardStepNewsSignupState();
}

class _WizardStepNewsSignupState extends State<WizardStepNewsSignup> {
  final GlobalKey<NewsSignupState> _signupKey = GlobalKey<NewsSignupState>();
  bool _submitting = false;

  Future<void> _submit() async {
    if (_submitting) return;
    final data = _signupKey.currentState?.validateAndCollect();
    if (data == null) return; // warnings now shown inline by NewsSignup
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
    // The keyboard overlays this step (resizeToAvoidBottomInset is off on the
    // wizard Scaffold) rather than shrinking it. We add scroll padding equal to
    // the keyboard height so the buttons can be scrolled up above the keyboard
    // without dismissing it, while staying pinned to the bottom when there is
    // room.
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    return PageContainer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: keyboardInset),
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
                    NewsSignup(key: _signupKey),
                    const SizedBox(height: AppSpacing.xxl),
                    const Expanded(child: SizedBox.shrink()),
                    WizardButtonBar(
                      maxWidth: constraints.maxWidth,
                      leading: ActionButton(
                        label: l.skip,
                        color: ActionButtonColor.white,
                        isOutlined: true,
                        onPressed: _submitting ? null : _skip,
                      ),
                      trailing: ActionButton(
                        label: l.finish,
                        color: ActionButtonColor.secondary,
                        onPressed: _submitting ? null : _submit,
                      ),
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
