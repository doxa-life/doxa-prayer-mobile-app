import 'package:flutter/material.dart';

import '../../services/wizard_controller.dart';
import '../misc/progress_dots.dart';

class WizardProgress extends StatelessWidget {
  const WizardProgress({super.key, required this.controller});

  final WizardController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) =>
          ProgressDots(count: 4, currentIndex: controller.progressIndex),
    );
  }
}
