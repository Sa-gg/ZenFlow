class AppConstants {
  // Timer durations in minutes
  static const int focusDuration = 25;
  static const int shortBreakDuration = 5;
  static const int longBreakDuration = 15;

  // Pomodoro cycles
  static const int cyclesBeforeLongBreak = 4;

  // Hive box names
  static const String tasksBox = 'tasks';
  static const String settingsBox = 'settings';
  static const String sessionsBox = 'sessions';

  // Timer states
  static const String timerStateIdle = 'idle';
  static const String timerStateRunning = 'running';
  static const String timerStatePaused = 'paused';
  static const String timerStateCompleted = 'completed';
}
