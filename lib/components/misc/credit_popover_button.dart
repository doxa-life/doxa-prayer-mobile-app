import 'package:doxa_prayer_mobile_app/models/people_group_detail.dart';
import 'package:doxa_prayer_mobile_app/theme/app_colors.dart';
import 'package:doxa_prayer_mobile_app/theme/app_spacing.dart';
import 'package:doxa_prayer_mobile_app/theme/app_typography.dart';
import 'package:flutter/material.dart';

class CreditPopoverButton extends StatefulWidget {
  const CreditPopoverButton({super.key, required this.credit});

  final List<PictureCreditSegment> credit;

  @override
  State<CreditPopoverButton> createState() => _CreditPopoverButtonState();
}

class _CreditPopoverButtonState extends State<CreditPopoverButton> {
  final MenuController _controller = MenuController();

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[
      for (final part in widget.credit)
        if (part.link != null && part.link!.isNotEmpty)
          TextSpan(
            text: part.text,
            style: const TextStyle(
              color: AppColors.secondary,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.secondary,
            ),
          )
        else
          TextSpan(text: part.text),
    ];

    return MenuAnchor(
      controller: _controller,
      alignmentOffset: const Offset(0, 6),
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.surface),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
      ),
      menuChildren: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 240),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text.rich(
              TextSpan(
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.75),
                ),
                children: spans,
              ),
            ),
          ),
        ),
      ],
      builder: (context, controller, _) {
        return Material(
          color: AppColors.black.withValues(alpha: 0.45),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () =>
                controller.isOpen ? controller.close() : controller.open(),
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.sm),
              child: Icon(
                Icons.info_outline,
                size: AppTypography.lg,
                color: AppColors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
