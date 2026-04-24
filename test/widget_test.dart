import 'package:flutter_test/flutter_test.dart';

import 'package:doxa_prayer_mobile_app/main.dart';

void main() {
  testWidgets('Gallery screen renders without exceptions', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Component Gallery'), findsWidgets);
    expect(find.text('Colours'), findsOneWidget);
    expect(find.text('Typography'), findsOneWidget);
    expect(find.text('Action buttons'), findsOneWidget);
  });
}
