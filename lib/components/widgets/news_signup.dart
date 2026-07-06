import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/crash_reporting_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../buttons/action_button.dart';
import '../inputs/checkbox_field.dart';
import '../inputs/text_field.dart';
import 'news_signup_success.dart';

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
    this.onSubmit,
    this.onChanged,
    this.submitLabel,
  });

  final Future<void> Function(NewsSignupData)? onSubmit;
  final ValueChanged<NewsSignupData?>? onChanged;
  final String? submitLabel;

  @override
  State<NewsSignup> createState() => NewsSignupState();
}

class NewsSignupState extends State<NewsSignup> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  bool _wantsPeopleGroupUpdates = true;
  bool _wantsDoxaUpdates = true;
  bool _submitting = false;
  bool _submitAttempted = false;
  bool _submitted = false;
  String? _errorMessage;

  static final RegExp _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
    if (widget.onChanged != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onChanged!(_currentValid());
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  bool get _nameValid => _name.text.trim().isNotEmpty;
  bool get _emailValid => _emailRe.hasMatch(_email.text.trim());
  bool get _isValid => _nameValid && _emailValid;

  /// Forces validation warnings to show and returns the collected data, or null
  /// if the form is invalid. Called by the wizard step's Finish button so the
  /// button can stay enabled and surface warnings on tap.
  NewsSignupData? validateAndCollect() {
    setState(() => _submitAttempted = true);
    return _currentValid();
  }

  NewsSignupData? _currentValid() {
    if (!_isValid) return null;
    return NewsSignupData(
      name: _name.text.trim(),
      email: _email.text.trim(),
      wantsPeopleGroupUpdates: _wantsPeopleGroupUpdates,
      wantsDoxaUpdates: _wantsDoxaUpdates,
    );
  }

  void _emitChanged() => widget.onChanged?.call(_currentValid());

  Future<void> _submit() async {
    final onSubmit = widget.onSubmit;
    if (onSubmit == null) return;
    await runSubmit(onSubmit);
  }

  /// Validates the form, runs [onSubmit], and on success flips to the in-place
  /// confirmation; on failure surfaces the inline error. Returns whether the
  /// submission succeeded. Used both by the built-in submit button (settings)
  /// and externally by the wizard step, which supplies its own callback and
  /// reacts to the result (swapping its "Sign up" button for "Finish").
  Future<bool> runSubmit(Future<void> Function(NewsSignupData) onSubmit) async {
    setState(() => _submitAttempted = true);
    if (_submitting) return false;
    final data = _currentValid();
    if (data == null) return false;
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      await onSubmit(data);
      if (mounted) setState(() => _submitted = true);
      return true;
    } catch (e, s) {
      reportError(e, s, reason: 'news-signup submit failed');
      if (mounted) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.newsSignupError;
        });
      }
      return false;
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (_submitted) {
      return NewsSignupSuccess(email: _email.text.trim());
    }
    final submitLabel = widget.submitLabel ?? l.save;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: l.nameLabel,
          controller: _name,
          errorText: _submitAttempted && !_nameValid ? l.nameRequired : null,
          onChanged: (_) {
            setState(() {});
            _emitChanged();
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: l.emailLabel,
          controller: _email,
          errorText: _submitAttempted && !_emailValid ? l.emailInvalid : null,
          onChanged: (_) {
            setState(() {});
            _emitChanged();
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        CheckboxField(
          label: l.updatesAboutMyPeopleGroup,
          value: _wantsPeopleGroupUpdates,
          onChanged: (v) {
            setState(() => _wantsPeopleGroupUpdates = v);
            _emitChanged();
          },
        ),
        CheckboxField(
          label: l.updatesFromDoxa,
          value: _wantsDoxaUpdates,
          onChanged: (v) {
            setState(() => _wantsDoxaUpdates = v);
            _emitChanged();
          },
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            _errorMessage!,
            style: TextStyle(color: AppColors.scheme.error),
          ),
        ],
        if (widget.onSubmit != null) ...[
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
                label: submitLabel,
                onPressed: _submitting ? null : _submit,
                color: ActionButtonColor.secondary,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
