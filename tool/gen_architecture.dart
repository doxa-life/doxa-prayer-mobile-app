/// Generates `docs/architecture/` from the code plus the action catalogue.
///
///   dart run tool/gen_architecture.dart           # write the docs
///   dart run tool/gen_architecture.dart --check    # exit 1 if stale or invalid
///
/// `--check` is what `test/architecture_docs_test.dart` runs, so the docs cannot
/// drift away from `lib/` without the test suite going red.
library;

import 'dart:io';

import 'architecture/catalogue.dart';
import 'architecture/facts.dart';
import 'architecture/render.dart';

void main(List<String> args) {
  final check = args.contains('--check');
  final root = _repoRoot();
  final facts = scanFacts(root);

  final problems = validateCatalogue(facts);
  if (problems.isNotEmpty) {
    stderr.writeln(
      'The action catalogue references ${problems.length} thing(s) that no '
      'longer exist in lib/:\n',
    );
    for (final problem in problems) {
      stderr.writeln('  • $problem');
    }
    stderr.writeln(
      '\nFix tool/architecture/catalogue.dart so it describes the code as it is '
      'now.',
    );
    exit(1);
  }

  final rendered = renderAll(facts);

  if (check) {
    final stale = <String>[];
    for (final entry in rendered.entries) {
      final file = File('$root/${entry.key}');
      if (!file.existsSync() || file.readAsStringSync() != entry.value) {
        stale.add(entry.key);
      }
    }
    if (stale.isEmpty) {
      stdout.writeln('architecture docs are up to date');
      return;
    }
    stderr.writeln('These architecture docs are stale:\n');
    for (final path in stale) {
      stderr.writeln('  • $path');
    }
    stderr.writeln('\nRegenerate with: dart run tool/gen_architecture.dart');
    exit(1);
  }

  for (final entry in rendered.entries) {
    final file = File('$root/${entry.key}')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(entry.value);
    stdout.writeln('wrote ${entry.key} (${file.lengthSync()} bytes)');
  }
  stdout.writeln(
    '\n${actions.length} actions · ${facts.requests.length} endpoints · '
    '${facts.prefsKeys.length} persisted keys · ${facts.routes.length} routes',
  );

  // Not a failure — a new endpoint should not block a regeneration — but worth
  // saying out loud, because an undocumented endpoint is exactly the thing this
  // pipeline exists to stop accumulating.
  final gaps = coverageGaps(facts);
  if (gaps.isNotEmpty) {
    stdout.writeln('\nNot yet described in the catalogue:');
    for (final gap in gaps) {
      stdout.writeln('  • $gap');
    }
  }
}

/// Endpoints and persisted keys that no catalogued action accounts for.
List<String> coverageGaps(Facts facts) {
  final gaps = <String>[];
  for (final endpoint in facts.requests) {
    final covered = actions.any(
      (a) => a.steps.any((s) => s.endpoint == endpoint.id),
    );
    if (!covered) gaps.add('endpoint ${endpoint.id}');
  }
  for (final key in facts.prefsKeys) {
    final covered = actions.any(
      (a) => a.steps.any((s) => (s.writes ?? const []).contains(key.value)),
    );
    if (!covered) gaps.add('persisted key ${key.value}');
  }
  return gaps;
}

/// Every fact the catalogue leans on, checked against the scanned source. This
/// is the whole point of the pipeline: prose is allowed to be hand-written, but
/// not allowed to cite something that no longer exists.
List<String> validateCatalogue(Facts facts) {
  final problems = <String>[];
  final surfaceIds = surfaces.map((s) => s.id).toSet();
  final seenIds = <String>{};

  void checkAnchor(Anchor anchor, String context) {
    if (!facts.sourceFiles.containsKey(anchor.file)) {
      problems.add('$context: no such file `${anchor.file}`');
    } else if (!facts.anchorResolves(anchor)) {
      problems.add(
        '$context: `${anchor.symbol}` is gone from `${anchor.file}`',
      );
    }
  }

  for (final anchor in permissionEntryPointAnchors) {
    checkAnchor(anchor, 'identity.md permission entry points');
  }

  for (final action in actions) {
    final where = 'action `${action.id}`';
    if (!seenIds.add(action.id)) {
      problems.add('$where: duplicate action id');
    }
    if (!surfaceIds.contains(action.surface)) {
      problems.add('$where: unknown surface `${action.surface}`');
    }
    checkAnchor(action.trigger, '$where trigger');

    if (action.steps.isEmpty) {
      problems.add('$where: no steps, so it would render an empty diagram');
    }

    for (var i = 0; i < action.steps.length; i++) {
      final step = action.steps[i];
      final stepWhere = '$where step ${i + 1}';
      final anchor = step.anchor;
      if (anchor != null) checkAnchor(anchor, stepWhere);

      final endpoint = step.endpoint;
      if (endpoint != null && facts.endpointById(endpoint) == null) {
        problems.add(
          '$stepWhere: endpoint `$endpoint` is not built anywhere in lib/',
        );
      }

      for (final key in step.writes ?? const <String>[]) {
        if (facts.prefsKeyByValue(key) == null) {
          problems.add(
            '$stepWhere: `$key` is not a SharedPreferences key in lib/',
          );
        }
      }
    }
  }

  // A documented identity field must still map to a real persisted key.
  for (final key in const [
    'identity_tracking_id',
    'identity_profile_id',
    'identity_subscription_id',
  ]) {
    if (facts.prefsKeyByValue(key) == null) {
      problems.add('identity.md: `$key` is no longer a persisted key');
    }
  }

  return problems;
}

/// Walks up from the script until it finds the `pubspec.yaml`, so the tool works
/// from any working directory.
String _repoRoot() {
  var dir = Directory.current;
  while (true) {
    if (File('${dir.path}/pubspec.yaml').existsSync()) return dir.path;
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError(
        'could not find pubspec.yaml above ${Directory.current}',
      );
    }
    dir = parent;
  }
}
