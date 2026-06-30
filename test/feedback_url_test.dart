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
  });
}
