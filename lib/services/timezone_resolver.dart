import 'dart:developer' as developer;

import 'package:flutter_timezone/flutter_timezone.dart';

/// The device's IANA timezone, falling back to UTC when the platform lookup
/// fails — every signup and profile update carries one, so this can never
/// throw its way out into a fire-and-forget sync.
Future<String> resolveTimezone({required String logName}) async {
  try {
    return (await FlutterTimezone.getLocalTimezone()).identifier;
  } catch (e) {
    developer.log(
      'failed to resolve local timezone, falling back to UTC',
      name: logName,
      error: e,
    );
    return 'UTC';
  }
}
