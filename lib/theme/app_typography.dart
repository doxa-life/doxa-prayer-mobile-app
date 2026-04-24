import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppFonts {
  const AppFonts._();
  static const bebasKai = 'BebasKai';
  static const poppins = 'Poppins';
  static const brandonGrotesque = 'BrandonGrotesque';
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
    fontFamily: AppFonts.bebasKai,
    fontWeight: FontWeight.w400,
    fontSize: xxl,
    letterSpacing: 0.5,
    color: AppColors.onSurface,
  );

  static const h2 = TextStyle(
    fontFamily: AppFonts.bebasKai,
    fontWeight: FontWeight.w400,
    fontSize: xl,
    letterSpacing: 0.5,
    color: AppColors.onSurface,
  );

  static const titleMedium = TextStyle(
    fontFamily: AppFonts.poppins,
    fontWeight: FontWeight.w500,
    fontSize: lg,
    color: AppColors.onSurface,
  );

  static const bodyLarge = TextStyle(
    fontFamily: AppFonts.poppins,
    fontWeight: FontWeight.w400,
    fontSize: lg,
    height: 1.5,
    color: AppColors.onSurface,
  );

  static const bodyMedium = TextStyle(
    fontFamily: AppFonts.poppins,
    fontWeight: FontWeight.w400,
    fontSize: md,
    height: 1.5,
    color: AppColors.onSurface,
  );

  static const bodySmall = TextStyle(
    fontFamily: AppFonts.poppins,
    fontWeight: FontWeight.w400,
    fontSize: sm,
    height: 1.5,
    color: AppColors.onSurface,
  );

  static const button = TextStyle(
    fontFamily: AppFonts.brandonGrotesque,
    fontWeight: FontWeight.w600,
    fontSize: md,
    letterSpacing: 1.0,
  );

  static const caption = TextStyle(
    fontFamily: AppFonts.poppins,
    fontWeight: FontWeight.w400,
    fontSize: sm,
    color: AppColors.onSurface,
  );

  static const textTheme = TextTheme(
    displayLarge: h1,
    displayMedium: h2,
    titleMedium: titleMedium,
    bodyLarge: bodyMedium,
    bodyMedium: bodySmall,
    labelLarge: button,
    labelSmall: caption,
  );
}
