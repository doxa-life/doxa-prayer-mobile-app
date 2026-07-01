/// Computes the feedback page route (path + query) for a given app [lang],
/// optional [trackingId], and optional [device] diagnostics.
///
/// The feedback form is hosted on the campaigns server, which localizes routes
/// with i18n's `prefix_except_default` strategy: English lives at `/feedback`
/// and every other locale is path-prefixed (e.g. `/es/feedback`). The app's
/// `lang` is also sent as a query param, `tracking_id` (when known) links the
/// feedback to the user's existing subscriber, and [device] entries (platform,
/// OS version, model, app version/build, timezone) are merged in for staff
/// diagnostics.
///
/// Kept free of `ApiConfig`/platform dependencies so it stays a pure,
/// unit-testable function; the caller composes the result with the resolved
/// host and launches it.
({String path, Map<String, String> query}) feedbackRoute(
  String lang,
  String? trackingId, [
  Map<String, String> device = const {},
]) {
  return (
    path: lang == 'en' ? '/feedback' : '/$lang/feedback',
    query: {
      'lang': lang,
      'tracking_id': ?trackingId,
      ...device,
    },
  );
}
