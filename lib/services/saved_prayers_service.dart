import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'api_config.dart';
import 'prayer_content_service.dart';
import 'response_cache.dart';

/// A prayer the user has starred, downloaded, or both — one people group's
/// prayer for one day.
///
/// Starred is the user's own mark: "the Holy Spirit did something in me
/// here". Downloaded keeps the day's content on the device for good, so it can
/// be read again offline long after the 30-day response cache has swept it.
/// A starred prayer keeps its content too, so it can always be reopened; the
/// difference is only in what the user asked for and what the list shows.
@immutable
class SavedPrayer {
  const SavedPrayer({
    required this.slug,
    required this.date,
    required this.language,
    required this.groupName,
    required this.starred,
    required this.downloaded,
    required this.savedAt,
    this.imageUrl,
  });

  final String slug;

  /// The day, as `yyyy-MM-dd` — the same form the API and the deep links use.
  final String date;

  /// The language the stored content is in.
  final String language;
  final String groupName;
  final String? imageUrl;
  final bool starred;
  final bool downloaded;
  final DateTime savedAt;

  String get key => savedPrayerKey(slug, date);

  DateTime get day => DateTime.parse(date);

  SavedPrayer copyWith({bool? starred, bool? downloaded}) => SavedPrayer(
    slug: slug,
    date: date,
    language: language,
    groupName: groupName,
    imageUrl: imageUrl,
    starred: starred ?? this.starred,
    downloaded: downloaded ?? this.downloaded,
    savedAt: savedAt,
  );

  Map<String, dynamic> toJson() => {
    'slug': slug,
    'date': date,
    'language': language,
    'group_name': groupName,
    'image_url': ?imageUrl,
    'starred': starred,
    'downloaded': downloaded,
    'saved_at': savedAt.toUtc().toIso8601String(),
  };

