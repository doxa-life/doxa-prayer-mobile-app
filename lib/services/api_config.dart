import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/services.dart' show appFlavor;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  ApiConfig._();

  /// Production endpoint, used by the `production` flavor and unflavored
  /// release builds.
  static const String _prodHost = 'pray.doxa.life';

  /// Staging endpoint, used by the `staging` flavor.
  static const String _stagingHost =
      'campaigns-server-k4ax-production.up.railway.app';

  /// Local Nuxt dev server default for unflavored debug builds. On a physical
  /// device connected over USB, run `adb reverse tcp:3000 tcp:3000` so the
  /// device's `localhost:3000` is forwarded to the dev machine.
  static const String _debugBase = 'http://localhost:3000';

  /// Compile-time override, set per launch via
  /// `--dart-define=API_BASE_URL=<url>` (see .vscode/launch.json's
  /// "debug (local API)" configuration).
  static const String _dartDefineBase = String.fromEnvironment('API_BASE_URL');

  /// Builds an API URI for [path] (+ optional [queryParameters]).
  ///
  /// Resolution order:
  ///   1. `--dart-define=API_BASE_URL=<url>`, when set — an explicit per-launch
  ///      argument, so it beats everything else.
  ///   2. `API_BASE_URL` in .env, when set. Use it to point any build at a
  ///      different host (e.g. `localhost:3000` for local dev, or a LAN IP)
  ///      without rebuilding.
  ///   3. Build flavor (`appFlavor`): `staging` → staging host, `production` →
  ///      production host. Set via `flutter run/build --flavor <name>`.
  ///   4. Unflavored debug builds → local dev server (`_debugBase`).
  ///   5. Fallback → production over HTTPS.
  static Uri buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final override = _dartDefineBase.isNotEmpty
        ? _dartDefineBase
        : dotenv.maybeGet('API_BASE_URL');
    if (override != null && override.isNotEmpty) {
      return Uri.parse(override)
          .replace(path: path, queryParameters: queryParameters);
    }
    switch (appFlavor) {
      case 'staging':
        return Uri.https(_stagingHost, path, queryParameters);
      case 'production':
        return Uri.https(_prodHost, path, queryParameters);
    }
    if (kDebugMode) {
      return Uri.parse(_debugBase)
          .replace(path: path, queryParameters: queryParameters);
    }
    return Uri.https(_prodHost, path, queryParameters);
  }

  static String get appSecret =>
      dotenv.maybeGet('ANON_SIGNUP_SECRET', fallback: '') ?? '';

  static bool get hasAppSecret => appSecret.isNotEmpty;

  static Map<String, String> get signupHeaders => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (hasAppSecret) 'x-app-secret': appSecret,
  };
}
