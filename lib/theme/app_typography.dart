import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppFonts {
  const AppFonts._();
  static const bebasKai = 'BebasKai';
  static const poppins = 'Poppins';
  static const brandonGrotesque = 'BrandonGrotesque';
  static const roboto = 'Roboto';
  static const notoSansArabic = 'NotoSansArabic';
  static const notoSansSC = 'NotoSansSC';

  /// Tried in order for any glyph the style's own family lacks.
  ///
  /// Every style carries this, because none of the three brand faces covers
  /// more than Latin: BebasKai and BrandonGrotesque are Latin display faces and
  /// Poppins adds only Devanagari. Without it the engine silently substitutes
  /// whatever the OS ships, which differs per device and per platform.
  ///
  /// Order is by specificity, not preference — the scripts do not overlap
  /// except in Latin, which never reaches this list. Roboto precedes
  /// NotoSansSC because both carry Cyrillic and Roboto is the text face for it
  /// (`cyrillic: roboto` in the pipeline's language atlas).
  static const fallback = <String>[
    poppins,
    roboto,
    notoSansArabic,
    notoSansSC,
  ];
}

class AppTypography {
  const AppTypography._();

  static const double fontScaleRatio = 1.3;
  static const double md = 18.0;
  static const double lg = md * fontScaleRatio;
  static const double xl = lg * fontScaleRatio;
  static const double xxl = xl * fontScaleRatio;
  static const double sm = md / fontScaleRatio;
  static const double xs = sm / fontScaleRatio;
  static const double xxs = xs / fontScaleRatio;

  static const h1 = TextStyle(
    fontFamilyFallback: AppFonts.fallback,
    fontFamily: AppFonts.bebasKai,
    fontWeight: FontWeight.w400,
    fontSize: xxl,
    letterSpacing: 0.5,
    color: AppColors.onSurface,
  );

  static const h2 = TextStyle(
    fontFamilyFallback: AppFonts.fallback,
    fontFamily: AppFonts.bebasKai,
    fontWeight: FontWeight.w400,
    fontSize: xl,
    letterSpacing: 0.5,
    color: AppColors.onSurface,
  );

  static const titleMedium = TextStyle(
    fontFamilyFallback: AppFonts.fallback,
    fontFamily: AppFonts.poppins,
    fontWeight: FontWeight.w500,
    fontSize: lg,
    color: AppColors.onSurface,
  );

  static const titleLarge = TextStyle(
    fontFamilyFallback: AppFonts.fallback,
    fontFamily: AppFonts.poppins,
    fontWeight: FontWeight.w500,
    fontSize: xl,
    color: AppColors.onSurface,
  );

  static const bodyLarge = TextStyle(
    fontFamilyFallback: AppFonts.fallback,
    fontFamily: AppFonts.poppins,
    fontWeight: FontWeight.w400,
    fontSize: lg,
    height: 1.5,
    color: AppColors.onSurface,
  );

  static const bodyMedium = TextStyle(
    fontFamilyFallback: AppFonts.fallback,
    fontFamily: AppFonts.poppins,
    fontWeight: FontWeight.w400,
    fontSize: md,
    height: 1.5,
    color: AppColors.onSurface,
  );

  static const bodySmall = TextStyle(
    fontFamilyFallback: AppFonts.fallback,
    fontFamily: AppFonts.poppins,
    fontWeight: FontWeight.w400,
    fontSize: sm,
    height: 1.5,
    color: AppColors.onSurface,
  );

  static const button = TextStyle(
    fontFamilyFallback: AppFonts.fallback,
    fontFamily: AppFonts.brandonGrotesque,
    fontWeight: FontWeight.w600,
    fontSize: md,
    letterSpacing: 1.0,
  );

  static const caption = TextStyle(
    fontFamilyFallback: AppFonts.fallback,
    fontFamily: AppFonts.poppins,
    fontWeight: FontWeight.w400,
    fontSize: sm,
    color: AppColors.onSurface,
  );

  /// The button style for [locale].
  ///
  /// BrandonGrotesque carries 70 glyphs — A-Z, a-z, 0-9 and `!,-.?` — so an
  /// accented letter, apostrophe or ampersand in a label is drawn by another
  /// face, mid-word, at different proportions. A [fontFamilyFallback] cannot
  /// fix that: it is per-glyph by design, which is exactly the mixed-typeface
  /// result to avoid here. So only English, whose labels stay inside that set,
  /// keeps the display face; every other language sets its buttons in Poppins.
  static TextStyle buttonFor(Locale locale) => locale.languageCode == 'en'
      ? button
      : button.copyWith(fontFamily: AppFonts.poppins);

  static TextTheme textThemeFor(Locale locale) => TextTheme(
    displayLarge: h1,
    displayMedium: h2,
    titleMedium: titleMedium,
    titleLarge: titleLarge,
    bodyLarge: bodyMedium,
    bodyMedium: bodySmall,
    labelLarge: buttonFor(locale),
    labelSmall: caption,
  );
}
