/// Generates `lib/l10n/glossary_index.g.dart`: where every glossary term sits
/// in every app string, in every language — worked out here, ahead of time,
/// so the app never searches text for terms while it runs.
///
///   dart run tool/gen_glossary.dart           # write the index
///   dart run tool/gen_glossary.dart --check   # exit 1 if it is stale
///
/// Run it after changing any ARB file (and alongside `flutter gen-l10n`).
/// `--check` is what `test/glossary_index_test.dart` runs, so the index can't
/// drift from the ARB files without the suite going red.
///
/// **The glossary** is read from the ARB files themselves. A term is any key
/// `glossary<Name>` with a sibling `glossary<Name>Definition`; an optional
/// `glossary<Name>Alternates` lists other wordings that also count as the term
/// (plurals, inflections), separated by `|`. The order of the keys in
/// `app_en.arb` is the order the Help screen lists the terms in, and `<Name>`
/// in kebab case is the term's stable id ("PeopleGroup" → "people-group").
///
/// **Matching**: case-insensitive, longest wording first (so "people group"
/// wins over "people" if both were terms), on whole words — except in
/// languages written without spaces, where every neighbour of a term is a
/// letter. The term's own heading and its alternates list are never linked.
///
/// **Only sentences are linked.** A term inside a button label, a title or a
/// tab ("Choose a people group", "My People Group") would turn a tap on the
/// control into a tap on the term, so a string is linked only when it reads
/// as running text: it ends in sentence punctuation (. ? ! : and their
/// equivalents in other scripts). Either way can be forced for one key by
/// adding `"x-glossary": true` or `false` to its `@key` metadata in
/// `app_en.arb`; it applies in every language.
///
/// **Only whole strings are indexed.** The app looks a string up by its exact
/// text, so a message with a placeholder or plural (`{count} people group…`)
/// can't be — its text only exists once filled in. Such messages are listed
/// when the generator runs, so a term in one is never missed silently.
library;

import 'dart:convert';
import 'dart:io';

const _outPath = 'lib/l10n/glossary_index.g.dart';
const _arbDir = 'lib/l10n';

/// Languages written without spaces between words.
const _unspaced = {'zh', 'ja', 'th', 'lo', 'km', 'my'};

final _termKey = RegExp(r'^glossary([A-Z][A-Za-z0-9]*)$');

/// How running text ends, in the scripts the app carries — Latin, Cyrillic,
/// Arabic, Devanagari, Chinese — allowing for a closing quote or bracket.
final _sentenceEnd = RegExp(r'[.?!:…。？！：।؟]["”’»)\]]*$');

void main(List<String> args) {
  final check = args.contains('--check');
  final root = _repoRoot();
  final result = generate(
    _readArbs('$root/$_arbDir'),
    _readOverrides('$root/$_arbDir/app_en.arb'),
  );
  final out = File('$root/$_outPath');

  if (check) {
    if (out.existsSync() && out.readAsStringSync() == result.source) {
      stdout.writeln('glossary index is up to date');
      return;
    }
    stderr.writeln(
      '$_outPath is stale.\nRegenerate with: dart run tool/gen_glossary.dart',
    );
    exit(1);
  }

  out.writeAsStringSync(result.source);
  stdout.writeln(
    'wrote $_outPath: ${result.termCount} term(s), '
    '${result.linkedStrings} string(s) with links across '
    '${result.locales} language(s)',
  );
  if (result.skipped.isNotEmpty) {
    stdout.writeln(
      '\nThese strings mention a term but have placeholders, so they are not '
      'linked:',
    );
    for (final s in result.skipped) {
      stdout.writeln('  • $s');
    }
  }
}

class GlossaryGenResult {
  GlossaryGenResult(
    this.source,
    this.termCount,
    this.linkedStrings,
    this.locales,
    this.skipped,
  );

  final String source;
  final int termCount;
  final int linkedStrings;
  final int locales;
  final List<String> skipped;
}

/// Locale code → that locale's ARB entries, without metadata.
Map<String, Map<String, String>> _readArbs(String dir) {
  final arbs = <String, Map<String, String>>{};
  final files =
      Directory(dir)
          .listSync()
          .whereType<File>()
          .where((f) => RegExp(r'app_\w+\.arb$').hasMatch(f.path))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  for (final file in files) {
    final code = RegExp(r'app_(\w+)\.arb$').firstMatch(file.path)!.group(1)!;
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    arbs[code] = {
      for (final e in json.entries)
        if (!e.key.startsWith('@') && e.value is String)
          e.key: e.value as String,
    };
  }
  return arbs;
}

/// Keys whose `@key` metadata in `app_en.arb` sets `x-glossary`.
Map<String, bool> _readOverrides(String enPath) {
  final json =
      jsonDecode(File(enPath).readAsStringSync()) as Map<String, dynamic>;
  return {
    for (final e in json.entries)
      if (e.key.startsWith('@') && e.value is Map<String, dynamic>)
        if ((e.value as Map<String, dynamic>)['x-glossary'] case final bool v)
          e.key.substring(1): v,
  };
}

String _kebab(String name) => name
    .replaceAllMapped(RegExp(r'(?<=[a-z0-9])([A-Z])'), (m) => '-${m[1]}')
    .toLowerCase();

