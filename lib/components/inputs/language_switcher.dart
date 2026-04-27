import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/locale_controller.dart';
import 'select_field.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeController,
      builder: (context, locale, _) {
        return SelectField<Locale>(
          label: AppLocalizations.of(context)!.language,
          value: _matchSupportedLocale(locale),
          items: appLanguages
              .map(
                (lang) => DropdownMenuItem<Locale>(
                  value: lang.locale,
                  child: Text(lang.nativeName),
                ),
              )
              .toList(growable: false),
          onChanged: (selected) {
            if (selected != null) {
              localeController.value = selected;
            }
          },
        );
      },
    );
  }

  Locale? _matchSupportedLocale(Locale current) {
    for (final lang in appLanguages) {
      if (lang.locale == current) return lang.locale;
    }
    for (final lang in appLanguages) {
      if (lang.locale.languageCode == current.languageCode) return lang.locale;
    }
    return null;
  }
}
