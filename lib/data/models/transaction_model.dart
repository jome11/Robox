enum TransactionType { income, expense }

/// Preset income categories. `other` lets the user type a custom label,
/// stored in [TransactionModel.customCategory]. Multiple categories can be
/// checked at once for a single transaction.
enum IncomeCategory {
  threeDPrint,
  filament,
  threeDMachineSale,
  classes,
  other;

  String get label {
    switch (this) {
      case IncomeCategory.threeDPrint:
        return '3D Print';
      case IncomeCategory.filament:
        return 'Filament';
      case IncomeCategory.threeDMachineSale:
        return '3D Machine Sale';
      case IncomeCategory.classes:
        return 'Classes';
      case IncomeCategory.other:
        return 'Other';
    }
  }
}

/// How the transaction's money moved. Required on every transaction.
enum PaymentMethod {
  cbe,
  telebirr,
  cash,
  otherBank;

  String get label {
    switch (this) {
      case PaymentMethod.cbe:
        return 'CBE';
      case PaymentMethod.telebirr:
        return 'Telebirr';
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.otherBank:
        return 'Other Bank';
    }
  }

  /// Matches a payment method by its display label (e.g. from the backend).
  /// Returns null if nothing matches.
  static PaymentMethod? fromLabel(String? label) {
    if (label == null) return null;
    for (final method in PaymentMethod.values) {
      if (method.label == label) return method;
    }
    return null;
  }
}

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final List<IncomeCategory> categories; // multiple categories may be checked
  final List<String> subCategories; // multiple specific types may be checked
  final String? customCategory; // set when categories contains "other"
  final PaymentMethod? paymentMethod; // required going forward, nullable for old rows
  final int? quantity; // Optional field for stock tracking
  final bool edited; // True if the transaction has been modified
  final String? description;
  final String? addedBy;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    this.categories = const [],
    this.subCategories = const [],
    this.customCategory,
    this.paymentMethod,
    this.quantity,
    this.edited = false,
    this.description,
    this.addedBy,
  });

  /// Display label combining every checked category, falling back to the
  /// custom text for "Other", plus every checked specific type.
  String? get categoryLabel {
    if (categories.isEmpty) return null;

    final labels = categories.map((c) {
      if (c == IncomeCategory.other) {
        return (customCategory == null || customCategory!.isEmpty) ? 'Other' : customCategory!;
      }
      return c.label;
    }).join(', ');

    if (subCategories.isNotEmpty) {
      return '$labels · ${subCategories.join(', ')}';
    }

    return labels;
  }

  /// The description shown to the user, with the exact time the transaction
  /// was logged appended — derived from [date], not stored separately.
  /// Shown in Ethiopian time, where the day starts at dawn (6:00 AM
  /// standard time = 12:00 Ethiopian) rather than at midnight.
  String get descriptionWithTime {
    final timePart = _ethiopianTimeString(date);
    if (description == null || description!.isEmpty) {
      return 'Logged at $timePart';
    }
    return '$description (Logged at $timePart)';
  }

  /// Converts a standard 24-hour clock time to the Ethiopian 12-hour clock,
  /// which runs 6 hours behind the standard clock (dawn = 12:00, dusk =
  /// 12:00) and labels each half of the day instead of using AM/PM.
  static String _ethiopianTimeString(DateTime d) {
    final standardHour = d.hour;
    var ethiopianHour = (standardHour - 6) % 12;
    if (ethiopianHour < 0) ethiopianHour += 12;
    if (ethiopianHour == 0) ethiopianHour = 12;
    final isDaytime = standardHour >= 6 && standardHour < 18;
    final period = isDaytime ? 'Day' : 'Night';
    final minute = d.minute.toString().padLeft(2, '0');
    final second = d.second.toString().padLeft(2, '0');
    return '$ethiopianHour:$minute:$second $period';
  }
}