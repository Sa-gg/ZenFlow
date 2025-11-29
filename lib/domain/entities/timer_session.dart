import 'package:equatable/equatable.dart';

enum TimerType { focus, shortBreak, longBreak }

class TimerSession extends Equatable {
  final String id;
  final TimerType type;
  final int durationMinutes;
  final DateTime startTime;
  final DateTime? endTime;
  final bool completed;
  final String? taskId;

  const TimerSession({
    required this.id,
    required this.type,
    required this.durationMinutes,
    required this.startTime,
    this.endTime,
    required this.completed,
    this.taskId,
  });

  TimerSession copyWith({
    String? id,
    TimerType? type,
    int? durationMinutes,
    DateTime? startTime,
    DateTime? endTime,
    bool? completed,
    String? taskId,
  }) {
    return TimerSession(
      id: id ?? this.id,
      type: type ?? this.type,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      completed: completed ?? this.completed,
      taskId: taskId ?? this.taskId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        durationMinutes,
        startTime,
        endTime,
        completed,
        taskId,
      ];
}
