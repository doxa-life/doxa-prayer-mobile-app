import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/update_controller.dart';

/// Wraps the app and overlays the update prompt driven by [updateController]:
///   - optional → a dismissible banner pinned below the status bar
///   - forced   → a non-dismissible modal that blocks the app until updated
///
/// Mounted via MaterialApp.router's `builder` so it sits above every route.
class UpdateGate extends StatelessWidget {
  const UpdateGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UpdateStatus>(
      valueListenable: updateController,
      builder: (context, status, _) {
        switch (status.state) {
          case UpdateState.none:
            return child;
          case UpdateState.optional:
            return _OptionalBanner(child: child);
          case UpdateState.forced:
            return _ForcedModal(child: child);
        }
      },
    );
  }
}

class _OptionalBanner extends StatelessWidget {
  const _OptionalBanner({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Stack(
      children: [
        child,
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                color: theme.colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.updateAvailableTitle,
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.updateAvailableBody,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: dismissOptionalUpdate,
                        child: Text(l10n.updateDismiss),
                      ),
                      FilledButton(
                        onPressed: () => startAppUpdate(),
                        child: Text(l10n.updateAction),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ForcedModal extends StatelessWidget {
  const _ForcedModal({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          child,
          ModalBarrier(
            color: Colors.black.withValues(alpha: 0.6),
            dismissible: false,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Material(
                borderRadius: BorderRadius.circular(16),
                color: theme.colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.updateRequiredTitle,
                        style: theme.textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.updateRequiredBody,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => startAppUpdate(immediate: true),
                          child: Text(l10n.updateAction),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
