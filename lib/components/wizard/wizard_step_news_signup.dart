import 'package:doxa_prayer_mobile_app/layouts/page_scaffold.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/wizard_controller.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';
import '../buttons/button_bar_wrap.dart';
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
  bool _signedUp = false;

  /// First stage: run the signup (people group + email). On success NewsSignup
  /// shows its in-place "check your email" confirmation and the button becomes
  /// Finish; on failure the error is shown inline and the button stays "Sign up".
  Future<void> _signup() async {
    if (_submitting) return;
    final state = _signupKey.currentState;
    if (state == null) return;
    setState(() => _submitting = true);
    final ok = await state.runSubmit(
      (data) => widget.controller.signUp(newsSignup: data),
    );
    if (!mounted) return;
    setState(() {
      _submitting = false;
      if (ok) _signedUp = true;
    });
  }

  /// Second stage: onboarding is done, route home.
  Future<void> _finish() async {
    if (_submitting) return;
    await widget.controller.complete(context);
  }

  Future<void> _skip() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    await widget.controller.skip(context);
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
                    // Once signed up, NewsSignup shows its own thank-you/verify
                    // message, so the step's heading and blurb are hidden.
                    if (!_signedUp) ...[
                      H1(l.wizardNewsSignupTitle, textAlign: TextAlign.center),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        l.wizardNewsSignupBody,
                        style: AppTypography.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    NewsSignup(key: _signupKey),
                    const SizedBox(height: AppSpacing.xxl),
                    const Expanded(child: SizedBox.shrink()),
                    if (_signedUp)
                      ActionButton.fullWidth(
                        label: l.finish,
                        color: ActionButtonColor.secondary,
                        onPressed: _submitting ? null : _finish,
                      )
                    else
                      ButtonBarWrap(
                        maxWidth: constraints.maxWidth,
                        leading: ActionButton(
                          label: l.skip,
                          color: ActionButtonColor.white,
                          isOutlined: true,
                          onPressed: _submitting ? null : _skip,
                        ),
                        trailing: ActionButton(
                          label: l.signUp,
                          color: ActionButtonColor.secondary,
                          onPressed: _submitting ? null : _signup,
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
