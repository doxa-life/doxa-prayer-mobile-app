import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards `lib/l10n/glossary_index.g.dart` — where each glossary term sits in
/// each app string — against drifting from the ARB files it is built from.
/// A stale index links the wrong words, or none.
void main() {
  test('the glossary index is current', () {
    final result = Process.runSync('dart', [
      'run',
      'tool/gen_glossary.dart',
      '--check',
    ], workingDirectory: Directory.current.path);
    expect(
      result.exitCode,
      0,
      reason:
          '${result.stdout}${result.stderr}\n'
          'Run: dart run tool/gen_glossary.dart',
    );
  });
}
