import 'package:flutter/material.dart';

import '../components/misc/background_image_container.dart';
import '../components/wizard/wizard_progress.dart';
import '../components/misc/triangle_icon.dart';
import '../components/wizard/wizard_step_group_intro.dart';
import '../components/wizard/wizard_step_group_picked.dart';
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
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Scaffold(
            // Steps keep their content in scroll views and let the keyboard
            // overlay them (with matching scroll padding), instead of shrinking
            // the layout — which at large font scales would clip the steps.
            resizeToAvoidBottomInset: false,
            backgroundColor: (_controller.step == WizardStep.welcome)
                ? Colors.white
                : Colors.transparent,
            body: SafeArea(
              child: PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, _) {
                  if (didPop) return;
                  if (_controller.canGoBack) _controller.back();
                },
                child: PageContainer(
                  horizontalPadding: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // On-screen back for every step but welcome. The
                      // system back gesture alone left iPhone users with no
                      // way back. Mirrors DetailsNavBar's arrow.
                      if (_controller.canGoBack)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: IconButton(
                              icon: TriangleIcon(
                                color: Theme.of(context).colorScheme.onSurface,
                                direction:
                                    Directionality.of(context) ==
                                        TextDirection.rtl
                                    ? TriangleDirection.right
                                    : TriangleDirection.left,
                                size: 12,
                              ),
                              tooltip: MaterialLocalizations.of(
                                context,
                              ).backButtonTooltip,
                              onPressed: _controller.back,
                            ),
                          ),
                        ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          // Top-aligned (the default centers): a step taller
                          // than the viewport must clip at the bottom only,
                          // never push its header off the top of the screen.
                          layoutBuilder: (currentChild, previousChildren) =>
                              Stack(
                                alignment: Alignment.topCenter,
                                children: [...previousChildren, ?currentChild],
                              ),
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
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStep() {
    switch (_controller.step) {
      case WizardStep.welcome:
        return WizardStepWelcome(controller: _controller);
      case WizardStep.groupIntro:
        return WizardStepGroupIntro(controller: _controller);
      case WizardStep.peopleGroupsList:
        return WizardStepPeopleGroups(controller: _controller);
      case WizardStep.peopleGroupConfirm:
        return WizardStepPeopleGroupConfirm(controller: _controller);
      case WizardStep.groupPicked:
        return WizardStepGroupPicked(controller: _controller);
      case WizardStep.reminder:
        return WizardStepReminder(controller: _controller);
      case WizardStep.newsSignup:
        return WizardStepNewsSignup(controller: _controller);
    }
  }
}
