import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/locale_controller.dart';
import '../../theme/app_spacing.dart';
import '../misc/country_flag.dart';
import 'select_field.dart';
import '../misc/hyphenated_text.dart';

class LanguageSwitcher extends StatelessWidget {
  /// Switches straight away, with no "keep this language?" check: the
  /// selector stays where it was, each language named in its own script, so
  /// a wrong pick is undone by picking again.
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CountryFlag(code: lang.flagCode, height: 16),
                      const SizedBox(width: AppSpacing.md),
                      Flexible(child: HyphenatedText(lang.nativeName)),
                    ],
                  ),
                ),
              )
              .toList(growable: false),
          onChanged: (selected) {
            if (selected == null) return;
            setLocale(selected);
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
