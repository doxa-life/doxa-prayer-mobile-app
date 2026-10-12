// Turns the raw JSON from the performance harness into a report and compares
// it with the saved baseline.
//
//   dart run tool/perf/report.dart --out build/perf/<run> [--baseline FILE] [--save-baseline]
//
// With several runs in --out (run1.json, run2.json, ...), every metric is the
// MEDIAN across runs, which smooths out thermal and network noise.

import 'dart:convert';
import 'dart:io';

/// Metrics compared against the baseline: key -> (label, lowerIsBetter, unit).
/// A change counts as real only if it exceeds both the relative and absolute
/// thresholds below, so noise on tiny numbers isn't reported as a regression.
const _tracked = <String, String>{
  'wallMs': 'wall ms',
  'totalP90': 'frame p90 ms',
  'totalP99': 'frame p99 ms',
  'buildP90': 'build p90 ms',
  'rasterP90': 'raster p90 ms',
  'droppedTotal': 'dropped frames',
  'severe': 'severe hitches',
  'rssDeltaMb': 'RSS Δ MB',
};
const _relThreshold = 0.10;
const _absThreshold = {
  'wallMs': 50.0,
  'totalP90': 1.0,
  'totalP99': 2.0,
  'buildP90': 1.0,
  'rasterP90': 1.0,
  'droppedTotal': 2.0,
  'severe': 1.0,
  'rssDeltaMb': 5.0,
};

void main(List<String> args) {
  String? out, baselinePath;
  var save = false;
  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--out':
        out = args[++i];
      case '--baseline':
        baselinePath = args[++i];
      case '--save-baseline':
        save = true;
    }
  }
  if (out == null) {
    stderr.writeln('usage: report.dart --out DIR [--baseline FILE] [--save-baseline]');
    exit(2);
  }

  final runFiles = Directory(out)
      .listSync()
      .whereType<File>()
      .where((f) => RegExp(r'run\d+\.json$').hasMatch(f.path))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  if (runFiles.isEmpty) {
    stderr.writeln('No run*.json in $out — the test produced no data.');
    exit(1);
  }
  final runs = [
    for (final f in runFiles) jsonDecode(f.readAsStringSync()) as Map<String, dynamic>,
  ];

  final current = _summarize(runs);
  File('$out/report.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(current),
  );

  Map<String, dynamic>? baseline;
  if (baselinePath != null && File(baselinePath).existsSync()) {
    baseline = jsonDecode(File(baselinePath).readAsStringSync()) as Map<String, dynamic>;
  }

  final md = _render(current, baseline, runs.length);
  File('$out/report.md').writeAsStringSync(md);
  stdout.writeln(md);
  stdout.writeln('Report: $out/report.md');

  if (save && baselinePath != null) {
    File(baselinePath)
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(const JsonEncoder.withIndent('  ').convert(current));
    stdout.writeln('Saved as the new baseline: $baselinePath');
  }
}

double _median(List<double> v) {
  if (v.isEmpty) return 0;
  final s = [...v]..sort();
  final m = s.length ~/ 2;
  return s.length.isOdd ? s[m] : (s[m - 1] + s[m]) / 2;
}

double _num(Object? v) => (v as num?)?.toDouble() ?? 0;

Map<String, dynamic> _summarize(List<Map<String, dynamic>> runs) {
  final names = <String>[];
  final byName = <String, List<Map<String, dynamic>>>{};
  for (final run in runs) {
    for (final s in (run['scenarios'] as List).cast<Map<String, dynamic>>()) {
      final n = s['name'] as String;
      if (!byName.containsKey(n)) names.add(n);
      byName.putIfAbsent(n, () => []).add(s);
    }
  }

  double med(List<Map<String, dynamic>> ss, double Function(Map<String, dynamic>) f) =>
      _median([for (final s in ss) f(s)]);
  double frame(Map<String, dynamic> s, String thread, String stat) =>
      _num(((s['frames'] as Map)[thread] as Map)[stat]);

  final scenarios = <Map<String, dynamic>>[];
  for (final n in names) {
    final ss = byName[n]!;
    final markKeys = {for (final s in ss) ...(s['marks'] as Map).keys.cast<String>()};
    scenarios.add({
      'group': ss.first['group'],
      'name': n,
      'wallMs': med(ss, (s) => _num(s['wallMs'])),
      'marks': {
        for (final k in markKeys)
          k: med(ss, (s) => _num((s['marks'] as Map)[k])),
      },
      'frames': med(ss, (s) => _num((s['frames'] as Map)['count'])),
      'buildAvg': med(ss, (s) => frame(s, 'build', 'avg')),
      'buildP90': med(ss, (s) => frame(s, 'build', 'p90')),
      'buildP99': med(ss, (s) => frame(s, 'build', 'p99')),
      'buildMax': med(ss, (s) => frame(s, 'build', 'max')),
      'rasterAvg': med(ss, (s) => frame(s, 'raster', 'avg')),
      'rasterP90': med(ss, (s) => frame(s, 'raster', 'p90')),
      'rasterP99': med(ss, (s) => frame(s, 'raster', 'p99')),
      'rasterMax': med(ss, (s) => frame(s, 'raster', 'max')),
      'totalAvg': med(ss, (s) => frame(s, 'total', 'avg')),
      'totalP90': med(ss, (s) => frame(s, 'total', 'p90')),
      'totalP99': med(ss, (s) => frame(s, 'total', 'p99')),
      'totalMax': med(ss, (s) => frame(s, 'total', 'max')),
      'droppedBuild': med(ss, (s) => _num((s['frames'] as Map)['droppedBuild'])),
      'droppedRaster': med(ss, (s) => _num((s['frames'] as Map)['droppedRaster'])),
      'droppedTotal': med(ss, (s) => _num((s['frames'] as Map)['droppedTotal'])),
      'severe': med(ss, (s) => _num((s['frames'] as Map)['severeTotal'])),
      'rssMb': med(ss, (s) => _num(s['rssMb'])),
      'rssDeltaMb': med(ss, (s) => _num(s['rssDeltaMb'])),
      'imageCacheMb': med(ss, (s) => _num(s['imageCacheMb'])),
      'timedOut': {for (final s in ss) ...(s['timedOut'] as List).cast<String>()}.toList(),
      'errors': [for (final s in ss) if (s['error'] != null) s['error']],
    });
  }
  return {
    'meta': {...(runs.first['meta'] as Map<String, dynamic>), 'runs': runs.length},
    'scenarios': scenarios,
  };
}

