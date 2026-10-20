import 'package:flutter/widgets.dart';

import '../l10n/glossary_index.g.dart';

/// The glossary, and where its terms appear in the app's own strings.
///
/// None of it is worked out at run time. `tool/gen_glossary.dart` reads the
/// ARB files when they change and writes `lib/l10n/glossary_index.g.dart`:
/// every term in every language, and for every string that mentions one,
/// exactly where. Showing a string's links is a map lookup by its text.
///
/// To add a term, add `glossary<Name>`, `glossary<Name>Definition` and
/// (optionally) `glossary<Name>Alternates` to every ARB file, then run
/// `flutter gen-l10n` and `dart run tool/gen_glossary.dart`. Every app string
/// that uses the term links to it from then on, with no other change.

/// One glossary term as it reads in one language.
@immutable
class GlossaryTerm {
  const GlossaryTerm({
    required this.id,
    required this.term,
    required this.definition,
  });

  /// A stable, untranslated name for the term ("people-group"), the same in
  /// every language. Never reuse or rename one.
  final String id;
  final String term;
  final String definition;
}

/// Where one term sits in a string: [start] to [end] (UTF-16 offsets, as
/// [String.substring] takes them), and which term it is.
@immutable
class GlossarySpan {
  const GlossarySpan(this.start, this.end, this.termId);

  final int start;
  final int end;
  final String termId;
}

String _language(BuildContext context) =>
    Localizations.localeOf(context).languageCode;

/// Whether glossary terms in the app's sentences are tappable. Off for now:
/// not shipping yet. The generator and its test keep the index current so this can simply be
/// switched back on.
const bool glossaryLinksEnabled = false;

/// The terms in [text], when it is one of the app's strings that mentions
/// any; null otherwise — including for text from the server, which the
/// generator never saw, and always while [glossaryLinksEnabled] is off.
List<GlossarySpan>? glossarySpansOf(BuildContext context, String text) {
  if (!glossaryLinksEnabled) return null;
  return glossarySpans[_language(context)]?[text];
}

/// The term with [id] in the app's language.
GlossaryTerm? glossaryTermOf(BuildContext context, String id) =>
    glossaryTerms[_language(context)]?[id];
