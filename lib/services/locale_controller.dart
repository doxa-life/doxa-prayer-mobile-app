import 'package:flutter/material.dart';

class AppLanguage {
  const AppLanguage({required this.locale, required this.nativeName});

  final Locale locale;
  final String nativeName;
}

const List<AppLanguage> appLanguages = <AppLanguage>[
  AppLanguage(locale: Locale('en'), nativeName: 'English'),
  AppLanguage(locale: Locale('es', 'ES'), nativeName: 'Español'),
  AppLanguage(locale: Locale('pt', 'BR'), nativeName: 'Português'),
  AppLanguage(locale: Locale('fr', 'FR'), nativeName: 'Français'),
  AppLanguage(locale: Locale('ru', 'RU'), nativeName: 'Русский'),
  AppLanguage(locale: Locale('ar'), nativeName: 'العربية'),
];

final ValueNotifier<Locale> localeController = ValueNotifier<Locale>(
  appLanguages.first.locale,
);
