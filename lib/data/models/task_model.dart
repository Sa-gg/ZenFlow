import 'package:hive/hive.dart';
import '../../domain/entities/task.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool completed;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  int pomodorosCompleted;

  TaskModel({
    required this.id,
    required this.title,
    required this.completed,
    required this.createdAt,
    this.pomodorosCompleted = 0,
  });

  // Convert from domain entity
  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      completed: task.completed,
      createdAt: task.createdAt,
      pomodorosCompleted: task.pomodorosCompleted,
    );
  }

  // Convert to domain entity
  Task toEntity() {
    return Task(
      id: id,
      title: title,
      completed: completed,
      createdAt: createdAt,
      pomodorosCompleted: pomodorosCompleted,
    );
  }
}
