/// Scans `lib/` for the facts the architecture docs are built from.
///
/// Everything in here is derived from source, never hand-maintained: endpoints,
/// cache policies, SharedPreferences keys and routes. The semantic layer — what
/// a button *means*, and what happens invisibly when it is tapped — lives in
/// `catalogue.dart` and is validated against these facts, so a rename in `lib/`
/// breaks the build rather than quietly rotting the docs.
library;

import 'dart:io';

/// A pointer from the catalogue into real source. Validated at generation time.
class Anchor {
  const Anchor(this.file, this.symbol);

  /// Repo-relative path, e.g. `lib/services/identity_service.dart`.
  final String file;

  /// A declaration or call the file must still contain, e.g. `submitAnonSignup`.
  final String symbol;

  @override
  String toString() => '$file#$symbol';
}

/// One `ApiConfig.buildUri(...)` call site, with its HTTP verb resolved from
/// the surrounding lines.
class Endpoint {
  Endpoint({
    required this.method,
    required this.path,
    required this.sites,
    this.cacheKeyExpr,
    this.ttlPolicy,
    this.refreshPolicy,
  });

  /// `GET`/`POST`/`PUT`/`DELETE`, or `LINK` when the URI is only ever built to
  /// be shared or opened in a browser rather than requested.
  final String method;
  final String path;

  /// Every `buildUri` call site that produces this endpoint — `/api/profile/{id}`
  /// is fetched from two places, and both matter when tracing a change.
  final List<CallSite> sites;

  /// Set when the call goes through `getJsonCached` — the cache key expression
  /// and the `CachePolicy` fields it was given.
  final String? cacheKeyExpr;
  final String? ttlPolicy;
  final String? refreshPolicy;

  bool get isCached => ttlPolicy != null;
  bool get isRequest => method != 'LINK';
  String get id => '$method $path';
}

/// One `ApiConfig.buildUri` call site.
class CallSite {
  const CallSite({required this.file, required this.line});

  final String file;
  final int line;

  String get short => '${file.split('/').last}:$line';
}

/// A `SharedPreferences` key: the constant, its literal value, where it lives.
class PrefsKey {
  const PrefsKey({
    required this.constName,
    required this.value,
    required this.file,
    required this.line,
  });

  final String constName;
  final String value;
  final String file;
  final int line;
}

/// A `Duration` constant from `cache_policy.dart`.
class CacheEntry {
  const CacheEntry({
    required this.name,
    required this.duration,
    required this.doc,
  });

  final String name;
  final String duration;
  final String doc;
}

/// A `GoRoute` from `router.dart`.
class RouteEntry {
  const RouteEntry({
    required this.name,
    required this.path,
    required this.line,
  });

  final String name;
  final String path;
  final int line;
}

class Facts {
  Facts({
    required this.endpoints,
    required this.prefsKeys,
    required this.cachePolicies,
    required this.routes,
    required this.sourceFiles,
  });

  final List<Endpoint> endpoints;
  final List<PrefsKey> prefsKeys;
  final List<CacheEntry> cachePolicies;
  final List<RouteEntry> routes;

  /// Repo-relative path -> file contents, for anchor validation.
  final Map<String, String> sourceFiles;

  Iterable<Endpoint> get requests => endpoints.where((e) => e.isRequest);

  Endpoint? endpointById(String id) {
    for (final e in endpoints) {
      if (e.id == id) return e;
    }
    return null;
  }

  PrefsKey? prefsKeyByValue(String value) {
    for (final k in prefsKeys) {
      if (k.value == value) return k;
    }
    return null;
  }

  /// Whether [anchor]'s file exists and still contains its symbol as a whole
  /// word. Deliberately a word match rather than a real parse: it catches the
  /// case that actually matters (something was renamed or deleted) without
  /// pulling in the analyzer.
  bool anchorResolves(Anchor anchor) {
    final source = sourceFiles[anchor.file];
    if (source == null) return false;
    return RegExp('\\b${RegExp.escape(anchor.symbol)}\\b').hasMatch(source);
  }
}

// ---------------------------------------------------------------------------
// Scanning
// ---------------------------------------------------------------------------

