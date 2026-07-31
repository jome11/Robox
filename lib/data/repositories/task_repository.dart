import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';
import '../models/task_model.dart';

abstract class TaskRepository {
  Future<List<TaskModel>> getTasks(); // worker: only their own tasks
  Future<List<TaskModel>> getAllTasks(); // admin: every task
  Future<void> createTask({
    required String title,
    required String description,
    required DateTime deadline,
    required TaskPriority priority,
    required bool isGroupTask,
    required List<String> workerIds,
  });
  Future<void> updateProgress(String taskId, double progress, TaskStatus status);
  Future<void> deleteTask(String taskId);
}

class TaskRepositoryImpl implements TaskRepository {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  TaskModel _fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      deadline: DateTime.parse(json['deadline'] as String),
      priority: TaskPriority.values.firstWhere(
            (p) => p.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      status: _statusFromString(json['status'] as String),
      progress: (json['progress'] as num).toDouble(),
      isGroupTask: json['isGroupTask'] as bool? ?? false,
      assignedWorkers: (json['assignedWorkers'] as List<dynamic>? ?? [])
          .map((w) => AssignedWorker(
        id: (w as Map<String, dynamic>)['id'] as String,
        name: w['name'] as String,
      ))
          .toList(),
    );
  }

  TaskStatus _statusFromString(String s) {
    switch (s) {
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      default:
        return TaskStatus.pending;
    }
  }

  String _statusToString(TaskStatus s) {
    switch (s) {
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.completed:
        return 'completed';
      case TaskStatus.pending:
        return 'pending';
    }
  }

  @override
  Future<List<TaskModel>> getTasks() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/worker/tasks'),
      headers: headers,
    );
    if (response.statusCode != 200) throw Exception('FAILED_TO_LOAD_TASKS');

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final tasks = data['tasks'] as List<dynamic>;
    return tasks.map((t) => _fromJson(t as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<TaskModel>> getAllTasks() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/tasks'),
      headers: headers,
    );
    if (response.statusCode != 200) throw Exception('FAILED_TO_LOAD_TASKS');

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final tasks = data['tasks'] as List<dynamic>;
    return tasks.map((t) => _fromJson(t as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> createTask({
    required String title,
    required String description,
    required DateTime deadline,
    required TaskPriority priority,
    required bool isGroupTask,
    required List<String> workerIds,
  }) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/admin/tasks'),
      headers: headers,
      body: jsonEncode({
        'title': title,
        'description': description,
        'deadline': deadline.toIso8601String(),
        'priority': priority.name,
        'isGroupTask': isGroupTask,
        'workerIds': workerIds,
      }),
    );
    if (response.statusCode != 200) throw Exception('CREATE_TASK_FAILED');
  }

  @override
  Future<void> updateProgress(String taskId, double progress, TaskStatus status) async {
    final headers = await _authHeaders();
    final response = await http.patch(
      Uri.parse('${ApiConstants.baseUrl}/worker/tasks/$taskId/progress'),
      headers: headers,
      body: jsonEncode({
        'progress': progress,
        'status': _statusToString(status),
      }),
    );
    if (response.statusCode != 200) throw Exception('UPDATE_PROGRESS_FAILED');
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/worker/tasks/$taskId'),
      headers: headers,
    );
    if (response.statusCode != 200) throw Exception('DELETE_TASK_FAILED');
  }
}