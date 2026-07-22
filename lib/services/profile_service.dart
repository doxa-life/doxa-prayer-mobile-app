import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'crash_reporting_service.dart';

/// One signed-up email address as returned by the profile endpoint. The [value]
/// is redacted server-side (e.g. `n***@g***.org`); [id] is the contact-method
/// id used to resend verification (the raw address never reaches the app).
class SignedUpEmail {
  const SignedUpEmail({
    required this.id,
    required this.value,
    required this.verified,
  });

  final int id;
  final String value;
  final bool verified;

  factory SignedUpEmail.fromJson(Map<String, dynamic> json) => SignedUpEmail(
    id: json['id'] as int,
    value: (json['value'] as String?) ?? '',
    verified: (json['verified'] as bool?) ?? false,
  );
}

/// Outcome of a resend-verification request, so the UI can respond precisely.
enum ResendVerificationStatus { sent, alreadyVerified, cooldown, failed }

class ResendVerificationResult {
  const ResendVerificationResult(this.status, {this.retryAfterSeconds});

  final ResendVerificationStatus status;

  /// Seconds to wait before retrying, when [status] is [ResendVerificationStatus.cooldown].
  final int? retryAfterSeconds;
}

/// Fetches the signed-up email addresses (with verification status) for the
/// given web profile id.
Future<List<SignedUpEmail>> fetchProfileEmails(String profileId) async {
  final uri = ApiConfig.buildUri('/api/profile/$profileId');
  final response = await http.get(uri, headers: ApiConfig.signupHeaders);
  if (response.statusCode != 200) {
    throw Exception('profile fetch failed (${response.statusCode})');
  }
  final json = jsonDecode(response.body) as Map<String, dynamic>;
  final emails = (json['emails'] as List<dynamic>? ?? [])
      .map((e) => SignedUpEmail.fromJson(e as Map<String, dynamic>))
      .toList();
  return emails;
}

/// Fetches the subscriber's full (non-redacted) primary email for [profileId],
/// or null when unavailable. Unlike the [SignedUpEmail.value] list — which is
/// redacted server-side — the profile endpoint returns the primary email in
/// plaintext under `subscriber.email`, so it can pre-fill the feedback form.
/// Best-effort: never throws; any network/parse issue maps to null.
Future<String?> fetchPrimaryEmail(String profileId) async {
  try {
    final uri = ApiConfig.buildUri('/api/profile/$profileId');
    final response = await http.get(uri, headers: ApiConfig.signupHeaders);
    if (response.statusCode != 200) return null;
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final subscriber = json['subscriber'] as Map<String, dynamic>?;
    final email = (subscriber?['email'] as String?)?.trim();
    return (email == null || email.isEmpty) ? null : email;
  } catch (e, s) {
    reportError(e, s, reason: 'fetch primary email failed');
    return null;
  }
}

/// Re-sends the verification email for [contactMethodId] belonging to the given
/// profile. Never throws — network/parse issues map to [ResendVerificationStatus.failed].
Future<ResendVerificationResult> resendVerification(
  String profileId,
  int contactMethodId,
) async {
  try {
    final uri = ApiConfig.buildUri('/api/profile/$profileId/resend-verification');
    final response = await http.post(
      uri,
      headers: ApiConfig.signupHeaders,
      body: jsonEncode({'contact_method_id': contactMethodId}),
    );

    if (response.statusCode == 429) {
      int? retryAfter;
      try {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>?;
        retryAfter = (data?['retryAfterSeconds'] as num?)?.toInt();
      } catch (_) {
        // Body may not carry structured data; fall back to no explicit delay.
      }
      return ResendVerificationResult(
        ResendVerificationStatus.cooldown,
        retryAfterSeconds: retryAfter,
      );
    }

    if (response.statusCode != 200) {
      return const ResendVerificationResult(ResendVerificationStatus.failed);
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['alreadyVerified'] == true) {
      return const ResendVerificationResult(
        ResendVerificationStatus.alreadyVerified,
      );
    }
    return const ResendVerificationResult(ResendVerificationStatus.sent);
  } catch (e, s) {
    reportError(e, s, reason: 'resend-verification failed');
    return const ResendVerificationResult(ResendVerificationStatus.failed);
  }
}

/// The public web profile URL for [profileId], resolved to the same host as the
/// API (production/staging/local).
Uri profileWebUri(String profileId) =>
    ApiConfig.buildUri('/subscriber', {'id': profileId});
