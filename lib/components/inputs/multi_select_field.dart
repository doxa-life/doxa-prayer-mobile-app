import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../buttons/action_button.dart';
import '../misc/hyphenated_text.dart';
import '../misc/titles.dart';
import 'checkbox_field.dart';
import 'search_field.dart';

/// A single choice in a [MultiSelectField]. [groupLabel], when set, renders
/// the option under a section header in the picker sheet — the caller is
/// responsible for pre-sorting [MultiSelectField.options] so options sharing
/// a [groupLabel] are contiguous (the sheet groups by encounter order, not by
/// sorting them itself, so it can preserve a caller-chosen group order).
class MultiSelectOption<T> {
  const MultiSelectOption({
    required this.value,
    required this.label,
    this.groupLabel,
  });

  final T value;
  final String label;
  final String? groupLabel;
}

/// A [SelectField]-alike for choosing zero or more values: looks like a form
/// field, but tapping it opens a picker sheet with checkboxes (optionally
/// grouped into sections, optionally with its own search field) instead of an
/// inline dropdown, since Flutter's dropdown widgets don't support
/// multi-select natively. Used by the people-groups search filters — see
/// docs/v2.md.
class MultiSelectField<T> extends StatelessWidget {
  const MultiSelectField({
    super.key,
    required this.label,
    required this.emptyLabel,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.searchable = false,
  });

  final String label;
  /// Summary text shown when nothing is selected (e.g. "All languages").
  final String emptyLabel;
  final List<MultiSelectOption<T>> options;
  final Set<T> selected;
  final ValueChanged<Set<T>> onChanged;
  final bool searchable;

  String _summary(AppLocalizations l) {
    if (selected.isEmpty) return emptyLabel;
    if (selected.length <= 2) {
      final labels = options
          .where((o) => selected.contains(o.value))
          .map((o) => o.label);
      return labels.join(', ');
    }
    return l.nSelected(selected.length);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () async {
        final result = await showMultiSelectSheet<T>(
          context: context,
          title: label,
          options: options,
          initialSelection: selected,
          searchable: searchable,
        );
        if (result != null) onChanged(result);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          label: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            child: HyphenatedText(label),
          ),
        ),
        child: HyphenatedText(
          _summary(l),
          style: AppTypography.bodyMedium.copyWith(color: scheme.onSurface),
        ),
      ),
    );
  }
}

/// Shows the picker sheet and resolves with the new selection once the user
/// taps Done, or `null` if they dismiss the sheet without confirming (e.g.
/// swiping it away) — the caller should only apply the result when non-null.
Future<Set<T>?> showMultiSelectSheet<T>({
  required BuildContext context,
  required String title,
  required List<MultiSelectOption<T>> options,
  required Set<T> initialSelection,
  bool searchable = false,
}) {
  return showModalBottomSheet<Set<T>>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _MultiSelectSheet<T>(
      title: title,
      options: options,
      initialSelection: initialSelection,
      searchable: searchable,
    ),
  );
}

class _MultiSelectSheet<T> extends StatefulWidget {
  const _MultiSelectSheet({
    required this.title,
    required this.options,
    required this.initialSelection,
    required this.searchable,
  });

  final String title;
  final List<MultiSelectOption<T>> options;
  final Set<T> initialSelection;
  final bool searchable;

  @override
  State<_MultiSelectSheet<T>> createState() => _MultiSelectSheetState<T>();
}

class _MultiSelectSheetState<T> extends State<_MultiSelectSheet<T>> {
  late final Set<T> _selection = {...widget.initialSelection};
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MultiSelectOption<T>> get _filteredOptions {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.options;
    return widget.options
        .where((o) => o.label.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // Groups options under their groupLabel (null = ungrouped), preserving
    // the order groups are first encountered in the (caller-sorted) list.
    final grouped = <String?, List<MultiSelectOption<T>>>{};
    for (final o in _filteredOptions) {
      grouped.putIfAbsent(o.groupLabel, () => []).add(o);
    }
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(child: H2(widget.title)),
                  TextButton(
                    onPressed: _selection.isEmpty
                        ? null
                        : () => setState(_selection.clear),
                    child: HyphenatedText(l.clear),
                  ),
                ],
              ),
              if (widget.searchable) ...[
                const SizedBox(height: AppSpacing.sm),
                SearchField(
                  hint: l.search,
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  onClear: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    for (final entry in grouped.entries) ...[
                      if (entry.key != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          child: HyphenatedText(
                            entry.key!,
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      for (final o in entry.value)
                        CheckboxField(
                          label: o.label,
                          value: _selection.contains(o.value),
                          onChanged: (v) => setState(() {
                            if (v) {
                              _selection.add(o.value);
                            } else {
                              _selection.remove(o.value);
                            }
                          }),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ActionButton(
                label: l.done,
                onPressed: () => Navigator.of(context).pop(_selection),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
