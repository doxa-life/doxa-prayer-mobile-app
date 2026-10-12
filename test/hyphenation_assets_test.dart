import 'dart:io';

import 'package:doxa_prayer_mobile_app/services/hyphenation_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the trimmed hyphenatorx copy in third_party/hyphenatorx. Every file in
/// its assets/ ships in the app, so it must hold exactly the languages
/// hyphenation_service.dart loads — no more (dead weight), no fewer (that
/// language silently goes unhyphenated). See docs/hyphenation.md.
void main() {
  const packageDir = 'third_party/hyphenatorx';

  test('the app depends on the trimmed local hyphenatorx copy', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(
      RegExp(
        r'^  hyphenatorx:\s*\n\s+path: third_party/hyphenatorx\s*$',
        multiLine: true,
      ).hasMatch(pubspec),
      isTrue,
      reason:
          'pubspec.yaml must use `hyphenatorx: path: $packageDir`. The pub.dev '
          'package bundles ~70 languages (~10 MB) the app never uses. To '
          'upgrade hyphenatorx, follow docs/hyphenation.md.',
    );
  });

  test('hyphenatorx bundles exactly the languages the app hyphenates', () {
    final bundled = Directory('$packageDir/assets')
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .toSet();
    final used = {for (final l in hyphenationLanguages) '${l.name}.json'};

    expect(
      used.difference(bundled),
      isEmpty,
      reason:
          'Languages in hyphenation_service.dart with no pattern file in '
          '$packageDir/assets/. Copy each from the upstream package '
          '(docs/hyphenation.md).',
    );
    expect(
      bundled.difference(used),
      isEmpty,
      reason:
          'Pattern files in $packageDir/assets/ that the app never loads but '
          'still ships. Delete them, or add the language to '
          'hyphenation_service.dart.',
    );
  });
}
