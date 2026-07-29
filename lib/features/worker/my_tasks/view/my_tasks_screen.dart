import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/priority_tag.dart';
import '../../../../data/models/task_model.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  // Mock data — replace with repository data later.
  final List<TaskModel> _tasks = [
    TaskModel(
      id: '1',
      title: 'Update client CRM records',
      description: 'Sync all Q2 onboarding contact data into the system.',
      deadline: DateTime.now().add(const Duration(days: 8)),
      priority: TaskPriority.medium,
      status: TaskStatus.inProgress,
      progress: 0.65,
      isGroupTask: true,
    ),
    TaskModel(
      id: '2',
      title: 'Safety inspection — Zone C',
      description: 'Complete walkthrough checklist and photograph all hazards.',
      deadline: DateTime.now().add(const Duration(days: 2)),
      priority: TaskPriority.high,
      status: TaskStatus.inProgress,
      progress: 0.20,
      isGroupTask: false,
    ),
    TaskModel(
      id: '3',
      title: 'Train new technicians on SOP',
      description: 'Walk the new hires through standard operating procedure.',
      deadline: DateTime.now().add(const Duration(days: 1)),
      priority: TaskPriority.high,
      status: TaskStatus.pending,
      progress: 0.0,
      isGroupTask: true,
    ),
  ];

  void _setProgress(int index, double value) {
    final t = _tasks[index];
    setState(() {
      _tasks[index] = TaskModel(
        id: t.id,
        title: t.title,
        description: t.description,
        deadline: t.deadline,
        priority: t.priority,
        status: value >= 1.0 ? TaskStatus.completed : TaskStatus.inProgress,
        progress: value,
      );
    });
  }

  void _showTaskDetails(TaskModel task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PriorityTag(priority: task.priority),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    task.isGroupTask ? 'GROUP TASK' : 'INDIVIDUAL',
                    style: AppTextStyles.label.copyWith(fontSize: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(task.title, style: AppTextStyles.headline),
            const SizedBox(height: 8),
            Text(
              'Deadline: ${task.deadline.year}-${task.deadline.month.toString().padLeft(2, '0')}-${task.deadline.day.toString().padLeft(2, '0')}',
              style: AppTextStyles.label,
            ),
            const Divider(height: 32, color: AppColors.border),
            Text('DESCRIPTION', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Text(task.description, style: AppTextStyles.body),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Tasks', style: AppTextStyles.headline),
            const SizedBox(height: 4),
            Text('${_tasks.length} tasks assigned to you', style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 20),
            ...List.generate(_tasks.length, (index) => GestureDetector(
                  onTap: () => _showTaskDetails(_tasks[index]),
                  child: _TaskCard(
                    task: _tasks[index],
                    onSetProgress: (v) => _setProgress(index, v),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final ValueChanged<double> onSetProgress;

  const _TaskCard({required this.task, required this.onSetProgress});

  static const _steps = [0.25, 0.5, 0.75, 1.0];

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
              PriorityTag(priority: task.priority),
              Text(
                'Due ${task.deadline.year}-${task.deadline.month.toString().padLeft(2, '0')}-${task.deadline.day.toString().padLeft(2, '0')}',
                style: AppTextStyles.label,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(task.title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 4),
          Text(task.description, style: AppTextStyles.label),
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
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('${(task.progress * 100).round()}% complete', style: AppTextStyles.label),
                Wrap(
                  spacing: 6,
                  children: _steps.map((step) {
                    final selected = task.progress >= step;
                    return GestureDetector(
                      onTap: () => onSetProgress(step),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                        ),
                        child: Text(
                          '${(step * 100).round()}%',
                          style: AppTextStyles.label.copyWith(color: selected ? AppColors.primary : AppColors.textMuted),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
