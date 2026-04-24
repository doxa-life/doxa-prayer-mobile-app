import 'package:flutter/material.dart';

class PageContainer extends StatelessWidget {
  const PageContainer({
    super.key,
    required this.child,
    this.maxWidth = 480,
    this.horizontalPadding = 20,
  });

  final Widget child;
  final double maxWidth;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: child,
        ),
      ),
    );
  }
}
