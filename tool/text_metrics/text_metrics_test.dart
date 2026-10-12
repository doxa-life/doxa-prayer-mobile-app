/// Measures every localized string in every language, at several text sizes.
///
/// Run from the project root:
///
///     flutter test tool/text_metrics/text_metrics_test.dart
///
/// It is a `flutter test` file only because that is the way to get Flutter's
/// real text layout (the same engine and bundled fonts the app uses) without a
/// device. Nothing is asserted. Each run writes two files into its own
/// timestamped folder, `build/text_metrics/<YYYY-MM-DD_HHMMSS>/`, so earlier
/// results are kept rather than overwritten:
///
///   * `text_metrics.csv`  one row per string x style x text scale, with the
///                         space it takes up. Open it in a spreadsheet.
///   * `summary.md`        per-language size relative to English, the widest
///                         strings, and how many strings contain a word too
///                         wide for a given width (those break mid-word).
///
/// Columns in the CSV:
///
///   * `single_line_px`  width of the whole string on one line.
///   * `longest_word_px` width of its widest word; a column narrower than this
///                       must break the word.
///   * `lines_<W>` / `height_<W>`  line count and height in logical pixels when
///                       laid out in a column W pixels wide.
///
/// Strings with plurals or selects are expanded to one row per branch, and
/// `{placeholders}` are filled with representative sample values, so the row
/// reflects text the user can actually see. `text` shows what was measured.
///
/// Options, passed as `--dart-define=NAME=value` (comma-separated lists):
///
///   * `SCALES`   text scale factors.    Default `1.0,1.3,2.0`
///   * `WIDTHS`   column widths in px.   Default `150,250,350`
///   * `STYLES`   AppTypography styles.  Default `bodyMedium,bodySmall,caption,button`
///                (also: h1, h2, titleMedium, titleLarge, bodyLarge)
///   * `LOCALES`  language codes.        Default: every `lib/l10n/app_*.arb`
///   * `OUT`      parent directory for the per-run folders.
///                Default `build/text_metrics`
///
/// Which style a given string is shown in is decided at its call site, not in
/// the ARB, so each string is measured in every requested style; read the rows
/// for the style the string actually uses.
library;

import 'dart:convert';
import 'dart:io';

import 'package:doxa_prayer_mobile_app/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _scalesArg = String.fromEnvironment('SCALES', defaultValue: '1.0,1.3,2.0');
const _widthsArg = String.fromEnvironment('WIDTHS', defaultValue: '150,250,350');
const _stylesArg = String.fromEnvironment(
  'STYLES',
  defaultValue: 'bodyMedium,bodySmall,caption,button',
);
const _localesArg = String.fromEnvironment('LOCALES');
const _outArg = String.fromEnvironment('OUT', defaultValue: 'build/text_metrics');

const _rtl = {'ar', 'he', 'fa', 'ur'};

/// Stand-ins for `{placeholders}`, chosen to be on the long side.
String _sampleFor(String name) {
  final n = name.toLowerCase();
  if (n.contains('email')) return 'someone@example.com';
  if (n.contains('name')) return 'Kazakh, Western';
  if (n.contains('version')) return '12.3.4';
  if (n.contains('seconds') || n.contains('count') || n.contains('days')) {
    return '30';
  }
  return 'Sample';
}

/// The number a plural branch stands for, used for `#` and `{count}` in it.
String _pluralSample(String key) {
  if (key.startsWith('=')) return key.substring(1);
  switch (key) {
    case 'zero':
      return '0';
    case 'one':
      return '1';
    case 'two':
      return '2';
    case 'few':
      return '3';
    case 'many':
      return '11';
    default:
      return '1234';
  }
}

int _matchingBrace(String s, int open) {
  var depth = 0;
  for (var i = open; i < s.length; i++) {
    if (s[i] == '{') depth++;
    if (s[i] == '}' && --depth == 0) return i;
  }
  return s.length - 1; // unbalanced; check_arb.py reports these
}

/// Every distinct text an ICU message can show (capped), placeholders filled.
List<String> _expand(String s, [Map<String, String> ctx = const {}]) {
  final open = s.indexOf('{');
  if (open < 0) return [s];
  final close = _matchingBrace(s, open);
  final prefix = s.substring(0, open);
  final rest = s.substring(close + 1);
  final inner = s.substring(open + 1, close);

  final head = <String>[];
  final comma = inner.indexOf(',');
  if (comma < 0) {
    head.add(ctx[inner.trim()] ?? _sampleFor(inner.trim()));
  } else {
    final name = inner.substring(0, comma).trim();
    final afterName = inner.substring(comma + 1);
    final comma2 = afterName.indexOf(',');
    final type = (comma2 < 0 ? afterName : afterName.substring(0, comma2))
        .trim();
    final branches = comma2 < 0 ? '' : afterName.substring(comma2 + 1);
    if (type == 'plural' || type == 'select') {
      var i = 0;
      while (i < branches.length) {
        final b = branches.indexOf('{', i);
        if (b < 0) break;
        final key = branches.substring(i, b).trim();
        final e = _matchingBrace(branches, b);
        var body = branches.substring(b + 1, e);
        final next = {...ctx};
        if (type == 'plural') {
          final n = _pluralSample(key);
          next[name] = n;
          body = body.replaceAll('#', n);
        }
        head.addAll(_expand(body, next));
        i = e + 1;
      }
    } else {
      head.add(ctx[name] ?? _sampleFor(name));
    }
  }

  final tails = _expand(rest, ctx);
  final out = <String>{};
  for (final h in head) {
    for (final t in tails) {
      out.add('$prefix$h$t');
      if (out.length >= 24) return out.toList();
    }
  }
  return out.toList();
}

