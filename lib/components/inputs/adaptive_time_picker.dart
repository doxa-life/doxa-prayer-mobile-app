import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Shows a time picker that matches the host platform: the native-style
/// Cupertino wheel presented in a bottom sheet on iOS, and Flutter's Material
/// dial dialog everywhere else.
///
/// Returns the picked [TimeOfDay], or `null` if the user dismissed the picker.
Future<TimeOfDay?> showAdaptiveTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: AppColors.surface,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CupertinoTimePickerSheet(initialTime: initialTime),
    );
  }
  return showTimePicker(context: context, initialTime: initialTime);
}

class _CupertinoTimePickerSheet extends StatefulWidget {
  const _CupertinoTimePickerSheet({required this.initialTime});

  final TimeOfDay initialTime;

  @override
  State<_CupertinoTimePickerSheet> createState() =>
      _CupertinoTimePickerSheetState();
}

class _CupertinoTimePickerSheetState extends State<_CupertinoTimePickerSheet> {
  late TimeOfDay _selected = widget.initialTime;

  @override
  Widget build(BuildContext context) {
    final l = MaterialLocalizations.of(context);
    final now = DateTime.now();
    final initial = DateTime(
      now.year,
      now.month,
      now.day,
      widget.initialTime.hour,
      widget.initialTime.minute,
    );
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    l.cancelButtonLabel,
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.primaryLight),
                  ),
                ),
                CupertinoButton(
                  onPressed: () => Navigator.of(context).pop(_selected),
                  child: Text(
                    l.okButtonLabel,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 216,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime: initial,
              use24hFormat: MediaQuery.of(context).alwaysUse24HourFormat,
              onDateTimeChanged: (dt) =>
                  _selected = TimeOfDay(hour: dt.hour, minute: dt.minute),
            ),
          ),
        ],
      ),
    );
  }
}
