import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../data/models/task_model.dart';

/// Pill tag for task priority — LOW (muted), STANDARD (orange), CRITICAL (pink).
class PriorityTag extends StatelessWidget {
  final TaskPriority priority;

  const PriorityTag({super.key, required this.priority});

  Color get _color {
    switch (priority) {
      case TaskPriority.high:
        return AppColors.error;
      case TaskPriority.medium:
        return AppColors.warning;
      case TaskPriority.low:
        return AppColors.textMuted;
    }
  }

  String get _label {
    switch (priority) {
      case TaskPriority.high:
        return 'CRITICAL';
      case TaskPriority.medium:
        return 'STANDARD';
      case TaskPriority.low:
        return 'LOW';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withAlpha((0.18 * 255).toInt()),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(_label, style: AppTextStyles.label.copyWith(color: _color)),
    );
  }
}
