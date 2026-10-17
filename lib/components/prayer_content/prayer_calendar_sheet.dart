import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../layouts/page_scaffold.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../misc/triangle_icon.dart';
import '../nav/root_pop_scope.dart';
import '../nav/sheet_header.dart';
import '../nav/sheet_page.dart';

/// What the calendar sheet is opened with — passed as the `/calendar` route's
/// `extra`.
@immutable
class PrayerCalendarArgs {
  const PrayerCalendarArgs({
    required this.selected,
    required this.firstDay,
    required this.lastDay,
  });

  /// The day the Pray screen is showing.
  final DateTime selected;

  /// The earliest day with a prayer — the campaign's start.
  final DateTime firstDay;

  /// Today: there are no prayers for days that haven't come yet.
  final DateTime lastDay;
}

/// Picks which day's prayer the Pray screen shows, in place of stepping back
/// one day at a time. Shown in a sheet, like Help and a people group's
/// profile, so it covers the prayer beneath it and is dismissed the same ways:
/// a drag down, the close button, or a tap above it. Pops with the picked day,
/// or with nothing when dismissed.
///
/// Months are swiped through sideways — back in time toward the start of the
/// row, as reading order runs — or stepped with the arrows beside the month.
class PrayerCalendarScreen extends StatefulWidget {
  const PrayerCalendarScreen({super.key, required this.args});

  final PrayerCalendarArgs args;

  @override
  State<PrayerCalendarScreen> createState() => _PrayerCalendarScreenState();
}

class _PrayerCalendarScreenState extends State<PrayerCalendarScreen> {
  late final DateTime _first = DateUtils.dateOnly(widget.args.firstDay);
  late final DateTime _last = DateUtils.dateOnly(widget.args.lastDay);
  late final DateTime _selected = DateUtils.dateOnly(widget.args.selected);

  /// Months from the first day's to today's, inclusive.
  late final int _monthCount = DateUtils.monthDelta(_first, _last) + 1;

  /// Page 0 is today's month; each page further on is a month earlier. The
  /// view is reversed, so the earlier months sit toward the start of the row.
  late final PageController _pages = PageController(
    initialPage: DateUtils.monthDelta(
      _selected,
      _last,
    ).clamp(0, _monthCount - 1),
  );

  late int _page = _pages.initialPage;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  DateTime _monthAt(int page) => DateTime(_last.year, _last.month - page);

  void _step(int by) => _pages.animateToPage(
    _page + by,
    duration: const Duration(milliseconds: 280),
    curve: Curves.easeOutCubic,
  );

  bool _selectable(DateTime day) =>
      !day.isBefore(_first) && !day.isAfter(_last);

