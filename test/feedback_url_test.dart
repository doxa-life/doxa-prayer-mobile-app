import 'package:doxa_prayer_mobile_app/services/feedback_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('feedbackRoute', () {
    test('English uses the unprefixed path and carries lang + tracking_id', () {
      final route = feedbackRoute('en', 'abc-123');
      expect(route.path, '/feedback');
      expect(route.query, {'lang': 'en', 'tracking_id': 'abc-123'});
    });

    test('non-English locales are path-prefixed', () {
      expect(feedbackRoute('es', 'id').path, '/es/feedback');
      expect(feedbackRoute('fr', 'id').path, '/fr/feedback');
      expect(feedbackRoute('ar', 'id').path, '/ar/feedback');
    });

    test('non-English locale still sends lang in the query', () {
      final route = feedbackRoute('pt', 'id');
      expect(route.query['lang'], 'pt');
    });

    test('omits tracking_id when it is null', () {
      final route = feedbackRoute('fr', null);
      expect(route.path, '/fr/feedback');
      expect(route.query, {'lang': 'fr'});
      expect(route.query.containsKey('tracking_id'), isFalse);
    });

    test('merges device entries into the query', () {
      final route = feedbackRoute('en', 'tid', {
        'platform': 'ios',
        'os_version': 'iOS 17.2',
        'device_model': 'iPhone14,2',
        'app_version': '1.10.0',
        'app_build': '17',
        'timezone': 'Europe/London',
      });
      expect(route.query, {
        'lang': 'en',
        'tracking_id': 'tid',
        'platform': 'ios',
        'os_version': 'iOS 17.2',
        'device_model': 'iPhone14,2',
        'app_version': '1.10.0',
        'app_build': '17',
        'timezone': 'Europe/London',
      });
    });

    test('an empty device map leaves the query unchanged', () {
      final route = feedbackRoute('en', 'tid', const {});
      expect(route.query, {'lang': 'en', 'tracking_id': 'tid'});
    });

    test('device works alongside a null tracking_id', () {
      final route = feedbackRoute('es', null, {'platform': 'android'});
      expect(route.query, {'lang': 'es', 'platform': 'android'});
    });
  });
}
