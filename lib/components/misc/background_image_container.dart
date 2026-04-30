import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const _kBackgroundColor = Color(0xFFF3F3F1);
const _kPatternColor = Color(0xFFEDEEEC);
const _kTabletBreakpoint = 600.0;

class BackgroundImageContainer extends StatelessWidget {
  const BackgroundImageContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isTablet =
        MediaQuery.sizeOf(context).shortestSide >= _kTabletBreakpoint;
    final backgroundAsset = isTablet
        ? 'assets/images/tablet-background.svg'
        : 'assets/images/mobile-background.svg';
    return Container(
      color: _kBackgroundColor,
      child: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              backgroundAsset,
              fit: BoxFit.cover,
              colorFilter: const ColorFilter.mode(
                _kPatternColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
