class FinancialRecord {
  final DateTime date;
  final String label; // shown on the chart's x-axis, e.g. "Jan" or "Wk 1"
  final double income;
  final double expense;

  FinancialRecord({
    required this.date,
    required this.label,
    required this.income,
    required this.expense,
  });
}