String _f(num v, [int d = 1]) => v.toStringAsFixed(d);

String _render(Map<String, dynamic> cur, Map<String, dynamic>? base, int runs) {
  final meta = cur['meta'] as Map<String, dynamic>;
  final scenarios = (cur['scenarios'] as List).cast<Map<String, dynamic>>();
  final baseByName = <String, Map<String, dynamic>>{
    if (base != null)
      for (final s in (base['scenarios'] as List).cast<Map<String, dynamic>>())
        s['name'] as String: s,
  };
  final b = StringBuffer();

  b.writeln('# Performance report');
  b.writeln();
  b.writeln(
    '- **Commit** ${meta['gitSha']}${meta['gitDirty'] == true ? ' (uncommitted changes)' : ''}'
    '${(meta['label'] as String).isEmpty ? '' : ' · **Label** ${meta['label']}'}',
  );
  b.writeln(
    '- **When** ${meta['timestamp']} · **Flavor** ${meta['flavor']} · **Mode** ${meta['buildMode']}'
    ' · **${meta['os']}** ${meta['osVersion']}',
  );
  b.writeln(
    '- **Display** ${_f(_num(meta['refreshRateHz']), 0)} Hz → frame budget ${_f(_num(meta['frameBudgetMs']), 2)} ms'
    ' · **Runs** $runs (median)',
  );
  if (meta['buildMode'] != 'profile') {
    b.writeln();
    b.writeln('> ⚠️ Not a profile build. These numbers are not comparable with device profile runs.');
  }
  if (base != null) {
    final bm = base['meta'] as Map<String, dynamic>;
    b.writeln(
      '- **Baseline** ${bm['gitSha']}'
      '${(bm['label'] as String).isEmpty ? '' : ' (${bm['label']})'} · ${bm['timestamp']}',
    );
    if (bm['refreshRateHz'] != meta['refreshRateHz'] || bm['os'] != meta['os']) {
      b.writeln();
      b.writeln('> ⚠️ Baseline was taken on a different display refresh rate or OS; compare with care.');
    }
  } else {
    b.writeln('- **Baseline** none yet — run with `--save-baseline` to create one.');
  }
  b.writeln();
  b.writeln(
    'Frame times are per-frame durations: **build** = UI thread, **raster** = GPU thread, '
    '**frame** = whole pipeline. *Dropped* = frame over budget; *severe* = over 2× budget.',
  );

  // ---- Main table ----
  b.writeln();
  b.writeln('## All scenarios');
  b.writeln();
  b.writeln(
    '| Group | Scenario | wall ms | frames | build avg/p90/max | raster avg/p90/max '
    '| frame p90/p99 | dropped | severe | RSS Δ MB |',
  );
  b.writeln('|---|---|--:|--:|---|---|---|--:|--:|--:|');
  for (final s in scenarios) {
    final flag = (s['timedOut'] as List).isNotEmpty || (s['errors'] as List).isNotEmpty ? ' ⚠️' : '';
    b.writeln(
      '| ${s['group']} | ${s['name']}$flag | ${_f(_num(s['wallMs']), 0)} | ${_f(_num(s['frames']), 0)} '
      '| ${_f(_num(s['buildAvg']))}/${_f(_num(s['buildP90']))}/${_f(_num(s['buildMax']))} '
      '| ${_f(_num(s['rasterAvg']))}/${_f(_num(s['rasterP90']))}/${_f(_num(s['rasterMax']))} '
      '| ${_f(_num(s['totalP90']))}/${_f(_num(s['totalP99']))} '
      '| ${_f(_num(s['droppedTotal']), 0)} | ${_f(_num(s['severe']), 0)} | ${_f(_num(s['rssDeltaMb']))} |',
    );
  }

  // ---- Time to content ----
  b.writeln();
  b.writeln('## Time to content (ms from the action)');
  b.writeln();
  b.writeln('| Scenario | Mark | ms |${base == null ? '' : ' baseline | Δ |'}');
  b.writeln('|---|---|--:|${base == null ? '' : '--:|--:|'}');
  for (final s in scenarios) {
    final marks = s['marks'] as Map<String, dynamic>;
    for (final e in marks.entries) {
      final bv = baseByName[s['name']]?['marks'] is Map
          ? (baseByName[s['name']]!['marks'] as Map)[e.key]
          : null;
      b.write('| ${s['name']} | ${e.key} | ${_f(_num(e.value), 0)} |');
      if (base != null) {
        b.write(bv == null ? ' – | – |' : ' ${_f(_num(bv), 0)} | ${_delta(_num(e.value), _num(bv), 'wallMs')} |');
      }
      b.writeln();
    }
    for (final t in (s['timedOut'] as List).cast<String>()) {
      b.writeln('| ${s['name']} | $t | **timed out** |${base == null ? '' : ' | |'}');
    }
  }

  // ---- Comparison ----
  if (base != null) {
    final regressions = <String>[];
    final improvements = <String>[];
    for (final s in scenarios) {
      final bs = baseByName[s['name']];
      if (bs == null) continue;
      for (final k in _tracked.keys) {
        final c = _num(s[k]), o = _num(bs[k]);
        final diff = c - o;
        if (diff.abs() < _absThreshold[k]! || (o != 0 && diff.abs() / o < _relThreshold)) continue;
        final line =
            '`${s['name']}` ${_tracked[k]}: ${_f(o, k.contains('dropped') || k == 'severe' ? 0 : 1)}'
            ' → ${_f(c, k.contains('dropped') || k == 'severe' ? 0 : 1)} (${_delta(c, o, k)})';
        (diff > 0 ? regressions : improvements).add(line);
      }
    }
    b.writeln();
    b.writeln('## Versus baseline');
    b.writeln();
    b.writeln('Only changes over ${(_relThreshold * 100).round()}% *and* above a per-metric noise floor are listed.');
    b.writeln();
    b.writeln('### Regressions (${regressions.length})');
    b.writeln(regressions.isEmpty ? '\nNone.' : '\n${regressions.map((l) => '- $l').join('\n')}');
    b.writeln();
    b.writeln('### Improvements (${improvements.length})');
    b.writeln(improvements.isEmpty ? '\nNone.' : '\n${improvements.map((l) => '- $l').join('\n')}');
    final missing = [for (final n in baseByName.keys) if (!scenarios.any((s) => s['name'] == n)) n];
    if (missing.isNotEmpty) {
      b.writeln('\nScenarios in the baseline but not in this run: ${missing.join(', ')}');
    }
  }

  // ---- Worst offenders ----
  b.writeln();
  b.writeln('## Worst offenders');
  List<Map<String, dynamic>> top(String key) =>
      ([...scenarios]..sort((a, c) => _num(c[key]).compareTo(_num(a[key])))).take(5).toList();
  b.writeln('\n**Highest frame p99 (ms)**');
  for (final s in top('totalP99')) {
    b.writeln('- ${s['name']}: ${_f(_num(s['totalP99']))}');
  }
  b.writeln('\n**Most dropped frames**');
  for (final s in top('droppedTotal')) {
    b.writeln('- ${s['name']}: ${_f(_num(s['droppedTotal']), 0)} of ${_f(_num(s['frames']), 0)}');
  }
  b.writeln('\n**Slowest worst-case build (UI thread, ms)**');
  for (final s in top('buildMax')) {
    b.writeln('- ${s['name']}: ${_f(_num(s['buildMax']))}');
  }
  b.writeln('\n**Slowest worst-case raster (GPU thread, ms)**');
  for (final s in top('rasterMax')) {
    b.writeln('- ${s['name']}: ${_f(_num(s['rasterMax']))}');
  }

  // ---- Problems ----
  final problems = [
    for (final s in scenarios) ...[
      for (final t in (s['timedOut'] as List)) '${s['name']}: timed out waiting for "$t"',
      for (final e in (s['errors'] as List)) '${s['name']}: $e',
    ],
  ];
  if (problems.isNotEmpty) {
    b.writeln();
    b.writeln('## Problems');
    for (final p in problems) {
      b.writeln('- $p');
    }
  }
  return b.toString();
}

/// "+12%" / "-8%" with an arrow, lower being better for every tracked metric.
String _delta(num cur, num old, String key) {
  if (old == 0) return cur == 0 ? '0%' : 'new';
  final pct = (cur - old) / old * 100;
  final arrow = pct > 0 ? '▲' : pct < 0 ? '▼' : '';
  return '$arrow${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(0)}%';
}
