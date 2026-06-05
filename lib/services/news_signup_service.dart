import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../components/widgets/news_signup.dart';
import 'api_config.dart';
import 'identity_service.dart';
import 'locale_controller.dart';
import 'selected_people_group_controller.dart';

Future<void> submitNewsSignup(NewsSignupData data) async {
  final body = jsonEncode({
    'email': data.email,
    'name': data.name,
    'consent_doxa_general': data.wantsDoxaUpdates,
    'consent_people_group_updates': data.wantsPeopleGroupUpdates,
    'people_group_slug': selectedPeopleGroupController.value?.slug ?? '',
    'country': '',
    'language': localeController.value.languageCode,
    'tracking_id': identityController.value?.trackingId ?? '',
  });

  final uri = ApiConfig.buildUri('/api/news-signup');

  if (!kReleaseMode && !ApiConfig.hasAppSecret) {
    developer.log(
      'Skipping news-signup POST (dev build, no ANON_SIGNUP_SECRET)\n'
      'URL: $uri\n'
      'Body: $body',
      name: 'news_signup_service',
    );
    return;
  }

  developer.log(
    'POST news-signup\nURL: $uri\nBody: $body',
    name: 'news_signup_service',
  );
  final response = await http.post(
    uri,
    headers: ApiConfig.signupHeaders,
    body: body,
  );
  developer.log(
    'news-signup response\nStatus: ${response.statusCode}\nBody: ${response.body}',
    name: 'news_signup_service',
  );
  if (response.statusCode != 200) {
    throw Exception('news-signup failed (${response.statusCode})');
  }
  final json = jsonDecode(response.body) as Map<String, dynamic>;
  await setIdentity(
    trackingId: json['tracking_id'] as String?,
    profileId: json['profile_id'] as String?,
  );
}
