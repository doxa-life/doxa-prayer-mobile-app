import 'package:flutter/material.dart';

import '../../theme/app_typography.dart';

class H1 extends StatelessWidget {
  const H1(this.text, {super.key, this.textAlign, this.color});
  final String text;
  final TextAlign? textAlign;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = color != null
        ? AppTypography.h1.copyWith(color: color)
        : AppTypography.h1;
    return Text(text, style: style, textAlign: textAlign);
  }
}

class H2 extends StatelessWidget {
  const H2(this.text, {super.key, this.textAlign});
  final String text;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTypography.h2, textAlign: textAlign);
}
