import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analytics_service.dart';
import 'hyphenation_service.dart';

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
  AppLanguage(locale: Locale('de'), nativeName: 'Deutsch'),
  AppLanguage(locale: Locale('hi'), nativeName: 'हिन्दी'),
  AppLanguage(locale: Locale('it'), nativeName: 'Italiano'),
  AppLanguage(locale: Locale('ro'), nativeName: 'Română'),
  AppLanguage(locale: Locale('zh'), nativeName: '简体中文'),
];

const _storageKey = 'app_locale_language_code';

final ValueNotifier<Locale> localeController = ValueNotifier<Locale>(
  appLanguages.first.locale,
);

/// Switches the app to [locale], with its hyphenation patterns already loaded.
///
/// Building a hyphenator takes 165–280ms, which must not happen lazily inside a
/// layout pass, so it is awaited here — before any text is laid out in the new
/// language. See `hyphenation_service.dart`.
Future<void> _applyLocale(Locale locale) async {
  await preloadHyphenator(locale);
  localeController.value = locale;
}

Future<void> loadLocale() async {
  final prefs = SharedPreferencesAsync();
  final saved = await prefs.getString(_storageKey);
  if (saved != null) {
    final match = _matchByLanguageCode(saved);
    if (match != null) {
      await _applyLocale(match);
      return;
    }
  }
  await _applyLocale(_bestMatchForSystem());
}

Future<void> setLocale(Locale locale) async {
  final previous = localeController.value;
  await _applyLocale(locale);
  final prefs = SharedPreferencesAsync();
  await prefs.setString(_storageKey, locale.languageCode);
  if (locale.languageCode != previous.languageCode) {
    trackLanguageSwitched(locale.languageCode, previous: previous.languageCode);
  }
}

Future<void> clearLocale() async {
  final prefs = SharedPreferencesAsync();
  await prefs.remove(_storageKey);
  await _applyLocale(_bestMatchForSystem());
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
