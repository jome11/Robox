import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/leaderboard_entry_model.dart';
import '../../../../data/repositories/leaderboard_repository.dart';
import '../../../auth/bloc/auth_bloc.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<LeaderboardEntryModel> _entries = [];
  bool _isLoading = true;
  String? _error;

  static const _medals = ['🥇', '🥈', '🥉'];

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = context.read<LeaderboardRepository>();
      final entries = await repo.getLeaderboard();
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load rankings. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final currentUserId = authState is AuthAuthenticated ? authState.user.id : null;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchLeaderboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Team Rankings', style: AppTextStyles.headline),
              const SizedBox(height: 4),
              Text('Tasks completed · this month',
                  style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 20),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Column(
                      children: [
                        Text(_error!, style: AppTextStyles.body.copyWith(color: Colors.red)),
                        const SizedBox(height: 12),
                        TextButton(onPressed: _fetchLeaderboard, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              else if (_entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text('No rankings available yet.',
                        style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
                  ),
                )
              else ...[
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
                                  child: Text(_entries[i].userName.split(' ').first,
                                      style: AppTextStyles.label),
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
                              color: entry.userId == currentUserId
                                  ? AppColors.primary
                                  : AppColors.secondary,
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
                  final isYou = entry.userId == currentUserId;
                  final initials = entry.userName
                      .split(' ')
                      .where((s) => s.isNotEmpty)
                      .map((p) => p[0])
                      .take(2)
                      .join();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isYou
                          ? AppColors.primary.withAlpha((0.1 * 255).toInt())
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isYou ? AppColors.primary : AppColors.border),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          child: index < 3
                              ? Text(_medals[index], style: const TextStyle(fontSize: 18))
                              : Text('#${entry.rank}',
                                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.secondary,
                          child: Text(initials,
                              style: AppTextStyles.body.copyWith(
                                  color: AppColors.onSecondary, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      entry.userName,
                                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isYou) ...[
                                    const SizedBox(width: 6),
                                    Text('YOU',
                                        style: AppTextStyles.label.copyWith(color: AppColors.primary)),
                                  ],
                                ],
                              ),
                              Text('${entry.efficiency.toStringAsFixed(0)}% efficiency',
                                  style: AppTextStyles.label),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${entry.tasksCompleted}',
                                style: AppTextStyles.headline.copyWith(fontSize: 18)),
                            Text('TASKS', style: AppTextStyles.label),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
