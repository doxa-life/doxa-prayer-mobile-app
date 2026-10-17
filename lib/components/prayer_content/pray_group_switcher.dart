import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../services/cache_warmup.dart';
import '../../services/locale_controller.dart';
import '../../services/prayer_history_service.dart';
import '../../services/subscribed_people_groups_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../misc/app_image.dart';
import '../misc/prayed_today_pill.dart';

/// Switches the Pray tab between the people groups the user prays for, the
/// way the home screen's carousel does: one compact card per group, swiped
/// through one at a time, the one in focus centred with its neighbours peeking
/// in at the sides — no arrows or dots; the peeking neighbours are the only
/// cue that there is more to swipe to. Settling on a card makes its group the active one, which the tab then
/// shows. A group already prayed for today carries a check.
///
/// Nothing at all below two groups: there is nothing to switch to.
class PrayGroupSwitcher extends StatelessWidget {
  const PrayGroupSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SubscribedPeopleGroups>(
      valueListenable: peopleGroupsController,
      builder: (context, groups, _) {
        if (groups.list.length < 2) return const SizedBox.shrink();
        return ValueListenableBuilder<Set<String>>(
          valueListenable: prayedTodayController,
          builder: (context, prayed, _) => _Switcher(
            groups: groups.list,
            activeSlug: groups.activeSlug,
            prayed: prayed,
          ),
        );
      },
    );
  }
}

class _Switcher extends StatefulWidget {
  const _Switcher({
    required this.groups,
    required this.activeSlug,
    required this.prayed,
  });

  final List<SubscribedPeopleGroup> groups;
  final String? activeSlug;
  final Set<String> prayed;

  @override
  State<_Switcher> createState() => _SwitcherState();
}

class _SwitcherState extends State<_Switcher> {
  /// Each card's share of the row's width; the rest shows its neighbours.
  static const double _cardShare = 0.8;

  static const double _backScale = 0.92;
  static const double _backOpacity = 0.6;

  static const double _avatarSize = 48;

  /// Room above and below the cards for their shadows.
  static const double _gutter = AppSpacing.sm;

  static const Duration _slide = Duration(milliseconds: 280);

  late final PageController _controller = PageController(
    viewportFraction: _cardShare,
    initialPage: _activeIndex.clamp(0, widget.groups.length - 1),
  );

  late int _current = _activeIndex.clamp(0, widget.groups.length - 1);

  /// Set while following a change made elsewhere, so the jump doesn't tick a
  /// haptic the user did nothing here to cause.
  bool _following = false;

  int get _activeIndex =>
      widget.groups.indexWhere((g) => g.slug == widget.activeSlug);

  @override
  void didUpdateWidget(_Switcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The active group changed somewhere else — the home carousel, or a
    // reminder: follow it.
    final index = _activeIndex;
    if (index < 0 || index == _current || !_controller.hasClients) return;
    _current = index;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) return;
      _following = true;
      _controller.jumpToPage(index);
      _following = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) => _controller.animateToPage(
    index,
    duration: _slide,
    curve: Curves.easeOutCubic,
  );

  void _onPageChanged(int index) {
    if (!_following) HapticFeedback.selectionClick();
    setState(() => _current = index);
    // Fires mid-swipe, as the card crosses the middle — a head start on the
    // prayer before the swipe settles and the tab switches to it.
    prefetchPrayer(
      slug: widget.groups[index].slug,
      date: DateTime.now(),
      language: localeController.value.languageCode,
    );
  }

  /// Once a swipe or tap has come to rest, its group becomes the active one.
  bool _onScrollEnd(ScrollEndNotification notification) {
    if (notification.depth != 0) return false;
    final slug = widget.groups[_current].slug;
    if (slug != widget.activeSlug) setActivePeopleGroup(slug);
    return false;
  }

  /// The card's height: the photo, or the name on two lines if taller, with
  /// the card's padding — so a name that wraps never overflows.
  double _cardHeight(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(text: 'Ag\nAg', style: _nameStyle),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final name = painter.height;
    painter.dispose();
    return (name > _avatarSize ? name : _avatarSize) + AppSpacing.md * 2;
  }

  static final TextStyle _nameStyle = AppTypography.bodyMedium.copyWith(
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  @override
  Widget build(BuildContext context) {
    final count = widget.groups.length;
    final height = _cardHeight(context) + _gutter * 2;
    return SizedBox(
      height: height,
      child: NotificationListener<ScrollEndNotification>(
        onNotification: _onScrollEnd,
        child: PageView.builder(
          controller: _controller,
          onPageChanged: _onPageChanged,
          itemCount: count,
          itemBuilder: (context, index) => _page(index),
        ),
      ),
    );
  }

  /// Card [index], drawn smaller and fainter the further it is from the
  /// centre — shrunk toward the card in focus, so its near edge keeps showing.
  Widget _page(int index) {
    final group = widget.groups[index];
    return AnimatedBuilder(
      animation: _controller,
      child: RepaintBoundary(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: _gutter,
          ),
          child: _GroupCard(
            group: group,
            prayedToday: widget.prayed.contains(group.slug),
            nameStyle: _nameStyle,
            avatarSize: _avatarSize,
            onTap: () => _goTo(index),
          ),
        ),
      ),
      builder: (context, child) {
        final ready =
            _controller.hasClients &&
            _controller.position.hasContentDimensions &&
            _controller.position.hasPixels;
        final page = ready
            ? _controller.page ?? _current.toDouble()
            : _current.toDouble();
        final away = (page - index).abs().clamp(0.0, 1.0);
        return Opacity(
          opacity: 1 - (1 - _backOpacity) * away,
          child: Transform.scale(
            scale: 1 - (1 - _backScale) * away,
            alignment: index > page
                ? AlignmentDirectional.centerStart
                : AlignmentDirectional.centerEnd,
            child: child,
          ),
        );
      },
    );
  }
}

/// One group in the switcher: its photo, its name, and a check once it has
/// been prayed for today.
class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.prayedToday,
    required this.nameStyle,
    required this.avatarSize,
    required this.onTap,
  });

  final SubscribedPeopleGroup group;
  final bool prayedToday;
  final TextStyle nameStyle;
  final double avatarSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      label: prayedToday
          ? '${l.switchToPeopleGroup(group.name)}, ${l.prayedToday}'
          : l.switchToPeopleGroup(group.name),
      child: ExcludeSemantics(
        child: Material(
          color: AppColors.surface,
          elevation: 3,
          shadowColor: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                spacing: AppSpacing.md,
                children: [
                  ClipOval(
                    child: AppImage(
                      url: group.imageUrl,
                      size: avatarSize,
                      radius: 0,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      group.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: nameStyle,
                    ),
                  ),
                  if (prayedToday)
                    PrayedTodayPill(label: l.prayedToday, compact: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
