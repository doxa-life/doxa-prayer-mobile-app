import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analytics_service.dart';

class AppLanguage {
  const AppLanguage({required this.locale, required this.nativeName});

  final Locale locale;
  final String nativeName;
}

const List<AppLanguage> appLanguages = <AppLanguage>[
  AppLanguage(locale: Locale('en'), nativeName: 'English'),
  AppLanguage(locale: Locale('es'), nativeName: 'Español'),
  AppLanguage(locale: Locale('pt'), nativeName: 'Português'),
  AppLanguage(locale: Locale('fr'), nativeName: 'Français'),
  AppLanguage(locale: Locale('ru'), nativeName: 'Русский'),
  AppLanguage(locale: Locale('ar'), nativeName: 'العربية'),
];

const _storageKey = 'app_locale_language_code';

final ValueNotifier<Locale> localeController = ValueNotifier<Locale>(
  appLanguages.first.locale,
);

Future<void> loadLocale() async {
  final prefs = SharedPreferencesAsync();
  final saved = await prefs.getString(_storageKey);
  if (saved != null) {
    final match = _matchByLanguageCode(saved);
    if (match != null) {
      localeController.value = match;
      return;
    }
  }
  localeController.value = _bestMatchForSystem();
}

Future<void> setLocale(Locale locale) async {
  final previous = localeController.value;
  localeController.value = locale;
  final prefs = SharedPreferencesAsync();
  await prefs.setString(_storageKey, locale.languageCode);
  if (locale.languageCode != previous.languageCode) {
    trackLanguageSwitched(
      locale.languageCode,
      previous: previous.languageCode,
    );
  }
}

Future<void> clearLocale() async {
  final prefs = SharedPreferencesAsync();
  await prefs.remove(_storageKey);
  localeController.value = _bestMatchForSystem();
}

Locale _bestMatchForSystem() {
  for (final systemLocale in PlatformDispatcher.instance.locales) {
    final match = _matchByLanguageCode(systemLocale.languageCode);
    if (match != null) return match;
  }
  return appLanguages.first.locale;
}

Locale? _matchByLanguageCode(String languageCode) {
  for (final lang in appLanguages) {
    if (lang.locale.languageCode == languageCode) return lang.locale;
  }
  return null;
}
