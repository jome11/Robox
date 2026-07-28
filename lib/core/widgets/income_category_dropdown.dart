import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../data/models/transaction_model.dart';

/// Dropdown for picking an income category, with a text field that appears
/// when "Other" is selected so the user can type a custom category.
class IncomeCategoryDropdown extends StatelessWidget {
  final IncomeCategory? selected;
  final TextEditingController customController;
  final ValueChanged<IncomeCategory?> onChanged;

  const IncomeCategoryDropdown({
    super.key,
    required this.selected,
    required this.customController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
              hint: Text('Select a category', style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
              style: AppTextStyles.body,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
              items: IncomeCategory.values
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.label, style: AppTextStyles.body)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        if (selected == IncomeCategory.other) ...[
          const SizedBox(height: 12),
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
