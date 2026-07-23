import 'package:doxa_prayer_mobile_app/components/cards/engagement_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_at_scale.dart';

void main() {
  // The tick / cross is a text-less CustomPaint icon, so the status a sighted
  // user reads from it must be spoken. It is exposed as its own semantics node
  // (isolated from the label) so screen readers announce the bare status word
  // rather than mangling it at the tail of a combined phrase.
  testWidgets('engagement markers announce their status as a spoken node', (
    tester,
  ) async {
    await pumpAtScale(
      tester,
      const Wrap(
        children: [
          EngagementItem(label: 'Prayer Status', status: EngagementStatus.yes),
          EngagementItem(label: 'Adoption Status', status: EngagementStatus.no),
          EngagementItem(
            label: 'Cross-cultural workers present',
            status: EngagementStatus.partial,
          ),
        ],
      ),
      scale: 1.0,
    );

    // Status words are announced (as their own nodes)...
    expect(find.bySemanticsLabel('Yes'), findsOneWidget);
    expect(find.bySemanticsLabel('No'), findsOneWidget);
    expect(find.bySemanticsLabel('Partial'), findsOneWidget);
    // ...alongside each marker's label.
    expect(find.text('Prayer Status'), findsOneWidget);
    expect(find.text('Adoption Status'), findsOneWidget);
    expect(find.text('Cross-cultural workers present'), findsOneWidget);
  });
}
