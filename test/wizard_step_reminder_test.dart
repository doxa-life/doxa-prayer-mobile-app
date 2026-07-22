import 'package:doxa_prayer_mobile_app/components/wizard/wizard_step_reminder.dart';
import 'package:doxa_prayer_mobile_app/services/wizard_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_at_scale.dart';

void main() {
  late WizardController controller;

  setUp(() => controller = WizardController());

  tearDown(() => controller.dispose());

  for (final scale in [2.0, 3.0]) {
    testWidgets('buttons stay reachable at ${scale}x font scale', (
      tester,
    ) async {
      await pumpAtScale(
        tester,
        WizardStepReminder(controller: controller),
        scale: scale,
      );

      // No RenderFlex overflow at large font scales.
      expect(tester.takeException(), isNull);

      // The bottom-pinned buttons can be scrolled into view and tapped
      // (ActionButton uppercases its label). Skip advances the wizard without
      // touching any platform plugin.
      final previousStep = controller.step;
      final skip = find.text('SKIP');
      await tester.ensureVisible(skip);
      await tester.pumpAndSettle();
      await tester.tap(skip);
      expect(controller.step, isNot(previousStep));
    });
  }
}
