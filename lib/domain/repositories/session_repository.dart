import '../entities/timer_session.dart';

abstract class SessionRepository {
  Future<List<TimerSession>> getSessions();
  Future<void> addSession(TimerSession session);
  Future<void> updateSession(TimerSession session);
  Future<List<TimerSession>> getSessionsByDate(DateTime date);
  Future<int> getTotalFocusTime();
}
