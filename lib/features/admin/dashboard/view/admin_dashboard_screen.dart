import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/robox_button.dart';
import '../../../../core/widgets/stat_strip.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../pending_requests/bloc/pending_requests_bloc.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dashboard', style: AppTextStyles.headline),
                    const SizedBox(height: 4),
                    Text('Team and business overview',
                        style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
                  ],
                ),
                BlocBuilder<PendingRequestsBloc, PendingRequestsState>(
                  builder: (context, state) {
                    if (state is PendingRequestsLoaded && state.requests.isNotEmpty) {
                      return GestureDetector(
                        onTap: () => context.push('/admin/pending-requests'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person_add_alt_1, size: 16, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                '${state.requests.length} PENDING',
                                style: AppTextStyles.label.copyWith(color: Colors.white, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            const StatStrip(items: [
              StatStripItem(value: '12', label: 'Active Tasks', icon: Icons.assignment_outlined, accentColor: AppColors.primary),
              StatStripItem(value: '91%', label: 'Team Efficiency', icon: Icons.bolt_outlined, accentColor: AppColors.secondary),
              StatStripItem(value: '6', label: 'Workers', icon: Icons.groups_outlined, accentColor: AppColors.warning),
            ]),
            const SizedBox(height: 24),

            Text('FINANCIAL OVERVIEW', style: AppTextStyles.label),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 3),
                          FlSpot(2, 4),
                          FlSpot(4, 3.5),
                          FlSpot(6, 5),
                          FlSpot(8, 4.5),
                          FlSpot(10, 6),
                        ],
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withAlpha((0.12 * 255).toInt()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            RoboxButton(label: 'Allocate New Task', onPressed: () {}),
            const SizedBox(height: 24),

            Text('ACTIVE TASK GROUPS', style: AppTextStyles.label),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Project Delta ${index + 1}', style: AppTextStyles.body),
                          Text('4 active members', style: AppTextStyles.label),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
