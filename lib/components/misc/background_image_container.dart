import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_colors.dart';

const _kBackgroundColor = Color(0xFFF3F3F1);
const _kPatternColor = AppColors.onPrimary;

/// Strength of the background pattern. 0 = invisible, 1 = full [_kPatternColor].
const _kPatternOpacity = 0.25;
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
              excludeFromSemantics: true,
              colorFilter: ColorFilter.mode(
                _kPatternColor.withValues(alpha: _kPatternOpacity),
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
