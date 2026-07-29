enum TaskPriority { low, medium, high }
enum TaskStatus { pending, inProgress, completed }

class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final TaskPriority priority;
  final TaskStatus status;
  final double progress; // 0.0 to 1.0
  final bool isGroupTask;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.priority,
    required this.status,
    required this.progress,
    this.isGroupTask = false,
  });
}
