import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../data/models/transaction_model.dart';

/// Dropdown for picking an income category, with nested sub-category dropdowns
/// for 3D Machine Sale, Filament, and Classes.
class IncomeCategoryDropdown extends StatelessWidget {
  final IncomeCategory? selected;
  final String? selectedSub;
  final TextEditingController customController;
  final ValueChanged<IncomeCategory?> onChanged;
  final ValueChanged<String?> onSubChanged;

  const IncomeCategoryDropdown({
    super.key,
    required this.selected,
    required this.selectedSub,
    required this.customController,
    required this.onChanged,
    required this.onSubChanged,
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
    final subOptions = _subCategories[selected];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CATEGORY', style: AppTextStyles.label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<IncomeCategory>(
              value: selected,
              isExpanded: true,
              dropdownColor: AppColors.surfaceHigh,
              hint: Text('Select a category',
                  style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
              style: AppTextStyles.body,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
              items: IncomeCategory.values
                  .map((c) => DropdownMenuItem(
                      value: c, child: Text(c.label, style: AppTextStyles.body)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        if (subOptions != null) ...[
          const SizedBox(height: 16),
          Text('SPECIFIC TYPE', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedSub,
                isExpanded: true,
                dropdownColor: AppColors.surfaceHigh,
                hint: Text('Select specific type',
                    style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
                style: AppTextStyles.body,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
                items: subOptions
                    .map((s) => DropdownMenuItem(
                        value: s, child: Text(s, style: AppTextStyles.body)))
                    .toList(),
                onChanged: onSubChanged,
              ),
            ),
          ),
        ],
        if (selected == IncomeCategory.other) ...[
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
