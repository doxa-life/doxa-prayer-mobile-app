import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const primary = Color(0xFF3B463D);
  static const onPrimary = Color(0xFFCBC5B9);
  static const secondary = Color(0xFF73A17F);
  static const secondaryLight = Color(0xFF92B195);
  static const onSecondary = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  static const outline = Color(0xFFD6D3CC);
  static const mutedSurface = Color(0xFFF4F2EC);

  static const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    secondary: secondary,
    onSecondary: onSecondary,
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    surface: surface,
    onSurface: onSurface,
    outline: outline,
  );
}

@immutable
class AppColorsExtra extends ThemeExtension<AppColorsExtra> {
  const AppColorsExtra({
    required this.link,
    required this.mutedSurface,
    required this.onPrimarySelected,
  });

  final Color link;
  final Color mutedSurface;
  final Color onPrimarySelected;

  static const light = AppColorsExtra(
    link: AppColors.secondary,
    mutedSurface: AppColors.mutedSurface,
    onPrimarySelected: AppColors.white,
  );

  @override
  AppColorsExtra copyWith({
    Color? link,
    Color? mutedSurface,
    Color? onPrimarySelected,
  }) => AppColorsExtra(
    link: link ?? this.link,
    mutedSurface: mutedSurface ?? this.mutedSurface,
    onPrimarySelected: onPrimarySelected ?? this.onPrimarySelected,
  );

  @override
  AppColorsExtra lerp(ThemeExtension<AppColorsExtra>? other, double t) {
    if (other is! AppColorsExtra) return this;
    return AppColorsExtra(
      link: Color.lerp(link, other.link, t)!,
      mutedSurface: Color.lerp(mutedSurface, other.mutedSurface, t)!,
      onPrimarySelected: Color.lerp(
        onPrimarySelected,
        other.onPrimarySelected,
        t,
      )!,
    );
  }
}