Map<String, String> _loadStrings(String code) {
  final json =
      jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync())
          as Map<String, dynamic>;
  return {
    for (final e in json.entries)
      if (!e.key.startsWith('@') && e.value is String) e.key: e.value as String,
  };
}

TextStyle _styleNamed(String name, Locale locale) {
  switch (name) {
    case 'h1':
      return AppTypography.h1;
    case 'h2':
      return AppTypography.h2;
    case 'titleMedium':
      return AppTypography.titleMedium;
    case 'titleLarge':
      return AppTypography.titleLarge;
    case 'bodyLarge':
      return AppTypography.bodyLarge;
    case 'bodyMedium':
      return AppTypography.bodyMedium;
    case 'bodySmall':
      return AppTypography.bodySmall;
    case 'caption':
      return AppTypography.caption;
    case 'button':
      return AppTypography.buttonFor(locale);
  }
  throw ArgumentError('Unknown style "$name"');
}

/// `flutter test` draws every glyph with the Ahem test font unless the real
/// ones are loaded, which would make every measurement meaningless.
Future<void> _loadBundledFonts() async {
  final manifest =
      jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final family in manifest) {
    final loader = FontLoader((family as Map)['family'] as String);
    for (final font in family['fonts'] as List) {
      loader.addFont(rootBundle.load((font as Map)['asset'] as String));
    }
    await loader.load();
  }
}

class _Measure {
  _Measure(this.singleLine, this.longestWord, this.byWidth);
  final double singleLine;
  final double longestWord;
  final Map<double, ({int lines, double height})> byWidth;
}

_Measure _measure(
  String text,
  TextStyle style,
  double scale,
  TextDirection dir,
  List<double> widths,
) {
  TextPainter painter() => TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: dir,
    textScaler: TextScaler.linear(scale),
  );

  final p = painter()..layout();
  final single = p.maxIntrinsicWidth;
  final word = p.minIntrinsicWidth;
  p.dispose();

  final byWidth = <double, ({int lines, double height})>{};
  for (final w in widths) {
    final q = painter()..layout(maxWidth: w);
    byWidth[w] = (lines: q.computeLineMetrics().length, height: q.height);
    q.dispose();
  }
  return _Measure(single, word, byWidth);
}

String _csv(String v) => '"${v.replaceAll('"', '""').replaceAll('\n', ' ')}"';
String _px(double v) => v.toStringAsFixed(1);

