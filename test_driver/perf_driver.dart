// Host-side driver for the performance harness.
//
// Runs on the dev machine while `flutter drive` executes
// integration_test/perf_test.dart on the device. The test hands its results back
// through `binding.reportData`; this writes them to $PERF_OUT (default
// build/perf/raw.json). tool/perf/run_perf.sh sets PERF_OUT per run.

import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() async {
  final out = Platform.environment['PERF_OUT'] ?? 'build/perf/raw.json';
  await integrationDriver(
    timeout: const Duration(minutes: 25),
    responseDataCallback: (Map<String, dynamic>? data) async {
      if (data == null) {
        stderr.writeln('perf: the test reported no data.');
        return;
      }
      // Run details come from the host, so the same built app can be reused.
      final env = Platform.environment;
      final meta = (data['meta'] as Map<String, dynamic>?) ?? {};
      for (final (key, name) in [
        ('gitSha', 'PERF_GIT_SHA'),
        ('gitDirty', 'PERF_GIT_DIRTY'),
        ('label', 'PERF_LABEL'),
        ('flavor', 'PERF_FLAVOR'),
      ]) {
        final v = env[name];
        if (v != null && v.isNotEmpty) {
          meta[key] = key == 'gitDirty' ? v == 'true' : v;
        }
      }
      data['meta'] = meta;
      final file = File(out)..parent.createSync(recursive: true);
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
      stdout.writeln('perf: wrote $out');
    },
  );
}
