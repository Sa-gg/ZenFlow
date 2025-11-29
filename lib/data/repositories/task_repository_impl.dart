import 'package:hive/hive.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final Box<TaskModel> _taskBox;

  TaskRepositoryImpl(this._taskBox);

  @override
  Future<List<Task>> getTasks() async {
    return _taskBox.values.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> addTask(Task task) async {
    final model = TaskModel.fromEntity(task);
    await _taskBox.put(task.id, model);
  }

  @override
  Future<void> updateTask(Task task) async {
    final model = TaskModel.fromEntity(task);
    await _taskBox.put(task.id, model);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _taskBox.delete(id);
  }

  @override
  Future<Task?> getTask(String id) async {
    final model = _taskBox.get(id);
    return model?.toEntity();
  }
}
