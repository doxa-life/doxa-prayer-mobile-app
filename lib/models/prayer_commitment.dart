/// How many people committing to pray for a group counts as fully covered.
///
/// Shared by the people-group details page's prayer-status tick and the map's
/// pins, so the two can never disagree about what a colour means.
const int kPeopleCommittedGoal = 100;

/// How well covered a people group is by people committed to praying for it.
enum PrayerCommitmentLevel {
  /// Nobody has committed to pray for this group.
  none,

  /// Someone is praying, but fewer than [kPeopleCommittedGoal].
  some,

  /// [kPeopleCommittedGoal] or more people have committed.
  met,
}

PrayerCommitmentLevel prayerCommitmentLevelFor(int peopleCommitted) {
  if (peopleCommitted >= kPeopleCommittedGoal) return PrayerCommitmentLevel.met;
  if (peopleCommitted > 0) return PrayerCommitmentLevel.some;
  return PrayerCommitmentLevel.none;
}
