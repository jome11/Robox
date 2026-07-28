import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/robox_button.dart';
import '../../../../data/models/task_model.dart';

class TaskAllocationScreen extends StatefulWidget {
  const TaskAllocationScreen({super.key});

  @override
  State<TaskAllocationScreen> createState() => _TaskAllocationScreenState();
}

class _TaskAllocationScreenState extends State<TaskAllocationScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;

  // Mock worker list — replace with repository data later.
  final List<String> _workers = ['Unit_X4', 'S. Petrov', 'L. Chen', 'Sasha L.'];
  final Set<String> _selectedWorkers = {};

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
            Text('Set the details and assign the task to a team member.', style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 20),

            Text('TASK TITLE', style: AppTextStyles.label),
            const SizedBox(height: 8),
            _StyledField(controller: _titleController, hint: 'e.g., Filament Restock'),
            const SizedBox(height: 16),

            Text('DESCRIPTION', style: AppTextStyles.label),
            const SizedBox(height: 8),
            _StyledField(controller: _descriptionController, hint: 'Describe the task objective...', maxLines: 3),
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
                        border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                      ),
                      child: Text(
                        _priorityLabel(p),
                        style: AppTextStyles.label.copyWith(color: selected ? AppColors.onPrimary : AppColors.textMuted),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            Text('ASSIGN TO (${_selectedWorkers.length} selected)', style: AppTextStyles.label),
            const SizedBox(height: 8),
            ..._workers.map((worker) {
              final selected = _selectedWorkers.contains(worker);
              return CheckboxListTile(
                value: selected,
                onChanged: (v) => setState(() {
                  if (v == true) {
                    _selectedWorkers.add(worker);
                  } else {
                    _selectedWorkers.remove(worker);
                  }
                }),
                title: Text(worker, style: AppTextStyles.body),
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
                    label: 'Assign Task',
                    onPressed: () {
                      // TODO: wire up to task repository once backend exists.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Task assigned')),
                      );
                    },
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }
}
