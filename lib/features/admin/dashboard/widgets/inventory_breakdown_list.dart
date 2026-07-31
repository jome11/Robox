import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/inventory_item.dart';
import 'package:intl/intl.dart';

class InventoryBreakdownList extends StatelessWidget {
  final List<InventoryItem> items;

  const InventoryBreakdownList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '', decimalDigits: 0);

    return Column(
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      'Qty: ${item.quantity} × ${currencyFormat.format(item.price)}',
                      style: AppTextStyles.label.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              Text(
                currencyFormat.format(item.totalValue),
                style: AppTextStyles.body.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
