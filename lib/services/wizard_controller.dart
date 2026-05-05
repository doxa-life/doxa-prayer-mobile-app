import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../models/people_group.dart';
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

  WizardStep get step => _step;
  PeopleGroup? get candidatePeopleGroup => _candidatePeopleGroup;

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

  Future<void> finish(BuildContext context) async {
    await markWizardCompleted();
    if (context.mounted) context.go('/home');
  }

  void _set(WizardStep step) {
    if (_step == step) return;
    _step = step;
    notifyListeners();
  }
}
