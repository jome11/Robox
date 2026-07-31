import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/financial_record.dart';

class FinancialComparisonChart extends StatelessWidget {
  final List<FinancialRecord> data;

  const FinancialComparisonChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    // Scale values to millions for better display
    final List<FlSpot> incomeSpots = [];
    final List<FlSpot> expenseSpots = [];

    for (int i = 0; i < data.length; i++) {
      incomeSpots.add(FlSpot(i.toDouble(), data[i].income / 1000000));
      expenseSpots.add(FlSpot(i.toDouble(), data[i].expense / 1000000));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                final index = value.toInt();
                if (index < 0 || index >= months.length) return const Text('');
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(months[index], style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          // Income Line (Blue)
          LineChartBarData(
            spots: incomeSpots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withAlpha(20),
            ),
          ),
          // Expense Line (Red)
          LineChartBarData(
            spots: expenseSpots,
            isCurved: true,
            color: AppColors.error,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.error.withAlpha(20),
            ),
          ),
        ],
      ),
    );
  }
}
