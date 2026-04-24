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

  static const h1 = TextStyle(
    fontFamily: AppFonts.bebasKai,
    fontWeight: FontWeight.w400,
    fontSize: 32,
    letterSpacing: 0.5,
    color: AppColors.onSurface,
  );

  static const h2 = TextStyle(
    fontFamily: AppFonts.bebasKai,
    fontWeight: FontWeight.w400,
    fontSize: 24,
    letterSpacing: 0.5,
    color: AppColors.onSurface,
  );

  static const titleMedium = TextStyle(
    fontFamily: AppFonts.poppins,
    fontWeight: FontWeight.w500,
    fontSize: 18,
    color: AppColors.onSurface,
  );

  static const bodyLarge = TextStyle(
    fontFamily: AppFonts.poppins,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.5,
    color: AppColors.onSurface,
  );

  static const bodyMedium = TextStyle(
    fontFamily: AppFonts.poppins,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.5,
    color: AppColors.onSurface,
  );

  static const button = TextStyle(
    fontFamily: AppFonts.brandonGrotesque,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    letterSpacing: 1.0,
  );

  static const caption = TextStyle(
    fontFamily: AppFonts.poppins,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: AppColors.onSurface,
  );

  static const textTheme = TextTheme(
    displayLarge: h1,
    displayMedium: h2,
    titleMedium: titleMedium,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    labelLarge: button,
    labelSmall: caption,
  );
}
