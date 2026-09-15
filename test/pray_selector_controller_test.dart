import 'package:doxa_prayer_mobile_app/services/pray_selector_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

Future<void> _reset([Map<String, Object> initial = const {}]) async {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.withData(Map<String, Object>.of(initial));
  praySelectorOpen.value = false;
  await loadPraySelectorSeen();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('opens on the first ask and never again', () async {
    await _reset();

    await openPraySelectorIfUnseen();
    expect(praySelectorOpen.value, isTrue);

    // The user closes it by reading.
    closePraySelector();
    expect(praySelectorOpen.value, isFalse);

    // A later visit must not re-open it.
    await openPraySelectorIfUnseen();
    expect(praySelectorOpen.value, isFalse);
  });

  test('a device that has already seen it never opens it', () async {
    await _reset({'pray_selector_seen': true});
    await openPraySelectorIfUnseen();
    expect(praySelectorOpen.value, isFalse);
  });

  test('having been seen survives a restart', () async {
    await _reset();
    await openPraySelectorIfUnseen();

    // Same storage, fresh load — as a relaunch would do.
    praySelectorOpen.value = false;
    await loadPraySelectorSeen();
    await openPraySelectorIfUnseen();

    expect(praySelectorOpen.value, isFalse);
  });

  test('the avatar button toggles it both ways', () async {
    await _reset();

    togglePraySelector();
    expect(praySelectorOpen.value, isTrue);
    togglePraySelector();
    expect(praySelectorOpen.value, isFalse);
  });

  test('closing an already-closed selector is a no-op', () async {
    await _reset();
    var notified = 0;
    void listener() => notified++;
    praySelectorOpen.addListener(listener);

    closePraySelector();
    expect(notified, 0);

    praySelectorOpen.removeListener(listener);
  });

  test('the debug reset lets it introduce itself again', () async {
    await _reset();
    await openPraySelectorIfUnseen();
    closePraySelector();

    await clearPraySelectorSeen();
    await openPraySelectorIfUnseen();

    expect(praySelectorOpen.value, isTrue);
  });

  tearDown(() => praySelectorOpen.value = false);

  test('the stored flag is what SharedPreferences holds', () async {
    await _reset();
    await openPraySelectorIfUnseen();

    final prefs = SharedPreferencesAsync();
    expect(await prefs.getBool('pray_selector_seen'), isTrue);
  });
}
