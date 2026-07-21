import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'device_context_service.dart';
import 'identity_service.dart';
import 'locale_controller.dart';

/// The three feedback categories the campaigns server accepts. Serialised to
/// the snake-case values the `/api/feedback` endpoint validates against.
enum FeedbackType {
  compliment,
  suggestion,
  problem;

  String get apiValue => name;
}

/// The user-entered feedback, ready to submit.
class FeedbackData {
  const FeedbackData({
    required this.type,
    required this.name,
    required this.email,
    required this.message,
    required this.wantsDoxaUpdates,
  });

  final FeedbackType type;
  final String name;
  final String email;
  final String message;
  final bool wantsDoxaUpdates;
}

/// Thrown when the feedback endpoint rejects the submission because the IP has
/// hit its hourly rate limit (HTTP 429), so the UI can show a tailored message.
class FeedbackRateLimitedException implements Exception {
  const FeedbackRateLimitedException();
}

/// Submits [data] to the campaigns server's `POST /api/feedback` endpoint,
/// attaching the app's `tracking_id`, locale, and device diagnostics so staff
/// can link the feedback to the right subscriber (mirrors the hosted web form).
///
/// Throws [FeedbackRateLimitedException] on HTTP 429, or a generic [Exception]
/// on any other non-200 response.
Future<void> submitFeedback(FeedbackData data) async {
  final device = await gatherDeviceContext();
  final body = jsonEncode({
    'feedback_type': data.type.apiValue,
    'name': data.name,
    'email': data.email,
    'message': data.message,
    'consent_doxa_general': data.wantsDoxaUpdates,
    'language': localeController.value.languageCode,
    'tracking_id': identityController.value?.trackingId ?? '',
    'device': device,
  });

  final uri = ApiConfig.buildUri('/api/feedback');

  if (!kReleaseMode && !ApiConfig.hasAppSecret) {
    developer.log(
      'Skipping feedback POST (dev build, no ANON_SIGNUP_SECRET)\n'
      'URL: $uri\n'
      'Body: $body',
      name: 'feedback_service',
    );
    return;
  }

  developer.log('POST feedback\nURL: $uri\nBody: $body', name: 'feedback_service');
  final response = await http.post(
    uri,
    headers: ApiConfig.signupHeaders,
    body: body,
  );
  developer.log(
    'feedback response\nStatus: ${response.statusCode}\nBody: ${response.body}',
    name: 'feedback_service',
  );
  if (response.statusCode == 429) {
    throw const FeedbackRateLimitedException();
  }
  if (response.statusCode != 200) {
    throw Exception('feedback failed (${response.statusCode})');
  }
}