/// Reads every `.dart` file under `<repoRoot>/lib` and extracts the fact base.
Facts scanFacts(String repoRoot) {
  final libDir = Directory('$repoRoot/lib');
  if (!libDir.existsSync()) {
    throw StateError('no lib/ directory under $repoRoot');
  }

  final sourceFiles = <String, String>{};
  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final rel = entity.path
        .substring(repoRoot.length + 1)
        .replaceAll('\\', '/');
    // Generated localisations add thousands of lines and no architecture.
    if (rel.startsWith('lib/l10n/app_localizations')) continue;
    sourceFiles[rel] = entity.readAsStringSync();
  }

  final endpoints = <Endpoint>[];
  final prefsKeys = <PrefsKey>[];
  for (final entry in sourceFiles.entries) {
    endpoints.addAll(_scanEndpoints(entry.key, entry.value));
    prefsKeys.addAll(_scanPrefsKeys(entry.key, entry.value));
  }

  final merged = _mergeEndpoints(endpoints);
  merged.sort((a, b) {
    final byPath = a.path.compareTo(b.path);
    return byPath != 0 ? byPath : a.method.compareTo(b.method);
  });
  prefsKeys.sort((a, b) => a.value.compareTo(b.value));

  return Facts(
    endpoints: merged,
    prefsKeys: prefsKeys,
    cachePolicies: _scanCachePolicies(
      sourceFiles['lib/services/cache_policy.dart'] ?? '',
    ),
    routes: _scanRoutes(sourceFiles['lib/router.dart'] ?? ''),
    sourceFiles: sourceFiles,
  );
}

/// Collapses repeat call sites of the same `METHOD path` into one endpoint,
/// keeping every site and the first cache configuration seen.
List<Endpoint> _mergeEndpoints(List<Endpoint> raw) {
  final byId = <String, Endpoint>{};
  for (final e in raw) {
    final existing = byId[e.id];
    if (existing == null) {
      byId[e.id] = e;
      continue;
    }
    existing.sites.addAll(e.sites);
  }
  return byId.values.toList();
}

final _buildUriRe = RegExp(r"ApiConfig\.buildUri\(\s*'([^']*)'");
final _verbRe = RegExp(r'http\.(get|post|put|delete)\s*\(');
final _ttlRe = RegExp(r'ttl:\s*CachePolicy\.(\w+)');
final _refreshRe = RegExp(r'refreshAfter:\s*CachePolicy\.(\w+)');
final _cacheKeyRe = RegExp(r'cacheKey:\s*([^\n]+?),\s*$', multiLine: true);

List<Endpoint> _scanEndpoints(String file, String source) {
  final lines = source.split('\n');
  final found = <Endpoint>[];

  for (final match in _buildUriRe.allMatches(source)) {
    final line = _lineOf(source, match.start);
    // The verb can sit well below the URI (a dev-skip guard and a log call
    // often come between), so look generously forward and a little back for
    // the `getJsonCached(` wrapper.
    final window = lines
        .sublist(
          (line - 9).clamp(0, lines.length),
          (line + 30).clamp(0, lines.length),
        )
        .join('\n');

    final cached = window.contains('getJsonCached(');
    final verbMatch = _verbRe.firstMatch(window);
    final method = cached
        ? 'GET'
        : (verbMatch?.group(1)?.toUpperCase() ?? 'LINK');

    found.add(
      Endpoint(
        method: method,
        path: _normalisePath(match.group(1)!),
        sites: [CallSite(file: file, line: line)],
        cacheKeyExpr: cached
            ? _cacheKeyRe.firstMatch(window)?.group(1)?.trim()
            : null,
        ttlPolicy: cached ? _ttlRe.firstMatch(window)?.group(1) : null,
        refreshPolicy: cached ? _refreshRe.firstMatch(window)?.group(1) : null,
      ),
    );
  }
  return found;
}

