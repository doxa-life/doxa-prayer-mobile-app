import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whether the Pray tab's people-group switcher is expanded.
///
/// The Pray tab owns the switcher but the app bar owns the button that opens
/// it, so the state has to sit outside both.
final ValueNotifier<bool> praySelectorOpen = ValueNotifier<bool>(false);

const _seenKey = 'pray_selector_seen';

/// Whether the switcher has already introduced itself. In memory after the
/// first load so the Pray tab can check it without awaiting on every build.
bool _seen = false;

Future<void> loadPraySelectorSeen() async {
  final prefs = SharedPreferencesAsync();
  _seen = await prefs.getBool(_seenKey) ?? false;
}

/// Opens the switcher the first time someone reaches the Pray tab with more
/// than one group to switch between — the one moment it has to show what it
/// is. After that the tab opens on the prayer content, and the avatar in the
/// app bar is the way back to it.
Future<void> openPraySelectorIfUnseen() async {
  if (_seen) return;
  _seen = true;
  praySelectorOpen.value = true;
  final prefs = SharedPreferencesAsync();
  await prefs.setBool(_seenKey, true);
}

void togglePraySelector() => praySelectorOpen.value = !praySelectorOpen.value;

/// Collapses the switcher. Called when the user starts reading — a scroll or a
/// touch on the prayer content is them saying they are done choosing.
void closePraySelector() {
  if (praySelectorOpen.value) praySelectorOpen.value = false;
}

/// Forgets that the switcher has introduced itself, so it opens once more.
/// Only the debug screen's reset uses this.
Future<void> clearPraySelectorSeen() async {
  _seen = false;
  praySelectorOpen.value = false;
  final prefs = SharedPreferencesAsync();
  await prefs.remove(_seenKey);
}
