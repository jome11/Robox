import '../models/task_model.dart';

abstract class TaskRepository {
  Future<List<TaskModel>> getTasks();
}

class TaskRepositoryImpl implements TaskRepository {
  @override
  Future<List<TaskModel>> getTasks() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      TaskModel(
        id: '1',
        title: 'Node Maintenance',
        description: 'Routine checkup on power nodes.',
        deadline: DateTime.now().add(const Duration(days: 2)),
        priority: TaskPriority.high,
        status: TaskStatus.inProgress,
        progress: 0.65,
      ),
      TaskModel(
        id: '2',
        title: 'Network Calibration',
        description: 'Adjusting signal strength for sector 7.',
        deadline: DateTime.now().add(const Duration(days: 5)),
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        progress: 0.0,
      ),
    ];
  }
}
