import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/priority_tag.dart';
import '../../../../data/models/task_model.dart';
import '../../../auth/bloc/auth_bloc.dart';

class WorkerDashboardScreen extends StatelessWidget {
  const WorkerDashboardScreen({super.key});

  // Mock data — replace with repository data later.
  static final List<TaskModel> _tasks = [
    TaskModel(
      id: '1',
      title: 'Update client CRM records',
      description: 'Sync all Q2 onboarding contact data into the system.',
      deadline: DateTime.now().add(const Duration(days: 8)),
      priority: TaskPriority.medium,
      status: TaskStatus.inProgress,
      progress: 0.65,
    ),
    TaskModel(
      id: '2',
      title: 'Safety inspection — Zone C',
      description: 'Complete walkthrough checklist and photograph all hazards.',
      deadline: DateTime.now().add(const Duration(days: 2)),
      priority: TaskPriority.high,
      status: TaskStatus.inProgress,
      progress: 0.20,
    ),
    TaskModel(
      id: '3',
      title: 'Train new technicians on SOP',
      description: 'Walk the new hires through standard operating procedure.',
      deadline: DateTime.now().add(const Duration(days: 1)),
      priority: TaskPriority.high,
      status: TaskStatus.pending,
      progress: 0.0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final name = authState is AuthAuthenticated ? authState.user.name : 'there';

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back,', style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
            Text(name, style: AppTextStyles.headline),
            const SizedBox(height: 20),

            Row(
              children: const [
                Expanded(child: StatCard(value: '38', label: 'Done', valueColor: AppColors.primary)),
                SizedBox(width: 12),
                Expanded(child: StatCard(value: '91%', label: 'Efficiency', valueColor: AppColors.secondary)),
                SizedBox(width: 12),
                Expanded(child: StatCard(value: '3', label: 'Active', valueColor: AppColors.warning)),
              ],
            ),
            const SizedBox(height: 24),

            Text('ASSIGNED TO ME', style: AppTextStyles.label),
            const SizedBox(height: 12),
            ..._tasks.map((task) => _AssignedTaskCard(task: task)),
          ],
        ),
      ),
    );
  }
}

class _AssignedTaskCard extends StatelessWidget {
  final TaskModel task;

  const _AssignedTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(task.title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600))),
              PriorityTag(priority: task.priority),
            ],
          ),
          const SizedBox(height: 4),
          Text('Due ${task.deadline.year}-${task.deadline.month.toString().padLeft(2, '0')}-${task.deadline.day.toString().padLeft(2, '0')}',
              style: AppTextStyles.label),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: task.progress,
              backgroundColor: AppColors.surfaceHigh,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text('${(task.progress * 100).round()}% complete', style: AppTextStyles.label),
        ],
      ),
    );
  }
}
