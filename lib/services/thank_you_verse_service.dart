import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

const _assetPath = 'assets/thank_you_verses.json';
const _indexKey = 'thank_you_verse_index';

/// Locale the verses fall back to when the active locale is missing from the
/// asset — every locale in [appLanguages] is present, so this only guards
/// against a locale being added to the app before the asset is regenerated.
const _fallbackLanguageCode = 'en';

/// A verse shown in the thank-you modal, already resolved to one language.
class ThankYouVerse {
  const ThankYouVerse({
    required this.text,
    required this.reference,
    required this.translation,
  });

  /// The verse itself, reproduced verbatim from a published translation.
  final String text;

  /// Book, chapter and verse, in the numbering used by [translation] — for
  /// Psalms these differ by language, so this is not a translation of the
  /// English reference. See `tool/fetch_thank_you_verses.py`.
  final String reference;

  /// Short label of the translation the text came from, e.g. `NKJV`.
  final String translation;
}

List<Map<String, dynamic>>? _cachedVerses;

/// Loads and caches the verse rotation. Returns an empty list if the asset is
/// missing or malformed, which leaves the modal without a verse rather than
/// failing the prayer flow.
Future<List<Map<String, dynamic>>> _loadVerses() async {
  final cached = _cachedVerses;
  if (cached != null) return cached;
  try {
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final verses = (decoded['verses'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    _cachedVerses = verses;
    return verses;
  } catch (error, stackTrace) {
    developer.log(
      'Failed to load thank-you verses',
      name: 'thank_you_verse_service',
      error: error,
      stackTrace: stackTrace,
    );
    _cachedVerses = const <Map<String, dynamic>>[];
    return _cachedVerses!;
  }
}

/// The next verse in the rotation for [languageCode], advancing the stored
/// pointer so the following "Amen" shows a different verse. Wraps around at the
/// end of the set. Returns null when no verse is available.
Future<ThankYouVerse?> nextThankYouVerse(String languageCode) async {
  final verses = await _loadVerses();
  if (verses.isEmpty) return null;

  final prefs = SharedPreferencesAsync();
  var index = 0;
  try {
    index = await prefs.getInt(_indexKey) ?? 0;
  } catch (error, stackTrace) {
    // A read failure just restarts the rotation; it must not block the modal.
    developer.log(
      'Failed to read thank-you verse index',
      name: 'thank_you_verse_service',
      error: error,
      stackTrace: stackTrace,
    );
  }

  final verse = verseAt(verses, index, languageCode);

  try {
    // Store the raw counter rather than the wrapped index so the value stays
    // meaningful if the number of verses changes between releases.
    await prefs.setInt(_indexKey, index + 1);
  } catch (error, stackTrace) {
    developer.log(
      'Failed to advance thank-you verse index',
      name: 'thank_you_verse_service',
      error: error,
      stackTrace: stackTrace,
    );
  }

  return verse;
}

/// Resolves the verse at [index] (wrapping) into [languageCode]. Exposed for
/// tests; [nextThankYouVerse] is the entry point the app uses.
ThankYouVerse? verseAt(
  List<Map<String, dynamic>> verses,
  int index,
  String languageCode,
) {
  if (verses.isEmpty) return null;
  // Modulo of a negative stored value would throw on list access.
  final position = index.abs() % verses.length;
  final locales = verses[position]['locales'] as Map<String, dynamic>;
  final entry =
      (locales[languageCode] ?? locales[_fallbackLanguageCode])
          as Map<String, dynamic>?;
  if (entry == null) return null;
  return ThankYouVerse(
    text: entry['text'] as String,
    reference: entry['reference'] as String,
    translation: entry['translation'] as String,
  );
}
