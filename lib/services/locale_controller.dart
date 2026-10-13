import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analytics_service.dart';
import 'hyphenation_service.dart';

class AppLanguage {
  const AppLanguage({
    required this.locale,
    required this.nativeName,
    required this.flagCode,
  });

  final Locale locale;
  final String nativeName;

  /// ISO alpha-3 code of the country whose flag stands for this language in
  /// the language selector — see `CountryFlag`. A language is not a country,
  /// so this is the conventional pick, not a claim about where it is spoken.
  final String flagCode;
}

/// Every language the app ships, in the order the language selector shows
/// them: alphabetical by native name, with the non-Latin scripts after the
/// Latin ones. Nothing depends on this order — [defaultLocale] is the
/// fallback, not the first entry.
const List<AppLanguage> appLanguages = <AppLanguage>[
  AppLanguage(
    locale: Locale('de'),
    nativeName: 'Deutsch',
    flagCode: 'DEU',
  ),
  AppLanguage(
    locale: Locale('en'),
    nativeName: 'English',
    flagCode: 'GBR',
  ),
  AppLanguage(
    locale: Locale('es'),
    nativeName: 'Español',
    flagCode: 'ESP',
  ),
  AppLanguage(
    locale: Locale('fr'),
    nativeName: 'Français',
    flagCode: 'FRA',
  ),
  AppLanguage(
    locale: Locale('it'),
    nativeName: 'Italiano',
    flagCode: 'ITA',
  ),
  AppLanguage(
    locale: Locale('pt'),
    nativeName: 'Português',
    flagCode: 'PRT',
  ),
  AppLanguage(
    locale: Locale('ro'),
    nativeName: 'Română',
    flagCode: 'ROU',
  ),
  AppLanguage(
    locale: Locale('fi'),
    nativeName: 'suomi',
    flagCode: 'FIN',
  ),
  AppLanguage(
    locale: Locale('ru'),
    nativeName: 'Русский',
    flagCode: 'RUS',
  ),
  AppLanguage(
    locale: Locale('ar'),
    nativeName: 'العربية',
    flagCode: 'SAU',
  ),
  AppLanguage(
    locale: Locale('hi'),
    nativeName: 'हिन्दी',
    flagCode: 'IND',
  ),
  AppLanguage(
    locale: Locale('zh'),
    nativeName: '简体中文',
    flagCode: 'CHN',
  ),
];

/// The locale used before a preference is read and when no system locale
/// matches a shipped language.
const Locale defaultLocale = Locale('en');

const _storageKey = 'app_locale_language_code';

final ValueNotifier<Locale> localeController = ValueNotifier<Locale>(
  defaultLocale,
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
  return defaultLocale;
}

Locale? _matchByLanguageCode(String languageCode) {
  for (final lang in appLanguages) {
    if (lang.locale.languageCode == languageCode) return lang.locale;
  }
  return null;
}