  static SavedPrayer? fromJson(Map<String, dynamic> json) {
    final slug = json['slug'];
    final date = json['date'];
    if (slug is! String || date is! String) return null;
    return SavedPrayer(
      slug: slug,
      date: date,
      language: (json['language'] as String?) ?? 'en',
      groupName: (json['group_name'] as String?) ?? slug,
      imageUrl: json['image_url'] as String?,
      starred: json['starred'] == true,
      downloaded: json['downloaded'] == true,
      savedAt:
          DateTime.tryParse(json['saved_at'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
    );
  }
}

String _formatDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// One prayer per group per day, whatever language it was saved in.
String savedPrayerKey(String slug, String date) => '$slug|$date';

/// Every saved prayer, keyed by [savedPrayerKey]. Loaded once at startup by
/// [loadSavedPrayers]; the Pray screen's star and download buttons, the
/// calendar's marks and the Saved prayers screen all listen to it.
final ValueNotifier<Map<String, SavedPrayer>> savedPrayersController =
    ValueNotifier<Map<String, SavedPrayer>>(const {});

/// The saved entry for [slug] on [date], if any.
SavedPrayer? savedPrayerFor(String slug, DateTime date) =>
    savedPrayersController.value[savedPrayerKey(slug, _formatDate(date))];

/// Where saved prayers live: the app-support directory, which — unlike the
/// cache directory the response cache uses — the OS never reclaims, and the
/// startup cache sweep never touches.
class _SavedPrayerStore {
  _SavedPrayerStore._();

  static Directory? _dir;

  static Future<Directory?> _directory() async {
    final existing = _dir;
    if (existing != null) return existing;
    try {
      final base = await getApplicationSupportDirectory();
      final dir = Directory('${base.path}/saved_prayers');
      if (!await dir.exists()) await dir.create(recursive: true);
      return _dir = dir;
    } catch (e) {
      developer.log(
        'saved prayer store unavailable',
        name: 'saved_prayers',
        error: e,
      );
      return null;
    }
  }

  static String _safe(String s) =>
      s.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

  static Future<File?> _indexFile() async {
    final dir = await _directory();
    return dir == null ? null : File('${dir.path}/index.json');
  }

  static Future<File?> _contentFile(String slug, String date) async {
    final dir = await _directory();
    return dir == null
        ? null
        : File('${dir.path}/${_safe(slug)}_${_safe(date)}.json');
  }

  static Future<Map<String, SavedPrayer>> readIndex() async {
    try {
      final file = await _indexFile();
      if (file == null || !await file.exists()) return const {};
      final json = jsonDecode(await file.readAsString());
      if (json is! List) return const {};
      final entries = <String, SavedPrayer>{};
      for (final raw in json) {
        if (raw is! Map<String, dynamic>) continue;
        final entry = SavedPrayer.fromJson(raw);
        if (entry != null) entries[entry.key] = entry;
      }
      return entries;
    } catch (e) {
      developer.log(
        'saved prayer index unreadable',
        name: 'saved_prayers',
        error: e,
      );
      return const {};
    }
  }

  static Future<void> writeIndex(Map<String, SavedPrayer> entries) async {
    final file = await _indexFile();
    if (file == null) return;
    // Written aside and renamed over, so a crash mid-write can't leave the
    // user's stars half a file.
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(
      jsonEncode([for (final e in entries.values) e.toJson()]),
      flush: true,
    );
    await tmp.rename(file.path);
  }

  static Future<String?> readContent(String slug, String date) async {
    try {
      final file = await _contentFile(slug, date);
      if (file == null || !await file.exists()) return null;
      return await file.readAsString();
    } catch (_) {
      return null;
    }
  }

  static Future<void> writeContent(
    String slug,
    String date,
    String body,
  ) async {
    final file = await _contentFile(slug, date);
    await file?.writeAsString(body, flush: true);
  }

  static Future<void> deleteContent(String slug, String date) async {
    try {
      final file = await _contentFile(slug, date);
      if (file != null && await file.exists()) await file.delete();
    } catch (_) {}
  }
}

/// Reads the saved prayers into [savedPrayersController]. Called once from
/// `main()`.
Future<void> loadSavedPrayers() async {
  savedPrayersController.value = await _SavedPrayerStore.readIndex();
}

/// The stored body of a saved prayer, for [fetchPrayerContent] to serve
/// without a request. Only when it is in [language], unless [anyLanguage]: the
/// Pray screen asks for the app's language, and a prayer saved in another one
/// shouldn't stand in for it while the network can provide the right one —
/// only once the network has failed.
Future<String?> readSavedPrayerBody({
  required String slug,
  required DateTime date,
  required String language,
  bool anyLanguage = false,
}) async {
  final entry = savedPrayerFor(slug, date);
  if (entry == null) return null;
  if (!anyLanguage && entry.language != language) return null;
  return _SavedPrayerStore.readContent(entry.slug, entry.date);
}

/// The raw response body for the prayer, to keep on the device: from the
/// response cache when the Pray screen has already loaded it (it always has
/// when the user taps star or download there), otherwise from the network.
Future<String> _fetchBody({
  required String slug,
  required DateTime date,
  required String language,
}) async {
  final cached = await ResponseCache.read(
    prayerContentCacheKey(slug: slug, date: date, language: language),
  );
  if (cached != null) return cached;
  final uri = ApiConfig.buildUri(
    '/api/people-groups/$slug/prayer-content/${_formatDate(date)}',
    {'language': language},
  );
  final response = await http.get(
    uri,
    headers: const {'Accept': 'application/json'},
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to download prayer (${response.statusCode})');
  }
  return response.body;
}

/// Sets the star and/or download flags on the prayer for [slug] on [date],
/// storing its content the first time either is set and dropping the entry
/// (and its content) once neither is.
///
/// Throws when the content has to be fetched and can't be — the caller says
/// so; nothing is recorded in that case.
Future<void> updateSavedPrayer({
  required String slug,
  required DateTime date,
  required String language,
  required String groupName,
  String? imageUrl,
  bool? starred,
  bool? downloaded,
}) async {
  final day = _formatDate(date);
  final key = savedPrayerKey(slug, day);
  final entries = Map<String, SavedPrayer>.of(savedPrayersController.value);
  final existing = entries[key];
  final next =
      (existing ??
              SavedPrayer(
                slug: slug,
                date: day,
                language: language,
                groupName: groupName.isEmpty ? slug : groupName,
                imageUrl: imageUrl,
                starred: false,
                downloaded: false,
                savedAt: DateTime.now(),
              ))
          .copyWith(starred: starred, downloaded: downloaded);

  if (!next.starred && !next.downloaded) {
    entries.remove(key);
    savedPrayersController.value = entries;
    await _SavedPrayerStore.writeIndex(entries);
    await _SavedPrayerStore.deleteContent(slug, day);
    return;
  }

  if (existing == null) {
    final body = await _fetchBody(slug: slug, date: date, language: language);
    await _SavedPrayerStore.writeContent(slug, day, body);
  }
  entries[key] = next;
  savedPrayersController.value = entries;
  await _SavedPrayerStore.writeIndex(entries);
}
