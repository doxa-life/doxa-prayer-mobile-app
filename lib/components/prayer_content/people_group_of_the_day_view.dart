import 'package:doxa_prayer_mobile_app/components/misc/people_details.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../models/prayer_content.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../misc/app_image.dart';
import '../misc/titles.dart';

/// Renders the introductory `people_group` block of a prayer-content
/// response — used at the top of the pray screen, and reusable on the
/// people-group details / wizard preview screens.
class PeopleGroupOfTheDayView extends StatelessWidget {
  const PeopleGroupOfTheDayView({
    super.key,
    required this.name,
    required this.data,
  });

  final String name;
  final PeopleGroupBlockData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: AppSpacing.lg,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: AppSpacing.xl,
          children: [
            AppImage(url: data.imageUrl, aspectRatio: 1, size: 96.0),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  H2(name, textAlign: TextAlign.start),
                  Wrap(
                    spacing: AppSpacing.md,
                    children: [
                      PeopleDetailsView(
                        text: '${data.country}',
                        icon: Icons.location_on_outlined,
                      ),
                      PeopleDetailsView(
                        text: '${data.population}',
                        icon: Icons.people_outline,
                      ),
                      PeopleDetailsView(
                        text: '${data.language}',
                        icon: Icons.translate,
                      ),
                      PeopleDetailsView(
                        text: '${data.religion}',
                        icon: Icons.church_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (data.description.isNotEmpty)
          Text(data.description, style: AppTypography.bodyMedium),
      ],
    );
  }
}

class _PictureCreditLine extends StatefulWidget {
  const _PictureCreditLine({required this.parts});

  final List<PictureCredit> parts;

  @override
  State<_PictureCreditLine> createState() => _PictureCreditLineState();
}

class _PictureCreditLineState extends State<_PictureCreditLine> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    for (final part in widget.parts) {
      if (part.link != null && part.link!.isNotEmpty) {
        final recognizer = TapGestureRecognizer()
          ..onTap = () {
            // External link handling is wired up in a future change once a
            // url_launcher dep is added — for now this is a visual cue.
          };
        _recognizers.add(recognizer);
        spans.add(
          TextSpan(
            text: part.text,
            style: TextStyle(
              color: AppColors.secondary,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.secondary,
            ),
            recognizer: recognizer,
          ),
        );
      } else {
        spans.add(TextSpan(text: part.text));
      }
    }
    return Text.rich(
      TextSpan(
        style: AppTypography.caption.copyWith(
          color: AppColors.onSurface.withValues(alpha: 0.6),
        ),
        children: spans,
      ),
      textAlign: TextAlign.center,
    );
  }
}
