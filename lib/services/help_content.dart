import '../l10n/app_localizations.dart';

/// What the Help tab shows: the mission and the FAQ. The glossary it lists
/// comes from `services/glossary.dart`.
///
/// Every piece of text is an ARB string, so all of it is translated the same
/// way as the rest of the app — nothing here is display text itself. To add an
/// FAQ entry:
///
///  1. add its keys to `lib/l10n/app_en.arb` (with `@key` descriptions) and to
///     every other `app_<code>.arb`;
///  2. run `flutter gen-l10n`;
///  3. add a line to [helpFaq] below pointing at the new keys.
///
/// Adding a glossary term is described in `services/glossary.dart`.
///
/// Order here is the order on screen.

/// One question and its answer.
class HelpFaqEntry {
  const HelpFaqEntry({required this.question, required this.answer});

  final String Function(AppLocalizations l) question;
  final String Function(AppLocalizations l) answer;
}

String helpMission(AppLocalizations l) => l.helpMissionBody;

final List<HelpFaqEntry> helpFaq = [
  HelpFaqEntry(
    question: (l) => l.helpFaqUnengagedQuestion,
    answer: (l) => l.helpFaqUnengagedAnswer,
  ),
  HelpFaqEntry(
    question: (l) => l.helpFaqEngagedQuestion,
    answer: (l) => l.helpFaqEngagedAnswer,
  ),
];
