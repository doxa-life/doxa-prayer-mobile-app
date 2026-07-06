import 'dart:developer' as developer;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../components/widgets/news_signup.dart';
import '../models/people_group.dart';
import 'anon_signup_service.dart';
import 'crash_reporting_service.dart';
import 'install_referrer_service.dart';
import 'locale_controller.dart';
import 'news_signup_service.dart';
import 'people_groups_service.dart';
import 'referral_controller.dart';
import 'selected_people_group_controller.dart';
import 'wizard_completion_controller.dart';

enum WizardStep {
  welcome,
  peopleGroupsList,
  peopleGroupConfirm,
  reminder,
  newsSignup,
}

class WizardController extends ChangeNotifier {
  WizardController() {
    // React to a referred people group arriving *during* onboarding — e.g. a
    // "Pray on the app" deep link (or, later, an in-app QR scan) that fires
    // setReferredPeopleGroup while the user is already mid-wizard. The welcome
    // step is handled separately by its CTA (see startFromWelcome).
    referredPeopleGroupController.addListener(_onReferredSlugChanged);
  }

  WizardStep _step = WizardStep.welcome;
  PeopleGroup? _candidatePeopleGroup;
  bool _resolvingReferral = false;
  // Set in dispose() so async resolution continuations don't touch a disposed
  // notifier (notifyListeners() after dispose throws).
  bool _disposed = false;

  WizardStep get step => _step;
  PeopleGroup? get candidatePeopleGroup => _candidatePeopleGroup;

  @override
  void dispose() {
    _disposed = true;
    referredPeopleGroupController.removeListener(_onReferredSlugChanged);
    super.dispose();
  }

  /// True while we're resolving a referred people group (from a "Pray on the app"
  /// link) after the welcome step — the welcome CTA shows a spinner meanwhile.
  bool get resolvingReferral => _resolvingReferral;

  /// Advances past the welcome step. If the user arrived via a "Pray on the app"
  /// link, the referred slug is resolved and we jump straight to the confirm step
  /// with that group pre-filled; otherwise we show the normal people-groups list.
  /// Back from confirm returns to the list so they can still choose differently.
  Future<void> startFromWelcome() async {
    if (_resolvingReferral) return;
    _resolvingReferral = true;
    notifyListeners();

    // The install-referrer lookup is fire-and-forget from main(); on a fresh
    // install the referred slug may not be stored yet when the user taps through
    // the welcome step. Await the single in-flight lookup (instant once done) so
    // a fast tapper doesn't race it. Bounded so a slow/hung Play Store service
    // can't wedge onboarding — we just fall through with whatever we have.
    try {
      await fetchInstallReferrer().timeout(const Duration(seconds: 5));
    } catch (_) {
      // Timeout or lookup failure — the install_referrer_service already logged it.
    }

    if (_disposed) return;
    final slug = referredPeopleGroupController.value;
    if (slug == null || slug.isEmpty) {
      debugPrint('[deferred] welcome: no referred slug — showing people-groups list');
      _resolvingReferral = false;
      _set(WizardStep.peopleGroupsList);
      return;
    }
    debugPrint('[deferred] welcome: resolving referred people group slug="$slug"');
    await _resolveReferredSlug(slug);
  }

  /// Reacts to the referred slug changing while the wizard is already open — a
  /// deep link / in-app scan that fires setReferredPeopleGroup mid-onboarding.
  /// Only auto-selects while the user is still choosing a group; the welcome
  /// step is owned by its CTA (which awaits the install-referrer race), and the
  /// later reminder/news-signup steps are left alone so we don't yank the user
  /// backwards. A cleared slug (null) is a no-op, which also breaks any loop
  /// with [clearReferredPeopleGroup].
  void _onReferredSlugChanged() {
    if (_disposed) return;
    final slug = referredPeopleGroupController.value;
    if (slug == null || slug.isEmpty) return;
    if (_resolvingReferral) return;
    if (_step != WizardStep.peopleGroupsList &&
        _step != WizardStep.peopleGroupConfirm) {
      return;
    }
    debugPrint('[deferred] mid-wizard referral arrived slug="$slug" — auto-selecting');
    _resolveReferredSlug(slug);
  }

