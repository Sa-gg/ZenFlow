import 'package:hive/hive.dart';
import '../../domain/entities/timer_session.dart';
import '../../domain/repositories/session_repository.dart';
import '../models/timer_session_model.dart';

class SessionRepositoryImpl implements SessionRepository {
  final Box<TimerSessionModel> _sessionBox;

  SessionRepositoryImpl(this._sessionBox);

  @override
  Future<List<TimerSession>> getSessions() async {
    return _sessionBox.values.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> addSession(TimerSession session) async {
    final model = TimerSessionModel.fromEntity(session);
    await _sessionBox.put(session.id, model);
  }

  @override
  Future<void> updateSession(TimerSession session) async {
    final model = TimerSessionModel.fromEntity(session);
    await _sessionBox.put(session.id, model);
  }

  @override
  Future<List<TimerSession>> getSessionsByDate(DateTime date) async {
    final sessions = await getSessions();
    return sessions.where((session) {
      return session.startTime.year == date.year &&
          session.startTime.month == date.month &&
          session.startTime.day == date.day;
    }).toList();
  }

  @override
  Future<int> getTotalFocusTime() async {
    final sessions = await getSessions();
    int totalMinutes = 0;
    for (var session in sessions) {
      if (session.type == TimerType.focus && session.completed) {
        totalMinutes += session.durationMinutes;
      }
    }
    return totalMinutes;
  }
}
