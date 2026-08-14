import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../data/models/transaction_model.dart';

/// Checklist for picking one or more categories at once, with a checklist
/// of specific types underneath for every checked category that has them
/// (3D Machine Sale, Filament, Classes) — so more than one specific type
/// can be checked too.
class CategoryChecklist extends StatelessWidget {
  final Set<IncomeCategory> selected;
  final Set<String> selectedSubs;
  final TextEditingController customController;
  final ValueChanged<Set<IncomeCategory>> onChanged;
  final ValueChanged<Set<String>> onSubsChanged;

  const CategoryChecklist({
    super.key,
    required this.selected,
    required this.selectedSubs,
    required this.customController,
    required this.onChanged,
    required this.onSubsChanged,
  });

  static const Map<IncomeCategory, List<String>> _subCategories = {
    IncomeCategory.threeDMachineSale: [
      'ENDER 3 V3 KE',
      'ENDER 3 V3 PLUS',
      'ENDER-5 MAX',
      'K2 PLUS',
    ],
    IncomeCategory.filament: [
      'PLA FILAMENT',
      'ABS FILAMENT',
      'PETG FILAMENT',
      'TPU FILAMENT',
    ],
    IncomeCategory.classes: [
      'Solidworks and 3D printing',
    ],
  };

  @override
  Widget build(BuildContext context) {
    // Every checked category that has specific types gets its own section,
    // in the same order as IncomeCategory.values.
    final sectionCategories = IncomeCategory.values
        .where((c) => selected.contains(c) && _subCategories.containsKey(c))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CATEGORIES', style: AppTextStyles.label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: IncomeCategory.values.map((c) {
              final checked = selected.contains(c);
              return CheckboxListTile(
                value: checked,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.primary,
                checkColor: AppColors.onPrimary,
                title: Text(c.label, style: AppTextStyles.body),
                onChanged: (checkedNow) {
                  final next = Set<IncomeCategory>.from(selected);
                  if (checkedNow == true) {
                    next.add(c);
                  } else {
                    next.remove(c);
                  }
                  onChanged(next);

                  // Drop specific-type selections that belonged only to a
                  // category that just got unchecked.
                  if (checkedNow != true) {
                    final orphaned = _subCategories[c] ?? const [];
                    if (orphaned.isNotEmpty) {
                      final nextSubs = Set<String>.from(selectedSubs)
                        ..removeAll(orphaned);
                      onSubsChanged(nextSubs);
                    }
                  }
                },
              );
            }).toList(),
          ),
        ),
        for (final category in sectionCategories) ...[
          const SizedBox(height: 16),
          Text(
            sectionCategories.length > 1
                ? 'SPECIFIC TYPE · ${category.label.toUpperCase()}'
                : 'SPECIFIC TYPE',
            style: AppTextStyles.label,
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _subCategories[category]!.map((s) {
                final checked = selectedSubs.contains(s);
                return CheckboxListTile(
                  value: checked,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.primary,
                  checkColor: AppColors.onPrimary,
                  title: Text(s, style: AppTextStyles.body),
                  onChanged: (checkedNow) {
                    final next = Set<String>.from(selectedSubs);
                    if (checkedNow == true) {
                      next.add(s);
                    } else {
                      next.remove(s);
                    }
                    onSubsChanged(next);
                  },
                );
              }).toList(),
            ),
          ),
        ],
        if (selected.contains(IncomeCategory.other)) ...[
          const SizedBox(height: 16),
          Text('CUSTOM CATEGORY', style: AppTextStyles.label),
          const SizedBox(height: 8),
          TextField(
            controller: customController,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              hintText: 'Enter category name',
              hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ],
    );
  }
}