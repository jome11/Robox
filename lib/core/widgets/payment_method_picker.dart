import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../data/models/transaction_model.dart';

/// Required single-select picker for how the transaction's money moved.
class PaymentMethodPicker extends StatelessWidget {
  final PaymentMethod? selected;
  final ValueChanged<PaymentMethod> onChanged;

  const PaymentMethodPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PAYMENT METHOD', style: AppTextStyles.label),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PaymentMethod.values.map((method) {
            final isSelected = selected == method;
            return ChoiceChip(
              label: Text(method.label),
              selected: isSelected,
              onSelected: (_) => onChanged(method),
              labelStyle: AppTextStyles.body.copyWith(
                color: isSelected ? AppColors.onPrimary : AppColors.textMuted,
              ),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            );
          }).toList(),
        ),
      ],
    );
  }
}