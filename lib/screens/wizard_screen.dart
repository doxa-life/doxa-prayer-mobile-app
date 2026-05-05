import 'package:flutter/material.dart';

import '../components/misc/background_image_container.dart';
import '../components/wizard/wizard_progress.dart';
import '../components/wizard/wizard_step_news_signup.dart';
import '../components/wizard/wizard_step_people_group_confirm.dart';
import '../components/wizard/wizard_step_people_groups.dart';
import '../components/wizard/wizard_step_reminder.dart';
import '../components/wizard/wizard_step_welcome.dart';
import '../layouts/page_scaffold.dart';
import '../services/wizard_controller.dart';
import '../theme/app_spacing.dart';

class WizardScreen extends StatefulWidget {
  const WizardScreen({super.key});

  @override
  State<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends State<WizardScreen> {
  late final WizardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WizardController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImageContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;
              if (_controller.canGoBack) _controller.back();
            },
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return PageContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: KeyedSubtree(
                            key: ValueKey(_controller.step),
                            child: _buildStep(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.lg,
                        ),
                        child: WizardProgress(controller: _controller),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_controller.step) {
      case WizardStep.welcome:
        return WizardStepWelcome(controller: _controller);
      case WizardStep.peopleGroupsList:
        return WizardStepPeopleGroups(controller: _controller);
      case WizardStep.peopleGroupConfirm:
        return WizardStepPeopleGroupConfirm(controller: _controller);
      case WizardStep.reminder:
        return WizardStepReminder(controller: _controller);
      case WizardStep.newsSignup:
        return WizardStepNewsSignup(controller: _controller);
    }
  }
}
