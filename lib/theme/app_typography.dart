import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppFonts {
  const AppFonts._();
  static const bebasKai = 'BebasKai';
  static const poppins = 'Poppins';
  static const brandonGrotesque = 'BrandonGrotesque';
}

const double fontScaleRatio = 1.3;
const double fontSizeBase = 18.0;
const double fontSizeUp1 = fontSizeBase * fontScaleRatio;
const double fontSizeUp2 = fontSizeUp1 * fontScaleRatio;
const double fontSizeUp3 = fontSizeUp2 * fontScaleRatio;
const double fontSizeDown1 = fontSizeBase / fontScaleRatio;
const double fontSizeDown2 = fontSizeDown1 / fontScaleRatio;
const double fontSizeDown3 = fontSizeDown2 / fontScaleRatio;

class AppTypography {
  const AppTypography._();

  static const h1 = TextStyle(
    fontFamily: AppFonts.bebasKai,
    fontWeight: FontWeight.w400,
    fontSize: fontSizeUp3,
    letterSpacing: 0.5,
    color: AppColors.onSurface,
  );

  static const h2 = TextStyle(
    fontFamily: AppFonts.bebasKai,
    fontWeight: FontWeight.w400,
    fontSize: fontSizeUp2,
    letterSpacing: 0.5,
    color: AppColors.onSurface,
  );

  static const titleMedium = TextStyle(
    fontFamily: AppFonts.poppins,
    fontWeight: FontWeight.w500,
    fontSize: fontSizeUp1,
    color: AppColors.onSurface,
  );

  static const bodyLarge = TextStyle(
    fontFamily: AppFonts.poppins,
    fontWeight: FontWeight.w400,
    fontSize: fontSizeUp1,
    height: 1.5,
    color: AppColors.onSurface,
  );

  static const bodyMedium = TextStyle(
    fontFamily: AppFonts.poppins,
    fontWeight: FontWeight.w400,
    fontSize: fontSizeBase,
    height: 1.5,
    color: AppColors.onSurface,
  );

  static const button = TextStyle(
    fontFamily: AppFonts.brandonGrotesque,
    fontWeight: FontWeight.w600,
    fontSize: fontSizeBase,
    letterSpacing: 1.0,
  );

  static const caption = TextStyle(
    fontFamily: AppFonts.poppins,
    fontWeight: FontWeight.w400,
    fontSize: fontSizeDown1,
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
