import 'package:flutter/material.dart';
import '../../data/models/task_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PriorityTag extends StatelessWidget {
  final TaskPriority priority;

  const PriorityTag({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (priority) {
      case TaskPriority.high:
        color = AppColors.error;
        text = 'HIGH';
        break;
      case TaskPriority.medium:
        color = AppColors.warning;
        text = 'MED';
        break;
      case TaskPriority.low:
        color = AppColors.primary;
        text = 'LOW';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        text,
        style: AppTextStyles.label.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
