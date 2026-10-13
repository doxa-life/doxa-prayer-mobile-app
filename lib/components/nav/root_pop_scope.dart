import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Pops the current route when there is history to pop, otherwise falls back to
/// the Home tab. This is what keeps back from emptying the root navigator and
/// leaving a black, unresponsive screen (or closing the app) when a route was
/// reached as the only page on the stack, e.g. a cold-start deep link.
///
/// The pop decision is made against the raw [Navigator] stack rather than
/// go_router's `context.canPop()`: with this app's [StatefulShellRoute], the
/// go_router helper does not reliably report "nothing to pop" for a top-level
/// route opened directly by a deep link, so it would pop the only page and go
/// black. `Navigator.of(context).canPop()` reflects the actual page stack (and
/// is the same check the in-file Select button already relies on).
void safeBack(BuildContext context) {
  final NavigatorState navigator = Navigator.of(context);
  if (navigator.canPop()) {
    navigator.pop();
  } else {
    context.go('/home');
  }
}

/// Wraps a top-level route (one pinned to the root navigator, sitting above the
/// [AppShell]) so the Android system back button can never empty the navigator.
///
/// Reached in-app via `context.push(...)` there is a route beneath to pop back
/// to; reached via a cold-start deep link the wrapped screen can be the only
/// page on the stack. [safeBack] handles both: it pops when there is history
/// and only routes to `/home` when the stack would otherwise empty.
///
/// When there is history, popping is left allowed rather than intercepted: a
/// `PopScope(canPop: false)` also disables the swipe-from-the-edge back
/// gesture, and pushed pages should be swipeable back to where they came from.
/// Only the deep-linked, only-page-on-the-stack case is intercepted, mirroring
/// the `PopScope(canPop: false, ...)` pattern used by the shell and the wizard.
class RootPopScope extends StatelessWidget {
  const RootPopScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.of(context).canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        safeBack(context);
      },
      child: child,
    );
  }
}
