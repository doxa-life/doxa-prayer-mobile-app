import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/architecture/facts.dart';
import '../tool/gen_architecture.dart' as gen;

/// Guards `docs/architecture/` against drifting away from `lib/`.
///
/// Two failure modes, with different fixes:
///  * the catalogue cites something that no longer exists — edit
///    `tool/architecture/catalogue.dart`;
///  * the checked-in markdown no longer matches what the generator produces —
///    run `dart run tool/gen_architecture.dart`.
void main() {
  group('architecture docs', () {
    test('the action catalogue only cites code that still exists', () {
      final problems = gen.validateCatalogue(scanFacts(Directory.current.path));
      expect(
        problems,
        isEmpty,
        reason:
            'tool/architecture/catalogue.dart is out of date with lib/:\n'
            '${problems.map((p) => '  • $p').join('\n')}',
      );
    });

    test('the generated docs are current', () {
      final result = Process.runSync('dart', [
        'run',
        'tool/gen_architecture.dart',
        '--check',
      ], workingDirectory: Directory.current.path);
      expect(
        result.exitCode,
        0,
        reason:
            '${result.stdout}${result.stderr}\n'
            'Run: dart run tool/gen_architecture.dart',
      );
    });
  });
}
