import 'package:flutter/foundation.dart';

import '../router.dart';

/// A one-visit override for the Pray tab: the people group (and optional date)
/// a user deep-linked into via `/<slug>/prayer`, shown *instead of* their own
/// [selectedPeopleGroupController] selection without persisting anything.
///
/// In-memory only — it is intentionally not written to SharedPreferences, so it
/// evaporates on restart and never replaces the user's real selection.
@immutable
class PrayOverride {
  const PrayOverride(this.slug, [this.date]);

  final String slug;
  final DateTime? date;
}

final ValueNotifier<PrayOverride?> prayOverrideController =
    ValueNotifier<PrayOverride?>(null);

void setPrayOverride(String slug, [DateTime? date]) {
  prayOverrideController.value = PrayOverride(slug, date);
}

void clearPrayOverride() {
  if (prayOverrideController.value != null) {
    prayOverrideController.value = null;
  }
}

/// Clears the override the moment the user leaves the Pray tab, so returning to
/// it shows their own selected group again. Wired once from `main()`.
void attachPrayOverrideAutoClear() {
  appRouter.routerDelegate.addListener(() {
    final path = appRouter.routerDelegate.currentConfiguration.uri.path;
    if (path != '/pray') clearPrayOverride();
  });
}
