import '../../../../data/models/financial_record.dart';
import '../../../../data/models/transaction_model.dart';

class DashboardDataHelper {
  /// Buckets real transactions into the last 6 months of income vs expense.
  static List<FinancialRecord> financialRecordsFromTransactions(
      List<TransactionModel> transactions,
      ) {
    final now = DateTime.now();

    // Last 6 months, oldest first.
    final months = List.generate(6, (i) {
      final monthsAgo = 5 - i;
      return DateTime(now.year, now.month - monthsAgo, 1);
    });

    return months.map((month) {
      final monthTransactions = transactions.where((t) =>
      t.date.year == month.year && t.date.month == month.month);

      final income = monthTransactions
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (sum, t) => sum + t.amount);

      final expense = monthTransactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);

      return FinancialRecord(date: month, income: income, expense: expense);
    }).toList();
  }
}