/// Turns a Dart-interpolated path into a stable documented shape:
/// `/api/profile/$profileId` -> `/api/profile/{profileId}`.
String _normalisePath(String raw) {
  var path = raw;
  // `${...}` expressions first, so the simple `$name` pass can't eat them.
  path = path.replaceAll(RegExp(r'\$\{_formatDate\([^}]*\)\}'), '{date}');
  path = path.replaceAll(RegExp(r'\$\{[^}]*\}'), '{expr}');
  path = path.replaceAllMapped(RegExp(r'\$(\w+)'), (m) {
    final name = m.group(1)!;
    // `$day` is a formatted date; document it as such so both prayer-content
    // endpoints read consistently.
    return name == 'day' ? '{date}' : '{$name}';
  });
  return path;
}

final _prefsConstRe = RegExp(
  r"^(?:\s*static\s+)?const\s+(?:String\s+)?(_\w+)\s*=\s*'([^']+)';",
  multiLine: true,
);

/// Collects only those string constants actually used as a prefs key — i.e. the
/// file passes them to a `prefs.get*/set*/remove` call. That keeps unrelated
/// constants (asset paths, channel ids, analytics event names) out.
List<PrefsKey> _scanPrefsKeys(String file, String source) {
  if (!source.contains('SharedPreferences')) return const [];

  final found = <PrefsKey>[];
  for (final match in _prefsConstRe.allMatches(source)) {
    final name = match.group(1)!;
    final used = RegExp(
      'prefs\\.(?:get\\w+|set\\w+|remove)\\(\\s*${RegExp.escape(name)}\\b',
    ).hasMatch(source);
    if (!used) continue;
    found.add(
      PrefsKey(
        constName: name,
        value: match.group(2)!,
        file: file,
        line: _lineOf(source, match.start),
      ),
    );
  }
  return found;
}

final _policyRe = RegExp(
  r'static const Duration (\w+) = (Duration\([^)]*\)|\w+);',
);

List<CacheEntry> _scanCachePolicies(String source) {
  final lines = source.split('\n');
  final found = <CacheEntry>[];
  for (final match in _policyRe.allMatches(source)) {
    final line = _lineOf(source, match.start);
    found.add(
      CacheEntry(
        name: match.group(1)!,
        duration: _humaniseDuration(match.group(2)!),
        doc: _docCommentAbove(lines, line),
      ),
    );
  }
  return found;
}

String _humaniseDuration(String expr) {
  final m = RegExp(r'Duration\((\w+):\s*(\d+)\)').firstMatch(expr);
  if (m == null) return expr; // an alias such as `prayerContent`
  final unit = m.group(1)!;
  final value = int.parse(m.group(2)!);
  final label = value == 1 ? unit.replaceAll(RegExp(r's$'), '') : unit;
  return '$value $label';
}

final _routeRe = RegExp(
  r"name:\s*(?:'([^']+)'|AppRoute\.(\w+)\.name),\s*\n\s*path:\s*'([^']+)'",
);

List<RouteEntry> _scanRoutes(String source) {
  final found = <RouteEntry>[];
  // A nested `GoRoute` declares a relative path (`news-signup`, `:date`). The
  // nearest absolute path above it is its parent, which is enough to rebuild the
  // full location without parsing the tree.
  var parent = '';
  for (final match in _routeRe.allMatches(source)) {
    final raw = match.group(3)!;
    final String path;
    if (raw.startsWith('/')) {
      parent = raw;
      path = raw;
    } else {
      path = '${parent == '/' ? '' : parent}/$raw';
    }
    found.add(
      RouteEntry(
        name: match.group(1) ?? match.group(2)!,
        path: path,
        line: _lineOf(source, match.start),
      ),
    );
  }
  return found;
}

/// The `///` block immediately above [line] (1-based), joined into one line so
/// it can sit in a table cell.
String _docCommentAbove(List<String> lines, int line) {
  final collected = <String>[];
  for (var i = line - 2; i >= 0; i--) {
    final trimmed = lines[i].trim();
    if (!trimmed.startsWith('///')) break;
    collected.insert(0, trimmed.substring(3).trim());
  }
  return collected.join(' ').replaceAll('|', r'\|').trim();
}

int _lineOf(String source, int offset) =>
    source.substring(0, offset).split('\n').length;