  void _pick(DateTime day) {
    HapticFeedback.selectionClick();
    Navigator.of(context).pop(day);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final material = MaterialLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final sheet = SheetScope.maybeOf(context);
    final canGoBack = _page < _monthCount - 1;
    final canGoForward = _page > 0;

    Widget arrow({required bool back}) {
      final enabled = back ? canGoBack : canGoForward;
      final pointsLeft = back != isRtl;
      return IconButton(
        tooltip: back
            ? material.previousMonthTooltip
            : material.nextMonthTooltip,
        onPressed: enabled ? () => _step(back ? 1 : -1) : null,
        icon: TriangleIcon(
          direction: pointsLeft
              ? TriangleDirection.left
              : TriangleDirection.right,
          color: enabled ? AppColors.primary : AppColors.onPrimary,
          size: 12,
        ),
      );
    }

    final content = SingleChildScrollView(
      // Dragged down from its top, it pulls the sheet down to dismiss it.
      physics: SheetScrollPhysics(sheet: sheet),
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewPaddingOf(context).bottom + AppSpacing.lg,
      ),
      child: PageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                arrow(back: true),
                Expanded(
                  child: Text(
                    material.formatMonthYear(_monthAt(_page)),
                    textAlign: TextAlign.center,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                arrow(back: false),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _WeekdayRow(),
            const SizedBox(height: AppSpacing.xs),
            LayoutBuilder(
              builder: (context, box) => SizedBox(
                // Six weeks always fit: a month never spans more.
                height: box.maxWidth / 7 * 6,
                child: PageView.builder(
                  controller: _pages,
                  reverse: true,
                  itemCount: _monthCount,
                  onPageChanged: (page) {
                    HapticFeedback.selectionClick();
                    setState(() => _page = page);
                  },
                  itemBuilder: (context, page) => _MonthGrid(
                    month: _monthAt(page),
                    selected: _selected,
                    today: _last,
                    selectable: _selectable,
                    onPick: _pick,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: TextButton(
                onPressed: () => _pick(_last),
                child: Text(
                  material.currentDateLabel,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: SheetHeader(
        title: l10n.chooseDay,
        onClose: () => safeBack(context),
      ),
      body: sheet == null
          ? content
          : NotificationListener<ScrollEndNotification>(
              // Only the vertical scroll's end settles the sheet; the months'
              // sideways swipes are no drag of the sheet.
              onNotification: (n) {
                if (n.metrics.axis == Axis.vertical) {
                  sheet.end(n.dragDetails?.primaryVelocity ?? 0);
                }
                return false;
              },
              child: content,
            ),
    );
  }
}

/// The weekday initials, starting on the locale's first day of the week.
class _WeekdayRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final material = MaterialLocalizations.of(context);
    final first = material.firstDayOfWeekIndex; // 0 = Sunday
    return ExcludeSemantics(
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Text(
                material.narrowWeekdays[(first + i) % 7],
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One month's days in weeks. The day on show is filled; today is ringed;
/// days without a prayer — before the campaign, or yet to come — are greyed
/// and can't be picked.
class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.today,
    required this.selectable,
    required this.onPick,
  });

  final DateTime month;
  final DateTime selected;
  final DateTime today;
  final bool Function(DateTime day) selectable;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    final material = MaterialLocalizations.of(context);
    final leading =
        (DateTime(month.year, month.month).weekday % 7 -
            material.firstDayOfWeekIndex) %
        7;
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    return GridView.count(
      crossAxisCount: 7,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        for (var i = 0; i < leading; i++) const SizedBox.shrink(),
        for (var d = 1; d <= days; d++)
          _day(context, DateTime(month.year, month.month, d)),
      ],
    );
  }

  Widget _day(BuildContext context, DateTime day) {
    final material = MaterialLocalizations.of(context);
    final enabled = selectable(day);
    final isSelected = DateUtils.isSameDay(day, selected);
    final isToday = DateUtils.isSameDay(day, today);
    return Semantics(
      button: enabled,
      enabled: enabled,
      selected: isSelected,
      label: material.formatFullDate(day),
      excludeSemantics: true,
      // The circle is a square of the cell's shorter side, centred in it, and
      // the number is set with no extra line height: Poppins' tall line box
      // (height 1.5) put the digits' optical middle off the circle's.
      child: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Material(
              color: isSelected ? AppColors.secondary : Colors.transparent,
              shape: CircleBorder(
                side: isToday && !isSelected
                    ? const BorderSide(color: AppColors.secondary, width: 1.5)
                    : BorderSide.none,
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: enabled ? () => onPick(day) : null,
                child: Center(
                  child: Text(
                    material.formatDecimal(day.day),
                    textAlign: TextAlign.center,
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                      leadingDistribution: TextLeadingDistribution.even,
                    ),
                    style: AppTypography.bodyMedium.copyWith(
                      height: 1,
                      leadingDistribution: TextLeadingDistribution.even,
                      color: isSelected
                          ? AppColors.onSecondary
                          : enabled
                          ? AppColors.primary
                          : AppColors.outline,
                      fontWeight: isSelected || isToday
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
