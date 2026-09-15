import 'package:flutter/painting.dart';

import '../models/prayer_commitment.dart';
import 'app_colors.dart';

/// The colour each prayer-commitment level is drawn in.
///
/// The same three colours the details page's engagement ticks use, so a group
/// that reads red on the map reads red on its profile. Kept here rather than on
/// the model so the domain stays free of painting.
extension PrayerCommitmentColor on PrayerCommitmentLevel {
  Color get color => switch (this) {
    PrayerCommitmentLevel.met => AppColors.secondary,
    PrayerCommitmentLevel.some => AppColors.partial,
    PrayerCommitmentLevel.none => AppColors.scheme.error,
  };
}
