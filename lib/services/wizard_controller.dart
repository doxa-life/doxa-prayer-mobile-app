import 'dart:developer' as developer;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../components/widgets/news_signup.dart';
import '../models/people_group.dart';
import 'anon_signup_service.dart';
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
  WizardStep _step = WizardStep.welcome;
  PeopleGroup? _candidatePeopleGroup;
  bool _resolvingReferral = false;

  WizardStep get step => _step;
  PeopleGroup? get candidatePeopleGroup => _candidatePeopleGroup;

  /// True while we're resolving a referred people group (from a "Pray on the app"
  /// link) after the welcome step — the welcome CTA shows a spinner meanwhile.
  bool get resolvingReferral => _resolvingReferral;

  /// Advances past the welcome step. If the user arrived via a "Pray on the app"
  /// link, the referred slug is resolved and we jump straight to the confirm step
  /// with that group pre-filled; otherwise we show the normal people-groups list.
  /// Back from confirm returns to the list so they can still choose differently.
  Future<void> startFromWelcome() async {
    if (_resolvingReferral) return;
    final slug = referredPeopleGroupController.value;
    if (slug == null || slug.isEmpty) {
      _set(WizardStep.peopleGroupsList);
      return;
    }
    _resolvingReferral = true;
    notifyListeners();
    try {
      final detail = await fetchPeopleGroupDetail(
        slug,
        lang: localeController.value.languageCode,
      );
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
      _resolvingReferral = false;
      _set(WizardStep.peopleGroupConfirm);
    } catch (e, s) {
      developer.log(
        'referred people group lookup failed',
        name: 'wizard_controller',
        error: e,
        stackTrace: s,
      );
      await clearReferredPeopleGroup();
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

  Future<void> finish(BuildContext context, {NewsSignupData? newsSignup}) async {
    final slug = selectedPeopleGroupController.value?.slug;
    if (slug != null && slug.isNotEmpty) {
      try {
        await submitAnonSignup(
          slug: slug,
          name: newsSignup?.name ?? '',
          email: newsSignup?.email ?? '',
          consentDoxaGeneral: newsSignup?.wantsDoxaUpdates ?? false,
          consentPeopleGroupUpdates:
              newsSignup?.wantsPeopleGroupUpdates ?? false,
        );
      } catch (e, s) {
        developer.log(
          'anon-signup failed at wizard finish',
          name: 'wizard_controller',
          error: e,
          stackTrace: s,
        );
      }
    }
    if (newsSignup != null) {
      try {
        await submitNewsSignup(newsSignup);
      } catch (e, s) {
        developer.log(
          'news-signup failed at wizard finish',
          name: 'wizard_controller',
          error: e,
          stackTrace: s,
        );
      }
    }
    await markWizardCompleted();
    if (context.mounted) context.go('/home');
  }

  void _set(WizardStep step) {
    if (_step == step) return;
    _step = step;
    notifyListeners();
  }
}
