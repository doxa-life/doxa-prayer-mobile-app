import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _storageKey = 'wizard_completed';

final ValueNotifier<bool> wizardCompletedController = ValueNotifier<bool>(
  false,
);

Future<void> loadWizardCompleted() async {
  final prefs = SharedPreferencesAsync();
  wizardCompletedController.value = await prefs.getBool(_storageKey) ?? false;
}

Future<void> markWizardCompleted() async {
  wizardCompletedController.value = true;
  final prefs = SharedPreferencesAsync();
  await prefs.setBool(_storageKey, true);
}
