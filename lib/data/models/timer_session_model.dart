import 'package:hive/hive.dart';
import '../../domain/entities/timer_session.dart';

part 'timer_session_model.g.dart';

@HiveType(typeId: 1)
class TimerSessionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  int timerTypeIndex; // 0: focus, 1: shortBreak, 2: longBreak

  @HiveField(2)
  int durationMinutes;

  @HiveField(3)
  DateTime startTime;

  @HiveField(4)
  DateTime? endTime;

  @HiveField(5)
  bool completed;

  @HiveField(6)
  String? taskId;

  TimerSessionModel({
    required this.id,
    required this.timerTypeIndex,
    required this.durationMinutes,
    required this.startTime,
    this.endTime,
    required this.completed,
    this.taskId,
  });

  // Convert from domain entity
  factory TimerSessionModel.fromEntity(TimerSession session) {
    return TimerSessionModel(
      id: session.id,
      timerTypeIndex: session.type.index,
      durationMinutes: session.durationMinutes,
      startTime: session.startTime,
      endTime: session.endTime,
      completed: session.completed,
      taskId: session.taskId,
    );
  }

  // Convert to domain entity
  TimerSession toEntity() {
    return TimerSession(
      id: id,
      type: TimerType.values[timerTypeIndex],
      durationMinutes: durationMinutes,
      startTime: startTime,
      endTime: endTime,
      completed: completed,
      taskId: taskId,
    );
  }
}
