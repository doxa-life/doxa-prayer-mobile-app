import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  ApiConfig._();

  static const String host = 'pray.doxa.life';

  static String get appSecret =>
      dotenv.maybeGet('ANON_SIGNUP_SECRET', fallback: '') ?? '';

  static bool get hasAppSecret => appSecret.isNotEmpty;

  static Map<String, String> get signupHeaders => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (hasAppSecret) 'x-app-secret': appSecret,
  };
}
