import 'dart:math';
import '../../../../data/models/inventory_item.dart';
import '../../../../data/models/financial_record.dart';

class DashboardDataHelper {
  static List<InventoryItem> getOpeningStock() {
    return [
      InventoryItem(name: 'ENDER 3 V3 KE', quantity: 3, price: 160000),
      InventoryItem(name: 'ENDER 3 V3 PLUS', quantity: 5, price: 230000),
      InventoryItem(name: 'ENDER-5 MAX', quantity: 20, price: 350000),
      InventoryItem(name: 'K2 PLUS', quantity: 3, price: 460000),
      InventoryItem(name: 'PLA FILAMENT', quantity: 1200, price: 7200),
      InventoryItem(name: 'ABS FILAMENT', quantity: 120, price: 8500),
      InventoryItem(name: 'PETG FILAMENT', quantity: 120, price: 8500),
      InventoryItem(name: 'TPU FILAMENT', quantity: 60, price: 9800),
    ];
  }

  static double calculateTotalStockValue() {
    return getOpeningStock().fold(0, (sum, item) => sum + item.totalValue);
  }

  static List<FinancialRecord> generateFinancialData() {
    final startValue = calculateTotalStockValue();
    final random = Random();
    final List<FinancialRecord> data = [];
    
    // Total expenses from report: 40664*3 + 60000*5 = 121992 + 300000 = 421992
    // We'll distribute this over time
    const totalExpense = 421992.0;

    for (int i = 0; i < 6; i++) {
      // Income trend: Start at stock value, grow randomly by 5-15% each step
      double income;
      if (i == 0) {
        income = startValue;
      } else {
        final growth = 1.05 + (random.nextDouble() * 0.1);
        income = data[i - 1].income * growth;
      }

      // Expense trend: Randomized fraction of the total expense report
      final expense = (totalExpense / 6) * (0.8 + random.nextDouble() * 0.4);

      data.add(FinancialRecord(
        date: DateTime.now().subtract(Duration(days: (5 - i) * 30)),
        income: income,
        expense: expense,
      ));
    }

    return data;
  }
}
