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

    // Scale to millions for readable bar heights, same as before.
    double maxVal = 0;
    for (final record in data) {
      if (record.income / 1000000 > maxVal) maxVal = record.income / 1000000;
      if (record.expense / 1000000 > maxVal) maxVal = record.expense / 1000000;
    }
    final chartMax = maxVal == 0 ? 1.0 : maxVal * 1.2;

    return BarChart(
      BarChartData(
        maxY: chartMax,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const Text('');
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(data[index].label,
                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(data.length, (i) {
          final record = data[i];
          return BarChartGroupData(
            x: i,
            barsSpace: 4,
            barRods: [
              BarChartRodData(
                toY: record.income / 1000000,
                color: AppColors.primary,
                width: 8,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
              ),
              BarChartRodData(
                toY: record.expense / 1000000,
                color: AppColors.error,
                width: 8,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
              ),
            ],
          );
        }),
      ),
    );
  }
}
