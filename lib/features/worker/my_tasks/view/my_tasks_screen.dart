import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/priority_tag.dart';
import '../../../../core/widgets/robox_button.dart';
import '../../../../data/models/task_model.dart';
import '../../../../data/repositories/task_repository.dart';
import '../../../auth/bloc/auth_bloc.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  final TaskRepository _taskRepository = TaskRepositoryImpl();

  List<TaskModel> _ongoingTasks = [];
  List<TaskModel> _completedTasks = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        throw Exception('NOT_AUTHENTICATED');
      }
      final currentUserId = authState.user.id.toString();
      print('DEBUG: Current User ID: $currentUserId');

      final tasks = await _taskRepository.getTasks();
      
      // Trust the backend /worker/tasks endpoint to only return relevant tasks.
      // Removed the manual ID filter to prevent issues with ID type mismatches.
      final assignedTasks = tasks;
      
      if (!mounted) return;
      setState(() {
        _ongoingTasks = assignedTasks.where((t) => t.status != TaskStatus.completed).toList();
        _completedTasks = assignedTasks.where((t) => t.status == TaskStatus.completed).toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load your tasks. Check your connection.';
        _isLoading = false;
      });
    }
  }

  Future<void> _setProgress(TaskModel task, double value) async {
    final newStatus = value >= 1.0 ? TaskStatus.completed : TaskStatus.inProgress;

    try {
      await _taskRepository.updateProgress(task.id, value, newStatus);
      _loadTasks(); // Reload all to move between tabs correctly
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update progress. Please try again.')),
      );
    }
  }

  Future<void> _removeTask(TaskModel task) async {
    try {
      await _taskRepository.deleteTask(task.id);
      _loadTasks();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove task. Please try again.')),
      );
    }
  }

  void _showTaskDetails(TaskModel task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
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
              const SizedBox(height: 24),
              if (task.isGroupTask)
                SizedBox(
                  width: double.infinity,
                  child: RoboxButton(
                    label: 'JOIN GROUP CHAT',
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/chat/${task.id}', extra: task.title);
                    },
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('MY TASKS', style: AppTextStyles.label),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            labelStyle: AppTextStyles.label,
            tabs: const [
              Tab(text: 'ONGOING'),
              Tab(text: 'COMPLETED'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, style: AppTextStyles.body.copyWith(color: Colors.red)),
                        const SizedBox(height: 12),
                        TextButton(onPressed: _loadTasks, child: const Text('Retry')),
                      ],
                    ),
                  )
                : TabBarView(
                    children: [
                      RefreshIndicator(
                        onRefresh: _loadTasks,
                        child: _TaskList(
                          tasks: _ongoingTasks,
                          onSetProgress: _setProgress,
                          onShowDetails: _showTaskDetails,
                        ),
                      ),
                      RefreshIndicator(
                        onRefresh: _loadTasks,
                        child: _TaskList(
                          tasks: _completedTasks,
                          onSetProgress: _setProgress,
                          onShowDetails: _showTaskDetails,
                          onRemove: _removeTask,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<TaskModel> tasks;
  final Function(TaskModel, double) onSetProgress;
  final Function(TaskModel) onShowDetails;
  final Function(TaskModel)? onRemove;

  const _TaskList({
    required this.tasks,
    required this.onSetProgress,
    required this.onShowDetails,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Text('No tasks found', style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return GestureDetector(
          onTap: () => onShowDetails(task),
          child: _TaskCard(
            task: task,
            onSetProgress: (v) => onSetProgress(task, v),
            onRemove: onRemove != null ? () => onRemove!(task) : null,
          ),
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final ValueChanged<double> onSetProgress;
  final VoidCallback? onRemove;

  const _TaskCard({required this.task, required this.onSetProgress, this.onRemove});

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
                style: AppTextStyles.label.copyWith(fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(task.title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 4),
          Text(task.description, style: AppTextStyles.label, maxLines: 2, overflow: TextOverflow.ellipsis),
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
                Text('${(task.progress * 100).round()}% complete', style: AppTextStyles.label.copyWith(fontSize: 10)),
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
                          style: AppTextStyles.label.copyWith(color: selected ? AppColors.primary : AppColors.textMuted, fontSize: 10),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: RoboxButton(
                label: 'REMOVE COMPLETED TASK',
                isSecondary: true,
                onPressed: onRemove!,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
