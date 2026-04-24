import 'package:doxa_prayer_mobile_app/components/misc/close_icon.dart';
import 'package:doxa_prayer_mobile_app/components/misc/plus_icon.dart';
import 'package:doxa_prayer_mobile_app/components/misc/triangle_icon.dart';
import 'package:doxa_prayer_mobile_app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

import '../components/buttons/action_button.dart';
import '../components/buttons/arrow_button.dart';
import '../components/buttons/button_link.dart';
import '../components/buttons/cta_button.dart';
import '../components/buttons/icon_label_button.dart';
import '../components/cards/elevated_card.dart';
import '../components/cards/flat_card.dart';
import '../components/cards/people_group_card.dart';
import '../components/cards/reminder_card.dart';
import '../components/inputs/checkbox_field.dart';
import '../components/inputs/search_field.dart';
import '../components/inputs/select_field.dart';
import '../components/inputs/text_field.dart';
import '../components/inputs/time_field.dart';
import '../components/inputs/toggle_field.dart';
import '../components/misc/app_icon.dart';
import '../components/misc/app_image.dart';
import '../components/misc/icon_set.dart';
import '../components/misc/progress_dots.dart';
import '../components/misc/titles.dart';
import '../components/nav/bottom_nav_bar.dart';
import '../components/nav/top_nav_bar.dart';
import '../layouts/page_scaffold.dart';
import '../layouts/section.dart';
import '../layouts/spacing.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool _checkbox1 = true;
  bool _checkbox2 = false;
  bool _toggle1 = true;
  bool _toggle2 = false;
  bool _reminderOn = true;
  String? _selectValue = 'en';
  TimeOfDay? _time = const TimeOfDay(hour: 7, minute: 30);
  int _bottomNavIndex = 0;
  int _progressIndex = 1;
  late final TextEditingController _searchController;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavBar(title: 'Component Gallery', onSettings: () {}),
      body: SafeArea(
        child: ListView(
          children: [
            PageContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap.l,
                  const H1('Component Gallery'),
                  Gap.xs,
                  Text(
                    'Phase 2 kitchen sink — every component + layout primitive for review.',
                    style: AppTypography.bodyMedium,
                  ),
                  _colorSection(),
                  _typographySection(),
                  _titlesSection(),
                  _topNavSection(),
                  _bottomNavSection(),
                  _actionButtonSection(),
                  _ctaSection(),
                  _iconLabelSection(),
                  _arrowSection(),
                  _linkSection(),
                  _cardsSection(),
                  _inputsSection(),
                  _progressDotsSection(),
                  _iconsSection(),
                  _imageSection(),
                  _layoutsSection(),
                  Gap.xl,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _swatch(String name, Color color, {Color? onColor}) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: AppTypography.caption.copyWith(
              color: onColor ?? AppColors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
            style: AppTypography.caption.copyWith(
              color: onColor ?? AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorSection() => Section(
    title: 'Colours',
    child: Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _swatch('primary', AppColors.primary, onColor: AppColors.onPrimary),
        _swatch(
          'secondary',
          AppColors.secondary,
          onColor: AppColors.onSecondary,
        ),
        _swatch('surface', AppColors.surface),
        _swatch('muted', AppColors.mutedSurface),
        _swatch('outline', AppColors.outline),
      ],
    ),
  );

  Widget _typographySection() => Section(
    title: 'Typography',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('displayLarge / h1 — BebasKai +2', style: AppTypography.h1),
        Gap.xs,
        Text('displayMedium / h2 — BebasKai +1', style: AppTypography.h2),
        Gap.xs,
        Text(
          'titleMedium — Poppins 500 / base',
          style: AppTypography.titleMedium,
        ),
        Gap.xs,
        Text('bodyLarge — Poppins 400 / base', style: AppTypography.bodyLarge),
        Gap.xs,
        Text('bodyMedium — Poppins 400 / -1', style: AppTypography.bodyMedium),
        Gap.xs,
        Text(
          'LABELLARGE — BRANDON GROTESQUE 600 / base',
          style: AppTypography.button,
        ),
        Gap.xs,
        Text('caption — Poppins 400 / -2', style: AppTypography.caption),
      ],
    ),
  );

  Widget _titlesSection() => const Section(
    title: 'Titles',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [H1('Pray for the Avar'), Gap.s, H2('Today’s prayer')],
    ),
  );

  Widget _topNavSection() => Section(
    title: 'Top nav bar',
    description: 'Centred title + right-aligned settings cog. Back variant.',
    child: Column(
      children: [
        _framed(
          SizedBox(
            height: kToolbarHeight,
            child: TopNavBar(title: 'DOXA', onSettings: () {}),
          ),
        ),
        Gap.s,
        _framed(
          SizedBox(
            height: kToolbarHeight,
            child: TopNavBar(title: 'People Group', onBack: () {}),
          ),
        ),
      ],
    ),
  );

  Widget _bottomNavSection() => Section(
    title: 'Bottom nav bar',
    child: _framed(
      BottomNavBar(
        items: const [
          BottomNavItemData(
            icon: AppIconName.home,
            selectedIcon: AppIconName.homeSolid,
            label: 'Home',
          ),
          BottomNavItemData(
            icon: AppIconName.pray,
            selectedIcon: AppIconName.praySolid,
            label: 'Pray',
          ),
          BottomNavItemData(icon: AppIconName.person, label: 'People Groups'),
          BottomNavItemData(
            icon: AppIconName.bell,
            selectedIcon: AppIconName.bellSolid,
            label: 'Reminders',
          ),
        ],
        currentIndex: _bottomNavIndex,
        onTap: (i) => setState(() => _bottomNavIndex = i),
      ),
    ),
  );

  Widget _actionButtonSection() => Section(
    title: 'Action buttons',
    description: 'Label, icon + label, icon-only, full-width variants.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ActionButton(
              label: 'Pray',
              onPressed: () {},
              color: ActionButtonColor.secondary,
            ),
            ActionButton(label: 'Remove', onPressed: () {}),
            ActionButton(
              label: 'Back',
              onPressed: () {},
              color: ActionButtonColor.white,
              isOutlined: true,
            ),
            ActionButton.iconLabel(
              label: 'Share',
              icon: const AppIcon(AppIconName.share),
              onPressed: () {},
            ),
            ActionButton.icon(
              icon: PlusIcon(color: AppColors.white),
              onPressed: () {},
            ),
            const ActionButton(label: 'Disabled', onPressed: null),
          ],
        ),
        Gap.m,
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outline),
          ),
          width: double.infinity,
          child: Row(
            spacing: AppSpacing.xxl,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ActionButton(
                label: 'Yes',
                onPressed: () {},
                color: ActionButtonColor.secondary,
                isOutlined: true,
              ),
              ActionButton(
                label: 'No',
                onPressed: () {},
                color: ActionButtonColor.white,
              ),
            ],
          ),
        ),
        Gap.m,
        ActionButton.fullWidth(
          label: 'Continue',
          icon: const TriangleIcon(direction: TriangleDirection.right),
          onPressed: () {},
        ),
      ],
    ),
  );

  Widget _ctaSection() => Section(
    title: 'CTA button',
    child: CtaButton(
      label: 'Set reminder',
      leadingIcon: const AppIcon(AppIconName.bell),
      onPressed: () {},
    ),
  );

  Widget _iconLabelSection() => Section(
    title: 'Icon + label buttons (off-navbar)',
    child: Wrap(
      spacing: 24,
      runSpacing: 16,
      children: [
        IconLabelButton(
          icon: const AppIcon(AppIconName.person),
          label: 'Profile',
          onPressed: () {},
        ),
        IconLabelButton(
          icon: const AppIcon(AppIconName.share),
          label: 'Share',
          onPressed: () {},
        ),
        IconLabelButton(
          icon: const AppIcon(AppIconName.trash),
          label: 'Remove',
          onPressed: () {},
        ),
      ],
    ),
  );

  Widget _arrowSection() => Section(
    title: 'Arrow buttons',
    child: Row(
      children: [
        ArrowButton(direction: ArrowDirection.back, onPressed: () {}),
        Gap.mH,
        ArrowButton(direction: ArrowDirection.forward, onPressed: () {}),
      ],
    ),
  );

  Widget _linkSection() => Section(
    title: 'Button link',
    child: Row(
      children: [ButtonLink(label: 'Sign up for updates', onPressed: () {})],
    ),
  );

  Widget _cardsSection() => Section(
    title: 'Cards',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedAppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const H2('Elevated card'),
              Gap.s,
              Text(
                'Used for primary content surfaces (e.g. home people-group card).',
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
        ),
        Gap.m,
        FlatCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const H2('Flat card'),
              Gap.s,
              Text(
                'Used for secondary groupings (e.g. reminder cards).',
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
        ),
        Gap.m,
        ReminderCard(
          time: '07:30 AM',
          daysSummary: 'Mon, Wed, Fri',
          enabled: _reminderOn,
          onToggle: (v) => setState(() => _reminderOn = v),
        ),
        Gap.m,
        PeopleGroupCard(
          name: 'The Avar',
          imageUrl: null,
          onPray: () {},
          onDetails: () {},
        ),
      ],
    ),
  );

  Widget _inputsSection() => Section(
    title: 'Inputs',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Name',
          hint: 'Your name',
          controller: _textController,
        ),
        Gap.m,
        const AppTextField(
          label: 'Email',
          hint: 'you@example.com',
          errorText: 'Please enter a valid email',
        ),
        Gap.m,
        SearchField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          onClear: () => setState(() => _searchController.clear()),
        ),
        Gap.m,
        TimeField(
          label: 'Reminder time',
          value: _time,
          onChanged: (v) => setState(() => _time = v),
        ),
        Gap.m,
        SelectField<String>(
          label: 'Language',
          value: _selectValue,
          items: const [
            DropdownMenuItem(value: 'en', child: Text('English')),
            DropdownMenuItem(value: 'es', child: Text('Español')),
            DropdownMenuItem(value: 'fr', child: Text('Français')),
          ],
          onChanged: (v) => setState(() => _selectValue = v),
        ),
        Gap.m,
        CheckboxField(
          label: 'Receive updates about this people group',
          value: _checkbox1,
          onChanged: (v) => setState(() => _checkbox1 = v),
        ),
        CheckboxField(
          label: 'Receive updates from Doxa',
          value: _checkbox2,
          onChanged: (v) => setState(() => _checkbox2 = v),
        ),
        Gap.m,
        ToggleField(
          label: 'Reminder enabled',
          subtitle: 'Sends a local notification at the set time',
          value: _toggle1,
          onChanged: (v) => setState(() => _toggle1 = v),
        ),
        ToggleField(
          label: 'Dark mode (future)',
          value: _toggle2,
          onChanged: (v) => setState(() => _toggle2 = v),
        ),
      ],
    ),
  );

  Widget _progressDotsSection() => Section(
    title: 'Progress dots (wizard)',
    child: Row(
      children: [
        ProgressDots(count: 4, currentIndex: _progressIndex),
        Gap.lH,
        TextButton(
          onPressed: () =>
              setState(() => _progressIndex = (_progressIndex + 1) % 4),
          child: const Text('NEXT'),
        ),
      ],
    ),
  );

  Widget _iconsSection() => const Section(title: 'Icons', child: IconSet());

  Widget _imageSection() => const Section(
    title: 'Image',
    child: AppImage(url: null, aspectRatio: 16 / 9),
  );

  Widget _layoutsSection() => Section(
    title: 'Layouts',
    description:
        'Spacing, pushed-apart, centred, grouped buttons, container width.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _layoutLabel('Vertical spacing'),
        _framed(
          Column(
            children: [
              _dashedBox('A'),
              Gap.m,
              _dashedBox('B'),
              Gap.m,
              _dashedBox('C'),
            ],
          ),
        ),
        Gap.m,
        _layoutLabel('Horizontal spacing'),
        _framed(
          Row(
            children: [
              _dashedBox('A'),
              Gap.mH,
              _dashedBox('B'),
              Gap.mH,
              _dashedBox('C'),
            ],
          ),
        ),
        Gap.m,
        _layoutLabel('Pushed apart (spaceBetween)'),
        _framed(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_dashedBox('A'), _dashedBox('B')],
          ),
        ),
        Gap.m,
        _layoutLabel('Centre aligned'),
        _framed(Center(child: _dashedBox('centred'))),
        Gap.m,
        _layoutLabel('Vertically grouped buttons'),
        _framed(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ActionButton.fullWidth(label: 'Save', onPressed: () {}),
              Gap.s,
              OutlinedButton(onPressed: () {}, child: const Text('SKIP')),
            ],
          ),
        ),
        Gap.m,
        _layoutLabel('Consistent container width (max 480)'),
        _framed(
          Container(
            color: AppColors.mutedSurface,
            padding: const EdgeInsets.all(12),
            child: const Text(
              'Content is capped at a max width so tablet layouts stay readable.',
              style: AppTypography.bodyMedium,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _layoutLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: AppTypography.caption.copyWith(fontWeight: FontWeight.w500),
    ),
  );

  Widget _framed(Widget child) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.outline),
    ),
    child: child,
  );

  Widget _dashedBox(String label) => Container(
    width: 64,
    height: 48,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.mutedSurface,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: AppColors.primary.withValues(alpha: 0.4),
        style: BorderStyle.solid,
      ),
    ),
    child: Text(label, style: AppTypography.caption),
  );
}
