import 'dart:convert';
import 'dart:io';

import 'package:doxa_prayer_mobile_app/l10n/app_localizations.dart';
import 'package:doxa_prayer_mobile_app/services/hyphenation_service.dart';
import 'package:doxa_prayer_mobile_app/services/locale_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every app language must be supported everywhere the app is language-aware,
/// so adding one can't leave part of the app behind. The translation files
/// (lib/l10n/app_<code>.arb) define what the app's languages are; each check
/// below names the place a language is missing from. The add-language skill
/// walks through every one of them.
///
/// String-level parity inside the ARB files (same keys, placeholders, plural
/// forms) is checked by tool/check_arb.py.
void main() {
  final arbLanguages =
      Directory('lib/l10n')
          .listSync()
          .whereType<File>()
          .map((f) => RegExp(r'app_(\w+)\.arb$').firstMatch(f.path)?.group(1))
          .whereType<String>()
          .toSet()
          .toList()
        ..sort();

  test('translation files were found', () {
    expect(arbLanguages, contains('en'));
  });

  test('every language is offered in the language picker', () {
    final offered = appLanguages.map((l) => l.locale.languageCode).toSet();
    expect(
      arbLanguages.toSet().difference(offered),
      isEmpty,
      reason:
          'Translated but not offered: add to appLanguages in '
          'lib/services/locale_controller.dart.',
    );
    expect(
      offered.difference(arbLanguages.toSet()),
      isEmpty,
      reason: 'Offered in appLanguages but no lib/l10n/app_<code>.arb exists.',
    );
  });

  test('every language is in the generated localizations', () {
    final generated = AppLocalizations.supportedLocales
        .map((l) => l.languageCode)
        .toSet();
    expect(
      arbLanguages.toSet().difference(generated),
      isEmpty,
      reason: 'Generated localizations are stale: run `flutter gen-l10n`.',
    );
  });

  test('every thank-you verse is translated into every language', () {
    final verses =
        (jsonDecode(File('assets/thank_you_verses.json').readAsStringSync())
                as Map<String, dynamic>)['verses']
            as List<dynamic>;
    final missing = <String>[];
    for (var i = 0; i < verses.length; i++) {
      final locales =
          (verses[i] as Map<String, dynamic>)['locales'] as Map<String, dynamic>;
      for (final code in arbLanguages) {
        final text = (locales[code] as Map<String, dynamic>?)?['text'];
        if (text is! String || text.trim().isEmpty) missing.add('$code #$i');
      }
    }
    expect(
      missing,
      isEmpty,
      reason:
          'Verses missing from assets/thank_you_verses.json: run '
          '`python3 tool/fetch_thank_you_verses.py`.',
    );
  });

  test('every language has a hyphenation decision', () {
    for (final code in arbLanguages) {
      final hyphenated = localeSupportsHyphenation(Locale(code));
      final exempt = unhyphenatedLanguages.containsKey(code);
      expect(
        hyphenated || exempt,
        isTrue,
        reason:
            '$code is not hyphenated. Add its patterns (docs/hyphenation.md), '
            'or — only if its script never hyphenates — list it in '
            'unhyphenatedLanguages in lib/services/hyphenation_service.dart.',
      );
      expect(
        hyphenated && exempt,
        isFalse,
        reason: '$code is both hyphenated and in unhyphenatedLanguages.',
      );
    }
    expect(
      unhyphenatedLanguages.keys.toSet().difference(arbLanguages.toSet()),
      isEmpty,
      reason: 'unhyphenatedLanguages lists a language the app does not have.',
    );
  });
}
