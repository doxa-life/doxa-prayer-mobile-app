import 'dart:convert';
import 'dart:io';

import 'package:doxa_prayer_mobile_app/services/locale_controller.dart';
import 'package:doxa_prayer_mobile_app/services/thank_you_verse_service.dart';
import 'package:flutter_test/flutter_test.dart';

List<Map<String, dynamic>> _fixture(int count) => List.generate(
  count,
  (i) => <String, dynamic>{
    'locales': <String, dynamic>{
      'en': {'text': 'text $i', 'reference': 'ref $i', 'translation': 'NKJV'},
      'ru': {'text': 'текст $i', 'reference': 'ссылка $i', 'translation': 'SYNOD'},
    },
  },
);

void main() {
  group('verseAt', () {
    test('walks the set in order', () {
      final verses = _fixture(3);
      expect(verseAt(verses, 0, 'en')!.text, 'text 0');
      expect(verseAt(verses, 1, 'en')!.text, 'text 1');
      expect(verseAt(verses, 2, 'en')!.text, 'text 2');
    });

    test('wraps around at the end of the set', () {
      final verses = _fixture(3);
      expect(verseAt(verses, 3, 'en')!.text, 'text 0');
      expect(verseAt(verses, 7, 'en')!.text, 'text 1');
    });

    test('returns the requested locale, not English', () {
      final verse = verseAt(_fixture(2), 1, 'ru')!;
      expect(verse.text, 'текст 1');
      expect(verse.reference, 'ссылка 1');
      expect(verse.translation, 'SYNOD');
    });

    test('falls back to English for a locale missing from the set', () {
      expect(verseAt(_fixture(2), 0, 'de')!.text, 'text 0');
    });

    test('handles an empty set', () {
      expect(verseAt(const [], 0, 'en'), isNull);
    });
  });

  group('assets/thank_you_verses.json', () {
    late Map<String, dynamic> data;

    setUpAll(() {
      data =
          jsonDecode(File('assets/thank_you_verses.json').readAsStringSync())
              as Map<String, dynamic>;
    });

    test('covers every app language, with no empty strings', () {
      final verses = (data['verses'] as List).cast<Map<String, dynamic>>();
      expect(verses, isNotEmpty);

      final expected = appLanguages
          .map((l) => l.locale.languageCode)
          .toSet();
      for (var i = 0; i < verses.length; i++) {
        final locales = verses[i]['locales'] as Map<String, dynamic>;
        expect(
          locales.keys.toSet(),
          expected,
          reason: 'verse $i does not cover every app language',
        );
        for (final entry in locales.values.cast<Map<String, dynamic>>()) {
          expect(entry['text'], isNotEmpty);
          expect(entry['reference'], isNotEmpty);
          expect(entry['translation'], isNotEmpty);
        }
      }
    });

    test('carries no leftover markup or footnote markers', () {
      final verses = (data['verses'] as List).cast<Map<String, dynamic>>();
      final markup = RegExp(r'<[^>]+>|\[\d+\]|[Ⓐ-ⓩ]');
      for (final verse in verses) {
        final locales = verse['locales'] as Map<String, dynamic>;
        for (final entry in locales.values.cast<Map<String, dynamic>>()) {
          expect(
            markup.hasMatch(entry['text'] as String),
            isFalse,
            reason: 'markup left in ${entry['reference']}',
          );
        }
      }
    });
  });
}
