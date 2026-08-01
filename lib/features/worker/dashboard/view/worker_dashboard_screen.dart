import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/stat_strip.dart';
import '../../../../core/widgets/priority_tag.dart';
import '../../../../data/models/task_model.dart';
import '../../../../data/repositories/task_repository.dart';
import '../../../auth/bloc/auth_bloc.dart';

class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  final TaskRepository _taskRepository = TaskRepositoryImpl();

  List<TaskModel> _activeTasks = [];
  int _doneCount = 0;
  double _efficiency = 0.0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final allTasks = await _taskRepository.getTasks();
      print('WORKER_DASH_DEBUG: Total tasks fetched: ${allTasks.length}');

      if (!mounted) return;
      setState(() {
        _activeTasks = allTasks.where((t) {
          final isActive = t.status != TaskStatus.completed;
          print('WORKER_DASH_DEBUG: Task "${t.title}" status: ${t.status}, IsActive? $isActive');
          return isActive;
        }).toList();
        
        _doneCount = allTasks.where((t) => t.status == TaskStatus.completed).length;
        print('WORKER_DASH_DEBUG: Active count: ${_activeTasks.length}, Done count: $_doneCount');

        if (allTasks.isNotEmpty) {
          _efficiency = (_doneCount / allTasks.length) * 100;
        } else {
          _efficiency = 0.0;
        }

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load dashboard. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final name = authState is AuthAuthenticated ? authState.user.name : 'there';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back,', style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
              Text(name, style: AppTextStyles.headline),
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
                        TextButton(onPressed: _loadData, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              else ...[
                StatStrip(items: [
                  StatStripItem(
                    value: '$_doneCount',
                    label: 'Done',
                    icon: Icons.check_circle_outline,
                    accentColor: AppColors.primary,
                  ),
                  StatStripItem(
                    value: '${_efficiency.toStringAsFixed(0)}%',
                    label: 'Efficiency',
                    icon: Icons.bolt_outlined,
                    accentColor: AppColors.secondary,
                  ),
                  StatStripItem(
                    value: '${_activeTasks.length}',
                    label: 'Active',
                    icon: Icons.pending_actions_outlined,
                    accentColor: AppColors.warning,
                  ),
                ]),
                const SizedBox(height: 24),

                Text('ASSIGNED TO ME', style: AppTextStyles.label),
                const SizedBox(height: 12),
                if (_activeTasks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text('No active tasks assigned.',
                          style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
                    ),
                  )
                else
                  ..._activeTasks.map((task) => _AssignedTaskCard(task: task)),
              ],
            ],
          ),
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
              Expanded(
                  child: Text(task.title,
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600))),
              PriorityTag(priority: task.priority),
            ],
          ),
          const SizedBox(height: 4),
          Text(
              'Due ${task.deadline.year}-${task.deadline.month.toString().padLeft(2, '0')}-${task.deadline.day.toString().padLeft(2, '0')}',
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
