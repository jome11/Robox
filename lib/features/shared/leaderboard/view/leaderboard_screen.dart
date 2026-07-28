import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/leaderboard_entry_model.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  // Mock data — replace with repository data later. "You" flags the current user's row.
  static final List<LeaderboardEntryModel> _entries = [
    const LeaderboardEntryModel(userId: '1', userName: 'Marcus T.', rank: 1, efficiency: 94.0, tasksCompleted: 42),
    const LeaderboardEntryModel(userId: '2', userName: 'You', rank: 2, efficiency: 91.0, tasksCompleted: 38),
    const LeaderboardEntryModel(userId: '3', userName: 'Olu B.', rank: 3, efficiency: 87.0, tasksCompleted: 35),
    const LeaderboardEntryModel(userId: '4', userName: 'Jamie L.', rank: 4, efficiency: 82.0, tasksCompleted: 29),
    const LeaderboardEntryModel(userId: '5', userName: 'Sam K.', rank: 5, efficiency: 78.0, tasksCompleted: 21),
  ];

  static const _medals = ['🥇', '🥈', '🥉'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Team Rankings', style: AppTextStyles.headline),
            const SizedBox(height: 4),
            Text('Tasks completed · this month', style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: SizedBox(
                height: 160,
                child: BarChart(
                  BarChartData(
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= _entries.length) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(_entries[i].userName.split(' ').first, style: AppTextStyles.label),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(_entries.length, (i) {
                      final entry = _entries[i];
                      return BarChartGroupData(x: i, barRods: [
                        BarChartRodData(
                          toY: entry.tasksCompleted.toDouble(),
                          color: entry.userName == 'You' ? AppColors.primary : AppColors.secondary,
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ]);
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            ...List.generate(_entries.length, (index) {
              final entry = _entries[index];
              final isYou = entry.userName == 'You';
              final initials = entry.userName == 'You'
                  ? 'Y'
                  : entry.userName.split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join();

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isYou ? AppColors.primary.withAlpha((0.1 * 255).toInt()) : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isYou ? AppColors.primary : AppColors.border),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: index < 3
                          ? Text(_medals[index], style: const TextStyle(fontSize: 18))
                          : Text('#${entry.rank}', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.secondary,
                      child: Text(initials, style: AppTextStyles.body.copyWith(color: AppColors.onSecondary, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(entry.userName, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                              if (isYou) ...[
                                const SizedBox(width: 6),
                                Text('YOU', style: AppTextStyles.label.copyWith(color: AppColors.primary)),
                              ],
                            ],
                          ),
                          Text('${entry.efficiency.toStringAsFixed(0)}% efficiency', style: AppTextStyles.label),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${entry.tasksCompleted}', style: AppTextStyles.headline.copyWith(fontSize: 18)),
                        Text('TASKS', style: AppTextStyles.label),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
