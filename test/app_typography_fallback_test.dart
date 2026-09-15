import 'dart:io';

import 'package:doxa_prayer_mobile_app/services/locale_controller.dart';
import 'package:doxa_prayer_mobile_app/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The families a style may fall back to must actually ship, and every style
/// must ask for them — none of the three brand faces covers more than Latin, so
/// a style without the chain renders Cyrillic, Arabic or Han in whatever font
/// the device happens to have.
void main() {
  group('typography script fallback', () {
    test('every fallback family is declared in pubspec', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      for (final family in AppFonts.fallback) {
        expect(
          pubspec,
          contains('- family: $family'),
          reason: '$family is in AppFonts.fallback but not bundled',
        );
      }
    });

    test('every declared font asset exists', () {
      final assets = RegExp(r'- asset: (assets/fonts/\S+)')
          .allMatches(File('pubspec.yaml').readAsStringSync())
          .map((m) => m.group(1)!);
      expect(assets, isNotEmpty);
      for (final path in assets) {
        expect(File(path).existsSync(), isTrue, reason: '$path is missing');
      }
    });

    test('every text style in the theme carries the fallback chain', () {
      final theme = AppTypography.textThemeFor(const Locale('en'));
      final styles = <String, TextStyle?>{
        'displayLarge': theme.displayLarge,
        'displayMedium': theme.displayMedium,
        'titleMedium': theme.titleMedium,
        'titleLarge': theme.titleLarge,
        'bodyLarge': theme.bodyLarge,
        'bodyMedium': theme.bodyMedium,
        'labelLarge': theme.labelLarge,
        'labelSmall': theme.labelSmall,
      };
      styles.forEach((name, style) {
        expect(style, isNotNull, reason: '$name is unset');
        expect(
          style!.fontFamilyFallback,
          AppFonts.fallback,
          reason: '$name does not carry AppFonts.fallback',
        );
      });
    });
  });

  group('button face', () {
    // BrandonGrotesque has no accented letters, so a label like "Ausgewählt"
    // would be drawn in two faces at once. Only English stays inside its glyph
    // set.
    test('English keeps the display face', () {
      expect(
        AppTypography.buttonFor(const Locale('en')).fontFamily,
        AppFonts.brandonGrotesque,
      );
    });

    test('every other shipping language uses Poppins', () {
      final others = appLanguages
          .where((l) => l.locale.languageCode != 'en')
          .map((l) => l.locale);
      expect(others, isNotEmpty);
      for (final locale in others) {
        expect(
          AppTypography.buttonFor(locale).fontFamily,
          AppFonts.poppins,
          reason: '${locale.languageCode} buttons must not use a Latin-only '
              'display face',
        );
      }
    });

    test('the face is the only thing that changes', () {
      final en = AppTypography.buttonFor(const Locale('en'));
      final de = AppTypography.buttonFor(const Locale('de'));
      expect(de.fontSize, en.fontSize);
      expect(de.fontWeight, en.fontWeight);
      expect(de.letterSpacing, en.letterSpacing);
    });
  });
}