  /// Resolves [slug] to a people group and jumps to the confirm step with it
  /// pre-filled (falls back to the people-groups list on failure). Owns the
  /// [resolvingReferral] flag for its duration. Shared by the welcome CTA path
  /// ([startFromWelcome]) and the reactive listener ([_onReferredSlugChanged]).
  Future<void> _resolveReferredSlug(String slug) async {
    _resolvingReferral = true;
    notifyListeners();
    try {
      final detail = await fetchPeopleGroupDetail(
        slug,
        lang: localeController.value.languageCode,
      );
      if (_disposed) return;
      _candidatePeopleGroup = PeopleGroup(
        name: detail.name,
        slug: detail.slug,
        imageUrl: detail.imageUrl,
        countryLabel: null,
        religionLabel: null,
        peoplePraying: 0,
      );
      // Consume the referral so a later wizard re-entry won't re-trigger it.
      await clearReferredPeopleGroup();
      if (_disposed) return;
      _resolvingReferral = false;
      _set(WizardStep.peopleGroupConfirm);
    } catch (e, s) {
      developer.log(
        'referred people group lookup failed',
        name: 'wizard_controller',
        error: e,
        stackTrace: s,
      );
      reportError(e, s, reason: 'referred people group lookup failed');
      await clearReferredPeopleGroup();
      if (_disposed) return;
      _resolvingReferral = false;
      _set(WizardStep.peopleGroupsList);
    }
  }

  /// Maps the 5-state machine onto 4 progress dots — the confirm sub-step
  /// shares its dot with the people-group list step.
  int get progressIndex {
    switch (_step) {
      case WizardStep.welcome:
        return 0;
      case WizardStep.peopleGroupsList:
      case WizardStep.peopleGroupConfirm:
        return 1;
      case WizardStep.reminder:
        return 2;
      case WizardStep.newsSignup:
        return 3;
    }
  }

  bool get canGoBack => _step != WizardStep.welcome;

  void next() {
    switch (_step) {
      case WizardStep.welcome:
        _set(WizardStep.peopleGroupsList);
      case WizardStep.peopleGroupsList:
        _set(WizardStep.reminder);
      case WizardStep.peopleGroupConfirm:
        _candidatePeopleGroup = null;
        _set(WizardStep.reminder);
      case WizardStep.reminder:
        _set(WizardStep.newsSignup);
      case WizardStep.newsSignup:
        break;
    }
  }

  void back() {
    switch (_step) {
      case WizardStep.welcome:
        break;
      case WizardStep.peopleGroupsList:
        _set(WizardStep.welcome);
      case WizardStep.peopleGroupConfirm:
        _candidatePeopleGroup = null;
        _set(WizardStep.peopleGroupsList);
      case WizardStep.reminder:
        _set(WizardStep.peopleGroupsList);
      case WizardStep.newsSignup:
        _set(WizardStep.reminder);
    }
  }

  void proposePeopleGroup(PeopleGroup g) {
    _candidatePeopleGroup = g;
    _set(WizardStep.peopleGroupConfirm);
  }

  void cancelPeopleGroupSelection() {
    _candidatePeopleGroup = null;
    _set(WizardStep.peopleGroupsList);
  }

  void skipPeopleGroup() {
    _candidatePeopleGroup = null;
    _set(WizardStep.reminder);
  }

  /// Performs the signup for the news-signup step: the people-group prayer
  /// subscription (best-effort) plus the news/email signup. Does NOT complete the
  /// wizard — the step shows the "check your email" confirmation first, then the
  /// user taps Finish ([complete]). Rethrows a news-signup failure so the step can
  /// surface it inline and keep the Sign up button available for a retry.
  Future<void> signUp({required NewsSignupData newsSignup}) async {
    await _submitPeopleGroupSignup(newsSignup);
    await submitNewsSignup(newsSignup);
  }

  /// Skips the news-signup step: still registers the selected people group
  /// (best-effort) but sends no email, then completes the wizard.
  Future<void> skip(BuildContext context) async {
    await _submitPeopleGroupSignup(null);
    if (context.mounted) await complete(context);
  }

  /// Finishes onboarding and routes to home. Called by the Finish button once the
  /// user has signed up, and by [skip].
  Future<void> complete(BuildContext context) async {
    await markWizardCompleted();
    if (context.mounted) context.go('/home');
  }

  /// Registers the selected people group's prayer subscription. Best-effort: a
  /// failure is logged and swallowed so onboarding is never blocked by it.
  Future<void> _submitPeopleGroupSignup(NewsSignupData? newsSignup) async {
    final slug = selectedPeopleGroupController.value?.slug;
    if (slug == null || slug.isEmpty) return;
    try {
      await submitAnonSignup(
        slug: slug,
        name: newsSignup?.name ?? '',
        email: newsSignup?.email ?? '',
        consentDoxaGeneral: newsSignup?.wantsDoxaUpdates ?? false,
        consentPeopleGroupUpdates: newsSignup?.wantsPeopleGroupUpdates ?? false,
      );
    } catch (e, s) {
      developer.log(
        'anon-signup failed at wizard finish',
        name: 'wizard_controller',
        error: e,
        stackTrace: s,
      );
      reportError(e, s, reason: 'anon-signup failed at wizard finish');
    }
  }

  void _set(WizardStep step) {
    if (_step == step) return;
    _step = step;
    notifyListeners();
  }
}