List<double> _doubles(String s) =>
    s.split(',').map((e) => double.parse(e.trim())).toList();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('measure every localized string', () async {
    await _loadBundledFonts();

    final scales = _doubles(_scalesArg);
    final widths = _doubles(_widthsArg);
    final styleNames = _stylesArg.split(',').map((e) => e.trim()).toList();
    final english = _loadStrings('en');
    final codes = _localesArg.isNotEmpty
        ? _localesArg.split(',').map((e) => e.trim()).toList()
        : (Directory('lib/l10n')
              .listSync()
              .map((f) => RegExp(r'app_(\w+)\.arb$').firstMatch(f.path)?.group(1))
              .whereType<String>()
              .toList()
            ..sort());
    // English first, so the summary can compare everything against it.
    codes
      ..remove('en')
      ..insert(0, 'en');

    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final stamp =
        '${now.year}-${two(now.month)}-${two(now.day)}_'
        '${two(now.hour)}${two(now.minute)}${two(now.second)}';
    final out = Directory('$_outArg/$stamp')..createSync(recursive: true);
    final csv = StringBuffer(
      [
        'locale', 'key', 'variant', 'style', 'scale', 'chars',
        'single_line_px', 'longest_word_px',
        for (final w in widths) ...['lines_${w.round()}', 'height_${w.round()}'],
        'text',
      ].join(','),
    )..writeln();

    // (locale, style, scale) -> single-line widths keyed by "key#variant".
    final widthsBy = <String, Map<String, double>>{};
    // (locale, style, scale, width) -> strings whose longest word is too wide.
    final overflowing = <String, int>{};
    final totals = <String, int>{};
    final widest = <String, List<(double, String, String)>>{};
    final fallbackKeys = <String, List<String>>{};

    for (final code in codes) {
      final locale = Locale(code);
      final dir = _rtl.contains(code) ? TextDirection.rtl : TextDirection.ltr;
      final strings = _loadStrings(code);
      for (final key in english.keys) {
        final raw = strings[key];
        if (raw == null) fallbackKeys.putIfAbsent(code, () => []).add(key);
        final variants = _expand(raw ?? english[key]!);
        for (var v = 0; v < variants.length; v++) {
          final text = variants[v];
          for (final styleName in styleNames) {
            final style = _styleNamed(styleName, locale);
            for (final scale in scales) {
              final m = _measure(text, style, scale, dir, widths);
              csv.writeln(
                [
                  code, key, v, styleName, scale, text.runes.length,
                  _px(m.singleLine), _px(m.longestWord),
                  for (final w in widths) ...[
                    m.byWidth[w]!.lines,
                    _px(m.byWidth[w]!.height),
                  ],
                  _csv(text),
                ].join(','),
              );
              final group = '$code|$styleName|$scale';
              widthsBy.putIfAbsent(group, () => {})['$key#$v'] = m.singleLine;
              totals[group] = (totals[group] ?? 0) + 1;
              for (final w in widths) {
                if (m.longestWord > w) {
                  final k = '$group|${w.round()}';
                  overflowing[k] = (overflowing[k] ?? 0) + 1;
                }
              }
              if (styleName == styleNames.first && scale == scales.first) {
                (widest.putIfAbsent(code, () => [])).add((
                  m.singleLine,
                  key,
                  text,
                ));
              }
            }
          }
        }
      }
    }
    File('${out.path}/text_metrics.csv').writeAsStringSync(csv.toString());

    // ---- summary.md ----
    final md = StringBuffer()
      ..writeln('# Text metrics summary')
      ..writeln()
      ..writeln(
        'Generated by `tool/text_metrics/text_metrics_test.dart` on '
        '${now.year}-${two(now.month)}-${two(now.day)} '
        '${two(now.hour)}:${two(now.minute)}. '
        'Scales: ${scales.join(', ')}. Column widths: ${widths.join(', ')} px. '
        'Styles: ${styleNames.join(', ')}.',
      )
      ..writeln()
      ..writeln('## Width relative to English')
      ..writeln()
      ..writeln(
        'Single-line width of each string divided by the English string with '
        'the same key (style `${styleNames.first}`, scale ${scales.first}). '
        'Above 1.00 means the language needs more room.',
      )
      ..writeln()
      ..writeln('| Language | Mean | Worst | Worst string |')
      ..writeln('|---|---|---|---|');
    final enGroup = 'en|${styleNames.first}|${scales.first}';
    final enWidths = widthsBy[enGroup] ?? const {};
    for (final code in codes) {
      final group = '$code|${styleNames.first}|${scales.first}';
      final mine = widthsBy[group] ?? const {};
      var sum = 0.0, n = 0, worst = 0.0;
      var worstKey = '';
      mine.forEach((k, w) {
        final base = enWidths[k];
        if (base == null || base == 0) return;
        final r = w / base;
        sum += r;
        n++;
        if (r > worst) {
          worst = r;
          worstKey = k;
        }
      });
      md.writeln(
        '| $code | ${n == 0 ? '-' : (sum / n).toStringAsFixed(2)} '
        '| ${worst.toStringAsFixed(2)} | `$worstKey` |',
      );
    }

    md
      ..writeln()
      ..writeln('## Strings with a word wider than the column')
      ..writeln()
      ..writeln(
        'Count of strings whose widest single word does not fit the column, '
        'so it must break mid-word (or be hyphenated). Total strings per '
        'language is shown in brackets.',
      )
      ..writeln();
    for (final styleName in styleNames) {
      md
        ..writeln('### $styleName')
        ..writeln()
        ..writeln(
          '| Language | Scale | ${widths.map((w) => '${w.round()} px').join(' | ')} |',
        )
        ..writeln('|---|---|${widths.map((_) => '---').join('|')}|');
      for (final code in codes) {
        for (final scale in scales) {
          final group = '$code|$styleName|$scale';
          md.writeln(
            '| $code | $scale | ${widths.map((w) => overflowing['$group|${w.round()}'] ?? 0).join(' | ')} '
            '(of ${totals[group]}) |',
          );
        }
      }
      md.writeln();
    }

    md
      ..writeln('## Widest strings per language')
      ..writeln()
      ..writeln(
        'Top 10 by single-line width (style `${styleNames.first}`, scale '
        '${scales.first}).',
      )
      ..writeln();
    for (final code in codes) {
      final list = widest[code]!..sort((a, b) => b.$1.compareTo(a.$1));
      md.writeln('### $code');
      md.writeln();
      for (final (w, key, text) in list.take(10)) {
        final shown = text.length > 80 ? '${text.substring(0, 80)}...' : text;
        md.writeln('- ${w.round()} px `$key`: $shown');
      }
      md.writeln();
    }

    if (fallbackKeys.isNotEmpty) {
      md
        ..writeln('## Missing translations (measured as English)')
        ..writeln();
      fallbackKeys.forEach((code, keys) {
        md.writeln('- $code: ${keys.length} keys');
      });
    }
    File('${out.path}/summary.md').writeAsStringSync(md.toString());

    // ignore: avoid_print
    print('Wrote ${out.path}/text_metrics.csv and ${out.path}/summary.md');
  }, timeout: Timeout.none);
}
