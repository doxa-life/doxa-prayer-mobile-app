import 'package:flutter/material.dart';

import '../components/prayer_content/prayer_session_view.dart';
import '../l10n/app_localizations.dart';
import '../layouts/page_scaffold.dart';
import '../router.dart';
import '../services/locale_controller.dart';
import '../services/pray_override_controller.dart';
import '../services/selected_people_group_controller.dart';
import '../theme/app_typography.dart';

class PrayScreen extends StatelessWidget {
  const PrayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // A deep-link override (`/<slug>/prayer`) takes precedence over the user's
    // own selection for this visit; it is cleared when they leave the Pray tab.
    return ValueListenableBuilder<PrayOverride?>(
      valueListenable: prayOverrideController,
      builder: (context, override, _) {
        return ValueListenableBuilder<SelectedPeopleGroup?>(
          valueListenable: selectedPeopleGroupController,
          builder: (context, selected, _) {
            final slug = override?.slug ?? selected?.slug;
            if (slug == null) {
              return const PageContainer(child: _NoSelectionView());
            }
            return ValueListenableBuilder<Locale>(
              valueListenable: localeController,
              builder: (context, locale, _) {
                return PrayerSessionView(
                  key: ValueKey('$slug-${locale.languageCode}'),
                  slug: slug,
                  language: locale.languageCode,
                  initialDate: override?.date,
                  isActive: _isOnPrayRoute,
                );
              },
            );
          },
        );
      },
    );
  }

  static bool _isOnPrayRoute() =>
      appRouter.routerDelegate.currentConfiguration.uri.path == '/pray';
}

class _NoSelectionView extends StatelessWidget {
  const _NoSelectionView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Text(
        l10n.noPeopleGroupSelected,
        textAlign: TextAlign.center,
        style: AppTypography.bodyMedium,
      ),
    );
  }
}
