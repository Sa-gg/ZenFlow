import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskRepository _taskRepository;

  TaskViewModel(this._taskRepository);

  List<Task> _tasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  List<Task> get activeTasks =>
      _tasks.where((task) => !task.completed).toList();
  List<Task> get completedTasks =>
      _tasks.where((task) => task.completed).toList();
  bool get isLoading => _isLoading;

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    _tasks = await _taskRepository.getTasks();
    _tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(String title) async {
    if (title.trim().isEmpty) return;

    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      completed: false,
      createdAt: DateTime.now(),
      pomodorosCompleted: 0,
    );

    await _taskRepository.addTask(task);
    await loadTasks();
  }

  Future<void> toggleTaskCompletion(String id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    final updatedTask = task.copyWith(completed: !task.completed);
    await _taskRepository.updateTask(updatedTask);
    await loadTasks();
  }

  Future<void> deleteTask(String id) async {
    await _taskRepository.deleteTask(id);
    await loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await _taskRepository.updateTask(task);
    await loadTasks();
  }

  Future<void> incrementPomodoro(String id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    final updatedTask = task.copyWith(
      pomodorosCompleted: task.pomodorosCompleted + 1,
    );
    await _taskRepository.updateTask(updatedTask);
    await loadTasks();
  }
}
