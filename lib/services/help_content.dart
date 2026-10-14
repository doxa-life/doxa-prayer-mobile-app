import '../l10n/app_localizations.dart';

/// What the Help tab shows: the mission, the FAQ and the glossary.
///
/// Every piece of text is an ARB string, so all of it is translated the same
/// way as the rest of the app — nothing here is display text itself. To add an
/// FAQ entry or a glossary term:
///
///  1. add its keys to `lib/l10n/app_en.arb` (with `@key` descriptions) and to
///     every other `app_<code>.arb`;
///  2. run `flutter gen-l10n`;
///  3. add a line to [helpFaq] or [glossary] below pointing at the new keys.
///
/// Order here is the order on screen.

/// One question and its answer.
class HelpFaqEntry {
  const HelpFaqEntry({required this.question, required this.answer});

  final String Function(AppLocalizations l) question;
  final String Function(AppLocalizations l) answer;
}

/// One glossary term.
///
/// [id] is the term's tag: a stable, untranslated name for it, so code (and
/// analytics, or a deep link later) can refer to "the term for unengaged"
/// whatever language the app is in. Never reuse or rename one.
///
/// [alternates] lists any other wordings that should also link to this term
/// wherever glossary-aware text shows them — plurals, inflected forms, an
/// abbreviation — separated by `|`. It is per language because the wordings
/// are; leave it empty when the term itself is the only form.
class GlossaryEntry {
  const GlossaryEntry({
    required this.id,
    required this.term,
    required this.definition,
    required this.alternates,
  });

  final String id;
  final String Function(AppLocalizations l) term;
  final String Function(AppLocalizations l) definition;
  final String Function(AppLocalizations l) alternates;
}

String helpMission(AppLocalizations l) => l.helpMissionBody;

final List<HelpFaqEntry> helpFaq = [
  HelpFaqEntry(
    question: (l) => l.helpFaq1Question,
    answer: (l) => l.helpFaq1Answer,
  ),
  HelpFaqEntry(
    question: (l) => l.helpFaq2Question,
    answer: (l) => l.helpFaq2Answer,
  ),
  HelpFaqEntry(
    question: (l) => l.helpFaq3Question,
    answer: (l) => l.helpFaq3Answer,
  ),
];

final List<GlossaryEntry> glossary = [
  GlossaryEntry(
    id: 'term1',
    term: (l) => l.glossaryTerm1,
    definition: (l) => l.glossaryTerm1Definition,
    alternates: (l) => l.glossaryTerm1Alternates,
  ),
  GlossaryEntry(
    id: 'term2',
    term: (l) => l.glossaryTerm2,
    definition: (l) => l.glossaryTerm2Definition,
    alternates: (l) => l.glossaryTerm2Alternates,
  ),
  GlossaryEntry(
    id: 'term3',
    term: (l) => l.glossaryTerm3,
    definition: (l) => l.glossaryTerm3Definition,
    alternates: (l) => l.glossaryTerm3Alternates,
  ),
];
