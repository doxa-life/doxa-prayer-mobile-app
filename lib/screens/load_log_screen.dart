import 'package:flutter/material.dart';

import '../services/load_log.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// The [LoadLog] on the device: every event, newest first, live as it
/// happens, or the per-item summary. Opened from the debug screen.
class LoadLogScreen extends StatefulWidget {
  const LoadLogScreen({super.key});

  @override
  State<LoadLogScreen> createState() => _LoadLogScreenState();
}

class _LoadLogScreenState extends State<LoadLogScreen> {
  bool _summary = false;

  static const _mono = TextStyle(
    fontFamily: 'Menlo',
    fontSize: 11,
    height: 1.3,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Load log'),
        actions: [
          IconButton(
            tooltip: _summary ? 'Show events' : 'Show summary',
            icon: Icon(_summary ? Icons.list : Icons.summarize_outlined),
            onPressed: () => setState(() => _summary = !_summary),
          ),
          IconButton(
            tooltip: 'Print summary to console',
            icon: const Icon(Icons.terminal),
            onPressed: LoadLog.printSummary,
          ),
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.delete_outline),
            onPressed: LoadLog.clear,
          ),
        ],
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: LoadLog.changes,
        builder: (context, _, _) {
          if (!LoadLog.enabled) {
            return const Center(
              child: Text('The load log is off in this build.'),
            );
          }
          final muted = AppColors.onSurface.withValues(alpha: 0.7);
          final lines = _summary
              ? [for (final line in LoadLog.summary()) (line, muted)]
              : [
                  for (final e in LoadLog.events.reversed)
                    (e.toString(), _colorFor(e.action) ?? muted),
                ];
          if (lines.isEmpty) {
            return const Center(child: Text('Nothing loaded yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: lines.length,
            separatorBuilder: (_, _) => Divider(
              height: AppSpacing.sm,
              color: AppColors.onSurface.withValues(alpha: 0.08),
            ),
            itemBuilder: (context, i) => SelectableText(
              lines[i].$1,
              style: _mono.copyWith(color: lines[i].$2),
            ),
          );
        },
      ),
    );
  }

  /// Requests, failures and drops stand out from the cache hits around them.
  static Color? _colorFor(LoadAction action) => switch (action) {
    LoadAction.failure || LoadAction.stale => Colors.red.shade700,
    LoadAction.request || LoadAction.response => AppColors.primary,
    LoadAction.discarded => Colors.orange.shade800,
    _ => null,
  };
}
