import 'package:doxa_prayer_mobile_app/components/wizard/wizard_step_people_group_confirm.dart';
import 'package:doxa_prayer_mobile_app/models/people_group.dart';
import 'package:doxa_prayer_mobile_app/services/wizard_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_at_scale.dart';

const _group = PeopleGroup(
  name: 'Kurds',
  slug: 'kurds',
  imageUrl: null, // Placeholder image, so the test needs no network.
  countryLabel: null,
  religionLabel: null,
  peoplePraying: 0,
);

void main() {
  late WizardController controller;

  setUp(() {
    controller = WizardController()..proposePeopleGroup(_group);
  });

  tearDown(() => controller.dispose());

  for (final scale in [2.0, 3.0]) {
    testWidgets('buttons stay reachable at ${scale}x font scale', (
      tester,
    ) async {
      await pumpAtScale(
        tester,
        WizardStepPeopleGroupConfirm(controller: controller),
        scale: scale,
      );

      // No RenderFlex overflow at large font scales.
      expect(tester.takeException(), isNull);

      // The bottom-pinned buttons can be scrolled into view and tapped
      // (ActionButton uppercases its label).
      final back = find.text('BACK');
      await tester.ensureVisible(back);
      await tester.pumpAndSettle();
      await tester.tap(back);
      expect(controller.step, WizardStep.peopleGroupsList);
    });
  }
}
