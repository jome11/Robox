import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/robox_button.dart';
import '../../../../data/models/task_model.dart';
import '../../../../data/repositories/admin_repository.dart';
import '../../../../data/repositories/task_repository.dart';

class TaskAllocationScreen extends StatefulWidget {
  const TaskAllocationScreen({super.key});

  @override
  State<TaskAllocationScreen> createState() => _TaskAllocationScreenState();
}

class _TaskAllocationScreenState extends State<TaskAllocationScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final AdminRepository _adminRepository = AdminRepositoryImpl();
  final TaskRepository _taskRepository = TaskRepositoryImpl();

  TaskPriority _priority = TaskPriority.medium;
  DateTime? _deadline;

  List<Map<String, String>> _workers = [];
  final Set<String> _selectedWorkers = {}; // stores worker ids now, not names
  bool _isLoadingWorkers = true;
  String? _loadError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    setState(() {
      _isLoadingWorkers = true;
      _loadError = null;
    });
    try {
      final workers = await _adminRepository.getWorkers();
      setState(() {
        _workers = workers;
        _isLoadingWorkers = false;
      });
    } catch (_) {
      setState(() {
        _loadError = 'Could not load workers. Check your connection.';
        _isLoadingWorkers = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _deadline) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  Future<void> _submitTask() async {
    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a deadline')),
      );
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }
    if (_selectedWorkers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one worker')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _taskRepository.createTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        deadline: _deadline!,
        priority: _priority,
        isGroupTask: _selectedWorkers.length > 1,
        workerIds: _selectedWorkers.toList(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task assigned')),
      );
      Navigator.of(context).maybePop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to assign task. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Allocate Task', style: AppTextStyles.headline),
            const SizedBox(height: 4),
            Text('Set the details and assign the task to a team member.',
                style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 20),
            Text('TASK TITLE', style: AppTextStyles.label),
            const SizedBox(height: 8),
            _StyledField(controller: _titleController, hint: 'e.g., Filament Restock'),
            const SizedBox(height: 16),
            Text('DESCRIPTION', style: AppTextStyles.label),
            const SizedBox(height: 8),
            _StyledField(
                controller: _descriptionController,
                hint: 'Describe the task objective...',
                maxLines: 3),
            const SizedBox(height: 16),
            Text('PRIORITY', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Row(
              children: TaskPriority.values.map((p) {
                final selected = _priority == p;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: selected ? AppColors.primary : AppColors.border),
                      ),
                      child: Text(
                        _priorityLabel(p),
                        style: AppTextStyles.label.copyWith(
                            color: selected ? AppColors.onPrimary : AppColors.textMuted),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('DEADLINE', style: AppTextStyles.label),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectDeadline,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _deadline == null
                          ? 'Select task deadline'
                          : DateFormat('yyyy-MM-dd').format(_deadline!),
                      style: AppTextStyles.body.copyWith(
                        color: _deadline == null ? AppColors.textMuted : AppColors.text,
                      ),
                    ),
                    const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('ASSIGN TO (${_selectedWorkers.length} selected)',
                style: AppTextStyles.label),
            const SizedBox(height: 8),
            if (_isLoadingWorkers)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_loadError != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_loadError!,
                        style: AppTextStyles.body.copyWith(color: Colors.red)),
                    const SizedBox(height: 8),
                    TextButton(onPressed: _loadWorkers, child: const Text('Retry')),
                  ],
                ),
              )
            else if (_workers.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text('No workers available yet.',
                      style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
                )
              else
                ..._workers.map((worker) {
                  final id = worker['id']!;
                  final name = worker['name']!;
                  final selected = _selectedWorkers.contains(id);
                  return CheckboxListTile(
                    value: selected,
                    onChanged: (v) => setState(() {
                      if (v == true) {
                        _selectedWorkers.add(id);
                      } else {
                        _selectedWorkers.remove(id);
                      }
                    }),
                    title: Text(name, style: AppTextStyles.body),
                    activeColor: AppColors.primary,
                    checkColor: AppColors.onPrimary,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: RoboxButton(
                    label: 'Cancel',
                    isSecondary: true,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RoboxButton(
                    label: _isSubmitting ? 'Assigning...' : 'Assign Task',
                    onPressed: _isSubmitting ? () {} : _submitTask,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _priorityLabel(TaskPriority p) {
  switch (p) {
    case TaskPriority.low:
      return 'LOW';
    case TaskPriority.medium:
      return 'STANDARD';
    case TaskPriority.high:
      return 'CRITICAL';
  }
}

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _StyledField({required this.controller, required this.hint, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }
}