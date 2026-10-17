import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

/// Keeps vertical-writing data out of the bundled fonts.
///
/// Flutter lays text out horizontally only, so a font's vertical metrics and
/// vertical layout features can never be used — and in the Chinese font they
/// cost 0.26 MB. `tool/strip_vertical_fonts.py` removes them; this fails when
/// a font is replaced with a fresh download, or a new one is added, without
/// going through it.
///
/// Reads the font files directly (the sfnt table directory, and the feature
/// lists of GSUB and GPOS), so it needs nothing beyond the Dart SDK.
void main() {
  const verticalTables = {'vhea', 'vmtx', 'VORG'};
  const verticalFeatures = {'vert', 'vrt2', 'vhal', 'vkrn', 'vpal'};

  final fonts =
      Directory('assets/fonts')
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (f) =>
                RegExp(r'\.(ttf|otf)$', caseSensitive: false).hasMatch(f.path),
          )
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  test('there are fonts to check', () => expect(fonts, isNotEmpty));

  for (final file in fonts) {
    test('${file.path} carries no vertical-writing data', () {
      final data = ByteData.sublistView(file.readAsBytesSync());
      final tables = _tableOffsets(data);
      final features = {
        for (final table in ['GSUB', 'GPOS'])
          if (tables[table] case final offset?) ..._featureTags(data, offset),
      };
      final found = [
        ...tables.keys.where(verticalTables.contains),
        ...features.where(verticalFeatures.contains),
      ];
      expect(
        found,
        isEmpty,
        reason:
            '${file.path} has vertical-writing data ($found), which Flutter '
            'never uses.\nRun: python3 tool/strip_vertical_fonts.py',
      );
    });
  }
}

String _tag(ByteData data, int at) =>
    String.fromCharCodes([for (var i = 0; i < 4; i++) data.getUint8(at + i)]);

/// Table tag → offset, from the font's table directory.
Map<String, int> _tableOffsets(ByteData data) {
  final count = data.getUint16(4);
  return {
    for (var i = 0; i < count; i++)
      _tag(data, 12 + 16 * i): data.getUint32(12 + 16 * i + 8),
  };
}

/// The feature tags in a GSUB or GPOS table starting at [table].
Iterable<String> _featureTags(ByteData data, int table) sync* {
  final featureList = data.getUint16(table + 6);
  if (featureList == 0) return;
  final list = table + featureList;
  final count = data.getUint16(list);
  for (var i = 0; i < count; i++) {
    yield _tag(data, list + 2 + 6 * i);
  }
}
