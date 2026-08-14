import '../../../../data/models/financial_record.dart';
import '../../../../data/models/transaction_model.dart';

enum ChartViewMode { monthly, weekly }

class DashboardDataHelper {
  static const _monthLabels = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const _fullMonthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  /// Full month name for a 1-12 month number, used in the month picker.
  static String monthName(int month) => _fullMonthNames[month - 1];

  /// One bar per month (Jan-Dec) of [year].
  static List<FinancialRecord> monthlyRecordsForYear(
      List<TransactionModel> transactions,
      int year,
      ) {
    return List.generate(12, (i) {
      final month = i + 1;
      final monthTransactions =
      transactions.where((t) => t.date.year == year && t.date.month == month);

      final income = monthTransactions
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (sum, t) => sum + t.amount);
      final expense = monthTransactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);

      return FinancialRecord(
        date: DateTime(year, month, 1),
        label: _monthLabels[i],
        income: income,
        expense: expense,
      );
    });
  }

  /// One bar per week within [month] of [year]. Weeks are simple 7-day
  /// chunks starting on the 1st (Week 1 = days 1-7, Week 2 = 8-14, etc.),
  /// so the last week of the month may be shorter than 7 days.
  static List<FinancialRecord> weeklyRecordsForMonth(
      List<TransactionModel> transactions,
      int year,
      int month,
      ) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final weekCount = (daysInMonth / 7).ceil();

    return List.generate(weekCount, (i) {
      final startDay = i * 7 + 1;
      final endDay = ((i + 1) * 7).clamp(0, daysInMonth);

      final weekTransactions = transactions.where((t) =>
      t.date.year == year &&
          t.date.month == month &&
          t.date.day >= startDay &&
          t.date.day <= endDay);

      final income = weekTransactions
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (sum, t) => sum + t.amount);
      final expense = weekTransactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);

      return FinancialRecord(
        date: DateTime(year, month, startDay),
        label: 'Wk ${i + 1}',
        income: income,
        expense: expense,
      );
    });
  }
}