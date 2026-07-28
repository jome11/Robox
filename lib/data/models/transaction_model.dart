enum TransactionType { income, expense }

/// Preset income categories. `other` lets the user type a custom label,
/// stored in [TransactionModel.customCategory].
enum IncomeCategory {
  threeDPrint,
  filament,
  threeDMachineSale,
  other;

  String get label {
    switch (this) {
      case IncomeCategory.threeDPrint:
        return '3D Print';
      case IncomeCategory.filament:
        return 'Filament';
      case IncomeCategory.threeDMachineSale:
        return '3D Machine Sale';
      case IncomeCategory.other:
        return 'Other';
    }
  }
}

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final IncomeCategory? category; // only set when type == income
  final String? customCategory; // set when category == other

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    this.category,
    this.customCategory,
  });

  /// Display label for the category, falling back to the custom text.
  String? get categoryLabel {
    if (category == null) return null;
    if (category == IncomeCategory.other) {
      return (customCategory == null || customCategory!.isEmpty) ? 'Other' : customCategory;
    }
    return category!.label;
  }
}
