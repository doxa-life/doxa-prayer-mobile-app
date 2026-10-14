import '../l10n/app_localizations.dart';
import 'help_content.dart';

/// A glossary term as it reads in the current language.
class ResolvedGlossaryTerm {
  const ResolvedGlossaryTerm({
    required this.id,
    required this.term,
    required this.definition,
  });

  final String id;
  final String term;
  final String definition;
}

/// One stretch of text: plain, or a glossary term to make tappable.
class GlossarySegment {
  const GlossarySegment(this.text, [this.term]);

  final String text;
  final ResolvedGlossaryTerm? term;
}

/// Languages written without spaces between words. Requiring a word boundary
/// around a term would never match in these, since every neighbour is a letter.
const Set<String> _unspacedLanguages = {'zh', 'ja', 'th', 'lo', 'km', 'my'};

/// Finds glossary terms in running text, for one language.
///
/// Built once per language and reused (see [glossaryMatcherFor]): the pattern
/// covers every term and alternate wording, longest first, so "people group"
/// wins over "people" when both are terms.
class GlossaryMatcher {
  GlossaryMatcher._(this._pattern, this._byForm);

  factory GlossaryMatcher(AppLocalizations l) {
    final byForm = <String, ResolvedGlossaryTerm>{};
    for (final entry in glossary) {
      final resolved = ResolvedGlossaryTerm(
        id: entry.id,
        term: entry.term(l),
        definition: entry.definition(l),
      );
      final forms = [
        resolved.term,
        ...entry.alternates(l).split('|'),
      ].map((f) => f.trim()).where((f) => f.isNotEmpty);
      for (final form in forms) {
        // First term to claim a wording keeps it.
        byForm.putIfAbsent(form.toLowerCase(), () => resolved);
      }
    }
    if (byForm.isEmpty) return GlossaryMatcher._(null, byForm);
    final alternation =
        (byForm.keys.toList()..sort((a, b) => b.length.compareTo(a.length)))
            .map(RegExp.escape)
            .join('|');
    final unspaced = _unspacedLanguages.contains(l.localeName.split('_').first);
    final pattern = unspaced
        ? '($alternation)'
        : r'(?<![\p{L}\p{N}])(' + alternation + r')(?![\p{L}\p{N}])';
    return GlossaryMatcher._(
      RegExp(pattern, caseSensitive: false, unicode: true),
      byForm,
    );
  }

  final RegExp? _pattern;
  final Map<String, ResolvedGlossaryTerm> _byForm;

  /// [text] split into plain runs and glossary terms, in order. A single plain
  /// segment when nothing in it is a term.
  List<GlossarySegment> split(String text) {
    final pattern = _pattern;
    if (pattern == null || text.isEmpty) return [GlossarySegment(text)];
    final segments = <GlossarySegment>[];
    var last = 0;
    for (final match in pattern.allMatches(text)) {
      final term = _byForm[match.group(1)!.toLowerCase()];
      if (term == null) continue;
      if (match.start > last) {
        segments.add(GlossarySegment(text.substring(last, match.start)));
      }
      segments.add(GlossarySegment(match.group(1)!, term));
      last = match.end;
    }
    if (last == 0) return [GlossarySegment(text)];
    if (last < text.length) segments.add(GlossarySegment(text.substring(last)));
    return segments;
  }
}

GlossaryMatcher? _cached;
String? _cachedLocale;

/// The matcher for [l]'s language, rebuilt only when the language changes.
GlossaryMatcher glossaryMatcherFor(AppLocalizations l) {
  if (_cached == null || _cachedLocale != l.localeName) {
    _cached = GlossaryMatcher(l);
    _cachedLocale = l.localeName;
  }
  return _cached!;
}
