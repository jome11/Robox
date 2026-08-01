import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/priority_tag.dart';
import '../../../../data/models/task_model.dart';
import '../../../../data/repositories/task_repository.dart';

class TaskAllocationScreen extends StatefulWidget {
  const TaskAllocationScreen({super.key});

  @override
  State<TaskAllocationScreen> createState() => _TaskAllocationScreenState();
}

class _TaskAllocationScreenState extends State<TaskAllocationScreen> {
  final TaskRepository _taskRepository = TaskRepositoryImpl();
  
  List<TaskModel> _ongoingTasks = [];
  List<TaskModel> _completedTasks = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final tasks = await _taskRepository.getAllTasks();
      if (!mounted) return;
      setState(() {
        _ongoingTasks = tasks.where((t) => t.status != TaskStatus.completed).toList();
        _completedTasks = tasks.where((t) => t.status == TaskStatus.completed).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load tasks. Check your connection.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('TASK OVERVIEW', style: AppTextStyles.label),
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
                    TextButton(onPressed: _fetchTasks, child: const Text('Retry')),
                  ],
                ),
              )
            : TabBarView(
                children: [
                  RefreshIndicator(
                    onRefresh: _fetchTasks,
                    child: _TaskList(tasks: _ongoingTasks),
                  ),
                  RefreshIndicator(
                    onRefresh: _fetchTasks,
                    child: _TaskList(tasks: _completedTasks),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await context.push('/admin/tasks/create');
            _fetchTasks(); // Refresh after coming back from allocation
          },
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: AppColors.onPrimary),
          label: Text('ALLOCATE TASK', style: AppTextStyles.label.copyWith(color: AppColors.onPrimary)),
        ),
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<TaskModel> tasks;

  const _TaskList({required this.tasks});

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
              Text(task.title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                'Assigned to: ${task.assignedWorkers.isEmpty ? "Unassigned" : task.assignedWorkers.map((w) => w.name).join(', ')}',
                style: AppTextStyles.label.copyWith(fontSize: 11),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: task.progress,
                        backgroundColor: AppColors.surfaceHigh,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(task.progress * 100).toInt()}%',
                    style: AppTextStyles.label.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
