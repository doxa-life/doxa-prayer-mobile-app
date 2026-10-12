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
import 'prayer_need_ranking.dart';
import 'referral_controller.dart';
import 'subscribed_people_groups_controller.dart';
import 'wizard_completion_controller.dart';

enum WizardStep {
  welcome,
  groupIntro,
  peopleGroupsList,
  peopleGroupConfirm,
  groupPicked,
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

  // "Pick a group for me" (see [skipPeopleGroup]). The picked group keeps its
  // full list-model fields for the group-picked step's stats.
  PeopleGroup? _pickedGroup;
  bool _autoSelectingGroup = false;
  // Which step the auto-pick was asked from (the intro or the list's Skip),
  // so back() from the group-picked step returns there.
  WizardStep _pickedFrom = WizardStep.groupIntro;
  // Groups already offered this session, so "Pick another group" walks down
  // the ranking instead of offering the same one again.
  final Set<String> _offeredSlugs = {};
  // The auto-pick the user continued with, so it can be swapped out if they
  // come back and pick another rather than ending up following both.
  String? _subscribedPickSlug;
  // Whether the reminder step was reached through the auto-pick, for back().
  bool _reminderFromAutoPick = false;

  // Set in dispose() so async resolution continuations don't touch a disposed
  // notifier (notifyListeners() after dispose throws).
  bool _disposed = false;

  WizardStep get step => _step;
  PeopleGroup? get candidatePeopleGroup => _candidatePeopleGroup;

  /// The group "Pick a group for me" chose, for the group-picked step.
  PeopleGroup? get pickedGroup => _pickedGroup;

  /// True while a group is being picked — the buttons show a spinner.
  bool get autoSelectingGroup => _autoSelectingGroup;

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
      debugPrint('[deferred] welcome: no referred slug — showing group intro');
      _resolvingReferral = false;
      _set(WizardStep.groupIntro);
      return;
    }
    debugPrint(
      '[deferred] welcome: resolving referred people group slug="$slug"',
    );
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
    if (_step != WizardStep.groupIntro &&
        _step != WizardStep.peopleGroupsList &&
        _step != WizardStep.peopleGroupConfirm &&
        _step != WizardStep.groupPicked) {
      return;
    }
    debugPrint(
      '[deferred] mid-wizard referral arrived slug="$slug" — auto-selecting',
    );
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
        peopleCommitted: detail.peopleCommitted,
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

  /// Maps the 7-state machine onto 4 progress dots — every "choose a group"
  /// step (intro, list, confirm, picked) shares the second dot.
  int get progressIndex {
    switch (_step) {
      case WizardStep.welcome:
        return 0;
      case WizardStep.groupIntro:
      case WizardStep.peopleGroupsList:
      case WizardStep.peopleGroupConfirm:
      case WizardStep.groupPicked:
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
        _set(WizardStep.groupIntro);
      case WizardStep.groupIntro:
        _set(WizardStep.peopleGroupsList);
      case WizardStep.peopleGroupsList:
        _reminderFromAutoPick = false;
        _set(WizardStep.reminder);
      case WizardStep.peopleGroupConfirm:
        _candidatePeopleGroup = null;
        _reminderFromAutoPick = false;
        _set(WizardStep.reminder);
      case WizardStep.groupPicked:
        continueWithPickedGroup();
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
      case WizardStep.groupIntro:
        _set(WizardStep.welcome);
      case WizardStep.peopleGroupsList:
        _set(WizardStep.groupIntro);
      case WizardStep.peopleGroupConfirm:
        _candidatePeopleGroup = null;
        _set(WizardStep.peopleGroupsList);
      case WizardStep.groupPicked:
        _set(_pickedFrom);
      case WizardStep.reminder:
        _set(
          _reminderFromAutoPick
              ? WizardStep.groupPicked
              : WizardStep.peopleGroupsList,
        );
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

  /// The intro's "Find a people group" choice.
  void searchForGroup() => _set(WizardStep.peopleGroupsList);

  /// "Pick a group for me" (the intro) and Skip (the list): picks the group
  /// that most needs prayer — see [compareByPrayerNeed] — from the people
  /// groups list cached on the device, ranking every group each time since
  /// counts change as people start and stop praying. Lands on the
  /// group-picked step so the user sees which group they got. If no list can
  /// be had (offline on a first launch), carries on without a group, as
  /// skipping always did.
  Future<void> skipPeopleGroup() async {
    if (_autoSelectingGroup) return;
    _candidatePeopleGroup = null;
    _pickedFrom = _step;
    // Already continued with a pick and come back: show that group again
    // rather than re-ranking into a different one.
    final kept = _pickedGroup;
    if (kept != null && kept.slug == _subscribedPickSlug) {
      _set(WizardStep.groupPicked);
      return;
    }
    _offeredSlugs.clear();
    final picked = await _pickNext();
    if (_disposed) return;
    if (picked) {
      _set(WizardStep.groupPicked);
    } else {
      _reminderFromAutoPick = false;
      _set(WizardStep.reminder);
    }
  }

  /// The group-picked step's "Pick another group": the next group down the
  /// same ranking that hasn't been offered yet, re-ranked from the current
  /// cached list.
  Future<void> rerollPickedGroup() async {
    if (_autoSelectingGroup) return;
    await _pickNext();
  }

  /// "Continue with this group": follows the picked group and moves on to
  /// reminders. Replaces an earlier auto-pick the user continued with and
  /// then came back from, so they don't end up following both.
  Future<void> continueWithPickedGroup() async {
    final g = _pickedGroup;
    if (g == null) return;
    final previous = _subscribedPickSlug;
    if (previous != null && previous != g.slug) {
      await removePeopleGroup(previous);
    }
    await addPeopleGroup(
      SubscribedPeopleGroup(slug: g.slug, name: g.name, imageUrl: g.imageUrl),
    );
    _subscribedPickSlug = g.slug;
    if (_disposed) return;
    _reminderFromAutoPick = true;
    _set(WizardStep.reminder);
  }

  /// Picks the neediest group not yet offered (nor already followed) into
  /// [pickedGroup]. Once every group has been offered, starts again from the
  /// top. Returns false when there's no list to pick from.
  Future<bool> _pickNext() async {
    _autoSelectingGroup = true;
    notifyListeners();
    var picked = false;
    try {
      final lang = localeController.value.languageCode;
      final groups = await fetchPeopleGroups(lang: lang);
      final followed = peopleGroupsController.value;
      final candidates = rankByPrayerNeed(
        groups.where(
          (g) => !followed.contains(g.slug) || g.slug == _subscribedPickSlug,
        ),
      );
      var next = candidates
          .where((g) => !_offeredSlugs.contains(g.slug))
          .firstOrNull;
      if (next == null && candidates.isNotEmpty) {
        _offeredSlugs.clear();
        next = candidates.firstWhere(
          (g) => g.slug != _pickedGroup?.slug,
          orElse: () => candidates.first,
        );
      }
      if (next != null) {
        _pickedGroup = next;
        _offeredSlugs.add(next.slug);
        picked = true;
      }
    } catch (e, s) {
      developer.log(
        'auto-pick people group failed',
        name: 'wizard_controller',
        error: e,
        stackTrace: s,
      );
      reportError(e, s, reason: 'auto-pick people group failed');
    }
    if (!_disposed) {
      _autoSelectingGroup = false;
      notifyListeners();
    }
    return picked;
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
    final slug = activePeopleGroup?.slug;
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
