import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../misc/close_icon.dart';
import 'sheet_page.dart';

/// The top of a [SheetPage]: a grab handle and a close button, and a [title]
/// when the content doesn't head itself. Dragged, it moves the sheet, as a
/// drag down on the content does.
class SheetHeader extends StatelessWidget implements PreferredSizeWidget {
  const SheetHeader({super.key, required this.onClose, this.title});

  final VoidCallback onClose;
  final String? title;

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    final sheet = SheetScope.maybeOf(context);
    final title = this.title;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: sheet == null
          ? null
          : (d) => sheet.update(d.primaryDelta ?? 0),
      onVerticalDragEnd: sheet == null
          ? null
          : (d) => sheet.end(d.primaryVelocity ?? 0),
      onVerticalDragCancel: sheet == null ? null : () => sheet.end(0),
      child: ColoredBox(
        color: AppColors.surface,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: ExcludeSemantics(
                  child: Container(
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),
            if (title != null)
              Positioned.fill(
                top: AppSpacing.sm,
                // Clear of the close button on both sides, so the title stays
                // centred.
                left: 48,
                right: 48,
                child: Center(
                  child: Semantics(
                    header: true,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleMedium,
                    ),
                  ),
                ),
              ),
            PositionedDirectional(
              end: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  onPressed: onClose,
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  icon: const CloseIcon(size: 16, color: AppColors.onSurface),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Scroll physics for a sheet's content: clamped, and dragged down from its
/// top it pulls the sheet down after it. Pair it with a
/// [ScrollEndNotification] listener that passes the drag's end to
/// [SheetDrag.end].
class SheetScrollPhysics extends ClampingScrollPhysics with SheetPullPhysics {
  const SheetScrollPhysics({this.sheet, super.parent});

  @override
  final SheetDrag? sheet;

  @override
  SheetScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      SheetScrollPhysics(sheet: sheet, parent: buildParent(ancestor));
}
