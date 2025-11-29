import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final String id;
  final String title;
  final bool completed;
  final DateTime createdAt;
  final int pomodorosCompleted;

  const Task({
    required this.id,
    required this.title,
    required this.completed,
    required this.createdAt,
    this.pomodorosCompleted = 0,
  });

  Task copyWith({
    String? id,
    String? title,
    bool? completed,
    DateTime? createdAt,
    int? pomodorosCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      pomodorosCompleted: pomodorosCompleted ?? this.pomodorosCompleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        completed,
        createdAt,
        pomodorosCompleted,
      ];
}
