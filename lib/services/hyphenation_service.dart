/// Language-aware line breaking with visible hyphens.
///
/// Flutter has no automatic hyphenation: when a single word is wider than the
/// line it is broken at an arbitrary character with no marker, which is what
/// large accessibility font scales and display zoom produce. Soft hyphens
/// (U+00AD) do not help — the engine honours them as break opportunities but
/// never draws a hyphen at the break.
///
/// So the line breaking is done here instead: [hyphenateForWidth] measures with
/// a [TextPainter] and returns the text with real hyphens and newlines baked in,
/// which a plain [Text] then renders. Only paragraphs containing a word too wide
/// for the line are rewritten — everything else is returned untouched so
/// Flutter's own wrapping still applies.
///
/// [hyphenatorx] supplies the language intelligence (TeX hyphenation patterns);
/// its own `wrap()` is not used because it breaks each word at most once and
/// does not verify the remainder fits.
library;

import 'dart:collection';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:hyphenatorx/hyphenatorx.dart';
import 'package:hyphenatorx/languages/languageconfig.dart';

/// hyphenatorx [Language] per app language code.
///
/// Languages absent from this map are never hyphenated. `ar`, `hi` and `zh` are
/// deliberately missing: none of Arabic, Devanagari or Han script has a
/// hyphenation convention — Chinese already wraps between characters — and
/// inserting hyphens would be wrong rather than merely ugly.
const Map<String, Language> _languageByCode = <String, Language>{
  'en': Language.language_en_us,
  'es': Language.language_es,
  'fr': Language.language_fr,
  'pt': Language.language_pt,
  'ru': Language.language_ru,
  'de': Language.language_de_1996,
  'it': Language.language_it,
  'ro': Language.language_ro,
};

/// The character drawn at a break. ASCII rather than U+2010 so it is present in
/// every bundled font (BebasKai, Poppins, BrandonGrotesque).
const String _hyphen = '-';

/// The zero-width marker hyphenatorx inserts between syllables.
const String _syllableMarker = '­';

final Map<String, Hyphenator> _hyphenators = <String, Hyphenator>{};
final Set<String> _loading = <String>{};

/// Loads the hyphenation patterns for [locale], if it has any.
///
/// Building a [Hyphenator] parses and sorts a few thousand patterns (165–280ms
/// in debug), so this is awaited during startup and on locale change rather
/// than reached lazily from a layout pass.
Future<void> preloadHyphenator(Locale locale) async {
  final code = locale.languageCode;
  final language = _languageByCode[code];
  if (language == null ||
      _hyphenators.containsKey(code) ||
      _loading.contains(code)) {
    return;
  }
  _loading.add(code);
  try {
    _hyphenators[code] = await Hyphenator.loadAsync(language, hyphen: _hyphen);
  } catch (e) {
    // Missing pattern assets must not take the app down: text simply renders
    // without hyphenation, exactly as it did before.
    developer.log(
      'failed to load hyphenation patterns for $code',
      name: 'hyphenation',
      error: e,
    );
  } finally {
    _loading.remove(code);
  }
}

/// The loaded hyphenator for [locale], or null when the language has no
/// patterns or they have not finished loading.
Hyphenator? hyphenatorFor(Locale locale) => _hyphenators[locale.languageCode];

/// Whether [locale] is a language this app hyphenates at all.
bool localeSupportsHyphenation(Locale locale) =>
    _languageByCode.containsKey(locale.languageCode);

@visibleForTesting
void registerHyphenatorForTest(String languageCode, Hyphenator hyphenator) {
  _hyphenators[languageCode] = hyphenator;
}

@visibleForTesting
void resetHyphenationForTest() {
  _hyphenators.clear();
  _loading.clear();
  _cache.clear();
}

/// Wrapped results, keyed on everything that changes the outcome.
///
/// Insertion-ordered so the oldest entry can be evicted; a hit is re-inserted
/// to keep it warm.
final LinkedHashMap<String, String> _cache = LinkedHashMap<String, String>();
const int _maxCacheEntries = 512;