GlossaryGenResult generate(
  Map<String, Map<String, String>> arbs, [
  Map<String, bool> overrides = const {},
]) {
  final en = arbs['en']!;
  // Term names in app_en.arb order.
  final names = [
    for (final key in en.keys)
      if (_termKey.firstMatch(key) case final m?)
        if (!key.endsWith('Definition') && !key.endsWith('Alternates'))
          if (en.containsKey('${key}Definition')) m.group(1)!,
  ];

  final buf = StringBuffer()
    ..writeln('// GENERATED by tool/gen_glossary.dart from lib/l10n/*.arb.')
    ..writeln('// Do not edit: change the ARB files and run')
    ..writeln('//   dart run tool/gen_glossary.dart')
    ..writeln()
    // Left as generated, so `dart format` over lib/ can't make --check fail.
    ..writeln('// dart format off')
    ..writeln()
    ..writeln("import '../services/glossary.dart';")
    ..writeln()
    ..writeln(
      '/// Every glossary term, in the order the Help screen lists them.',
    )
    ..writeln('const List<String> glossaryTermIds = [')
    ..writeAll([for (final n in names) "  '${_kebab(n)}',\n"])
    ..writeln('];')
    ..writeln()
    ..writeln('/// Each language\'s terms, by id.')
    ..writeln('const Map<String, Map<String, GlossaryTerm>> glossaryTerms = {');

  var linked = 0;
  final skipped = <String>[];
  final spansBuf = StringBuffer()
    ..writeln()
    ..writeln(
      '/// Each language\'s strings that mention a term, by their exact',
    )
    ..writeln('/// text, with where each term sits: start, end and term id.')
    ..writeln(
      'const Map<String, Map<String, List<GlossarySpan>>> glossarySpans = {',
    );

  for (final entry in arbs.entries) {
    final code = entry.key;
    final arb = entry.value;
    // Wording (lower case) → term id; the first term to claim one keeps it.
    final byForm = <String, String>{};
    final ownKeys = <String>{};
    buf.writeln('  ${_str(code)}: {');
    for (final name in names) {
      final id = _kebab(name);
      final term = arb['glossary$name'] ?? en['glossary$name']!;
      final definition =
          arb['glossary${name}Definition'] ?? en['glossary${name}Definition']!;
      final alternates = arb['glossary${name}Alternates'] ?? '';
      ownKeys
        ..add('glossary$name')
        ..add('glossary${name}Alternates');
      buf.writeln(
        '    ${_str(id)}: GlossaryTerm(id: ${_str(id)}, '
        'term: ${_str(term)}, definition: ${_str(definition)}),',
      );
      for (final form in [term, ...alternates.split('|')]) {
        final f = form.trim().toLowerCase();
        if (f.isNotEmpty) byForm.putIfAbsent(f, () => id);
      }
    }
    buf.writeln('  },');

    spansBuf.writeln('  ${_str(code)}: {');
    if (byForm.isNotEmpty) {
      final alternation =
          (byForm.keys.toList()..sort((a, b) => b.length.compareTo(a.length)))
              .map(RegExp.escape)
              .join('|');
      final pattern = RegExp(
        _unspaced.contains(code)
            ? '($alternation)'
            : r'(?<![\p{L}\p{N}])(' + alternation + r')(?![\p{L}\p{N}])',
        caseSensitive: false,
        unicode: true,
      );
      final seen = <String>{};
      for (final msg in arb.entries) {
        if (ownKeys.contains(msg.key)) continue;
        final text = msg.value;
        final linkable =
            overrides[msg.key] ?? _sentenceEnd.hasMatch(text.trimRight());
        if (!linkable) continue;
        final matches = pattern.allMatches(text).toList();
        if (matches.isEmpty) continue;
        if (text.contains('{')) {
          skipped.add('$code: ${msg.key}');
          continue;
        }
        // Two keys with the same text need only one entry.
        if (!seen.add(text)) continue;
        linked++;
        final spans = matches
            .map(
              (m) =>
                  'GlossarySpan(${m.start}, ${m.end}, '
                  '${_str(byForm[m.group(1)!.toLowerCase()]!)})',
            )
            .join(', ');
        spansBuf.writeln('    ${_str(text)}: [$spans],');
      }
    }
    spansBuf.writeln('  },');
  }
  buf.writeln('};');
  spansBuf.writeln('};');
  buf.write(spansBuf);
  return GlossaryGenResult(
    buf.toString(),
    names.length,
    linked,
    arbs.length,
    skipped,
  );
}

/// [s] as a Dart string literal.
String _str(String s) {
  final escaped = s
      .replaceAll(r'\', r'\\')
      .replaceAll("'", r"\'")
      .replaceAll(r'$', r'\$')
      .replaceAll('\n', r'\n')
      .replaceAll('\r', r'\r')
      .replaceAll('\t', r'\t');
  return "'$escaped'";
}

String _repoRoot() {
  var dir = File.fromUri(Platform.script).parent.parent;
  if (!File('${dir.path}/pubspec.yaml').existsSync()) dir = Directory.current;
  return dir.path;
}
