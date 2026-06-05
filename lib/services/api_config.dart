import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  ApiConfig._();

  /// Production endpoint, used by release/profile builds.
  static const String _prodHost = 'pray.doxa.life';

  /// Local Nuxt dev server default for debug builds. On a physical device
  /// connected over USB, run `adb reverse tcp:3000 tcp:3000` so the device's
  /// `localhost:3000` is forwarded to the dev machine.
  static const String _debugBase = 'http://localhost:3000';

  /// Builds an API URI for [path] (+ optional [queryParameters]).
  ///
  /// Resolution order:
  ///   1. `API_BASE_URL` in .env, when set — overrides everything. Use it to
  ///      point a debug build at the live site (`https://pray.doxa.life`) or a
  ///      different host (e.g. a LAN IP) without rebuilding.
  ///   2. Debug builds → local dev server (`_debugBase`).
  ///   3. Release/profile builds → production over HTTPS.
  static Uri buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final override = dotenv.maybeGet('API_BASE_URL');
    if (override != null && override.isNotEmpty) {
      return Uri.parse(override)
          .replace(path: path, queryParameters: queryParameters);
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