/// Returns [text] with hyphens and newlines inserted so that no word exceeds
/// [maxWidth] when rendered in [style], or [text] unchanged when nothing needs
/// breaking.
///
/// [style] must already have the text scale factor applied to its font size —
/// the returned string is rendered by a widget that scales again.
String hyphenateForWidth({
  required String text,
  required TextStyle style,
  required double maxWidth,
  required Hyphenator hyphenator,
  required String localeCode,
  TextDirection textDirection = TextDirection.ltr,
}) {
  if (text.isEmpty || maxWidth <= 0 || !maxWidth.isFinite) return text;

  final key =
      '$localeCode|${maxWidth.floor()}|${style.fontSize}'
      '|${style.fontFamily}|${style.fontWeight}|${style.letterSpacing}|$text';
  final cached = _cache.remove(key);
  if (cached != null) {
    _cache[key] = cached;
    return cached;
  }

  final measurer = _Measurer(style, textDirection);
  final result = text
      .split('\n')
      .map((p) => _wrapParagraph(p, maxWidth, measurer, hyphenator))
      .join('\n');

  if (_cache.length >= _maxCacheEntries) _cache.remove(_cache.keys.first);
  _cache[key] = result;
  return result;
}

/// Greedily lays out one paragraph, hyphenating words that do not fit.
///
/// Returns [paragraph] untouched unless some word is individually wider than
/// [maxWidth] — Flutter's own greedy space-breaking handles everything else,
/// and leaving it alone means this cannot change wrapping that already worked.
String _wrapParagraph(
  String paragraph,
  double maxWidth,
  _Measurer measurer,
  Hyphenator hyphenator,
) {
  if (paragraph.isEmpty) return paragraph;
  if (measurer.width(paragraph) <= maxWidth) return paragraph;

  final words = paragraph.split(' ');
  if (!words.any((w) => w.isNotEmpty && measurer.width(w) > maxWidth)) {
    return paragraph;
  }

  final lines = <String>[];
  var line = '';
  for (final word in words) {
    final candidate = line.isEmpty ? word : '$line $word';
    if (measurer.width(candidate) <= maxWidth) {
      line = candidate;
      continue;
    }

    // Syllabify once and carry the remaining syllables through: re-running the
    // hyphenator on a tail fragment yields different, worse break points than
    // the whole word does.
    var parts = _syllables(hyphenator, word);

    if (line.isNotEmpty) {
      // Try to fill the rest of the current line with a hyphenated head.
      final fit = _fitCount(parts, '$line ', maxWidth, measurer);
      if (fit > 0) {
        lines.add('$line ${parts.take(fit).join()}$_hyphen');
        parts = parts.sublist(fit);
      } else {
        lines.add(line);
      }
      line = '';
    }

    // Whatever is left starts on a fresh line, split as many times as needed.
    while (parts.length > 1 && measurer.width(parts.join()) > maxWidth) {
      final fit = _fitCount(parts, '', maxWidth, measurer);
      // No break point fits (a long unhyphenatable token, or a first syllable
      // wider than the line): leave it for Flutter to break mid-character, as
      // it did before this existed.
      if (fit == 0) break;
      lines.add('${parts.take(fit).join()}$_hyphen');
      parts = parts.sublist(fit);
    }
    line = parts.join();
  }
  if (line.isNotEmpty) lines.add(line);
  return lines.join('\n');
}

/// How many of [parts] fit on the line, hyphen included, after [prefix].
///
/// Always leaves at least one part for the next line, so 0 means no usable
/// break point.
int _fitCount(
  List<String> parts,
  String prefix,
  double maxWidth,
  _Measurer measurer,
) {
  final head = StringBuffer();
  var fit = 0;
  for (var i = 0; i < parts.length - 1; i++) {
    head.write(parts[i]);
    if (measurer.width('$prefix$head$_hyphen') > maxWidth) break;
    fit = i + 1;
  }
  return fit;
}

/// Break candidates for [word].
///
/// `hyphenateText` rather than `syllablesWord` because it copes with leading
/// and trailing punctuation; it returns the word with [_syllableMarker] between
/// syllables, and short words (< 5 letters) unchanged.
List<String> _syllables(Hyphenator hyphenator, String word) =>
    hyphenator.hyphenateText(word).split(_syllableMarker);

/// Measures and remembers substring widths for one wrap pass.
class _Measurer {
  _Measurer(this.style, this.textDirection);

  final TextStyle style;
  final TextDirection textDirection;
  final Map<String, double> _widths = <String, double>{};

  double width(String text) => _widths.putIfAbsent(text, () {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  });
}
