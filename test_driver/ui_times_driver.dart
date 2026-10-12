// Host side of the UI-times test: writes the result as a plain markdown file.
// Run via tool/perf/run_ui_times.sh, which sets UI_TIMES_OUT and the details.

import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() async {
  final env = Platform.environment;
  final out = env['UI_TIMES_OUT'] ?? 'build/perf/ui-times/latest.md';
  await integrationDriver(
    timeout: const Duration(minutes: 20),
    responseDataCallback: (Map<String, dynamic>? data) async {
      if (data == null) {
        stderr.writeln('ui-times: the test reported no data.');
        return;
      }
      final now = DateTime.now();
      String two(int n) => n.toString().padLeft(2, '0');
      final stamp =
          '${now.year}-${two(now.month)}-${two(now.day)} ${two(now.hour)}:${two(now.minute)}:${two(now.second)}';
      final b = StringBuffer()
        ..writeln('Timestamp: $stamp')
        ..writeln('Device: ${env['UI_DEVICE'] ?? 'unknown'} (${data['os']}, profile build)');
      final label = env['UI_LABEL'] ?? '';
      if (label.isNotEmpty) b.writeln('Label: $label');
      b
        ..writeln('Commit: ${env['UI_COMMIT'] ?? 'unknown'}')
        ..writeln()
        ..writeln('| Element | ms |')
        ..writeln('|---|--:|');
      for (final r in (data['rows'] as List).cast<Map<String, dynamic>>()) {
        final ms = r['ms'] as num?;
        final note = r['note'] as String?;
        final value = ms == null ? '—' : ms.round().toString();
        b.writeln('| ${r['element']} | $value${note == null ? '' : ' ($note)'} |');
      }
      final file = File(out)..parent.createSync(recursive: true);
      file.writeAsStringSync(b.toString());
      stdout.writeln('ui-times: wrote $out');
    },
  );
}
