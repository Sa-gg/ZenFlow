import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/timer_session.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/notification_service.dart';

class TimerViewModel extends ChangeNotifier {
  final SessionRepository _sessionRepository;
  final SettingsRepository _settingsRepository;
  final AudioService _audioService = AudioService();
  final NotificationService _notificationService = NotificationService();

  TimerViewModel(this._sessionRepository, this._settingsRepository);

  // Timer state
  TimerType _currentTimerType = TimerType.focus;
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  int _currentCycle = 0;
  int _completedCycles = 0;
  int _totalFocusSessions = 0;

  Timer? _timer;
  AppSettings? _settings;
  String? _currentTaskId;
  StreamSubscription<NotificationAction>? _notificationSubscription;

  // Callback for timer completion (to show dialog)
  Function(TimerType completedType)? onTimerComplete;

  // Callback for notification tap (to scroll to top)
  Function()? onNotificationTap;

  // Getters
  TimerType get currentTimerType => _currentTimerType;
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  int get currentCycle => _currentCycle;
  int get completedCycles => _completedCycles;
  int get totalFocusSessions => _totalFocusSessions;
  String? get currentTaskId => _currentTaskId;

  String get timeDisplay {
    final minutes = (_remainingSeconds / 60).floor();
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress {
    final totalSeconds = _getTotalSeconds();
    if (totalSeconds == 0) return 0;
    return (_getTotalSeconds() - _remainingSeconds) / _getTotalSeconds();
  }

  Future<void> initialize() async {
    _settings = await _settingsRepository.getSettings();
    _remainingSeconds = _settings!.focusDuration * 60;
    _totalFocusSessions = await _sessionRepository.getTotalFocusTime() ~/
        (_settings!.focusDuration);
    await _notificationService.initialize();

    // Listen to notification actions
    _notificationSubscription =
        _notificationService.actionStream.listen((action) {
      switch (action) {
        case NotificationAction.pause:
          pause();
          break;
        case NotificationAction.resume:
          start();
          break;
        case NotificationAction.reset:
          reset();
          break;
        case NotificationAction.tap:
          onNotificationTap?.call();
          break;
      }
    });

    notifyListeners();
  }

  void setTimerType(TimerType type) {
    if (_isRunning) {
      stop();
    }
    _currentTimerType = type;
    _remainingSeconds = _getTotalSeconds();
    notifyListeners();
  }

  void start() {
    if (_isRunning) return;

    // If remaining time is zero (timer already completed), reset before starting
    if (_remainingSeconds <= 0) {
      _remainingSeconds = _getTotalSeconds();
    }

    _isRunning = true;
    _updateTimerNotification(); // Show initial notification
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        _remainingSeconds--;
        _updateTimerNotification(); // Update notification every second
        notifyListeners();
      } else {
        // Last second: set to 0 and complete
        _remainingSeconds = 0;
        notifyListeners();
        _onTimerComplete();
      }
    });
    notifyListeners();
  }

  void _updateTimerNotification() {
    _notificationService.updateTimerNotification(
      timeRemaining: timeDisplay,
      timerType: _currentTimerType,
      isRunning: _isRunning,
    );
  }

  void pause() {
    _isRunning = false;
    _timer?.cancel();
    _notificationService.cancelTimerNotification();
    notifyListeners();
  }

  void stop() {
    _isRunning = false;
    _timer?.cancel();
    _remainingSeconds = _getTotalSeconds();
    _notificationService.cancelTimerNotification();
    notifyListeners();
  }

  void reset() {
    stop();
  }

  void resetAll() {
    // Reset both timer and cycle progress (used in settings)
    stop();
    _currentCycle = 0;
    _completedCycles = 0;
    notifyListeners();
  }

  void setCurrentTask(String? taskId) {
    _currentTaskId = taskId;
    notifyListeners();
  }

  /// Set the current cycle (number of completed focus sessions in the current group).
  /// Clamped to [0..cyclesBeforeLongBreak].
  void setCurrentCycle(int newCycle) {
    int value = newCycle;
    final max = _settings?.cyclesBeforeLongBreak ?? 4;
    if (value < 0) value = 0;
    if (value > max) value = max;
    _currentCycle = value;
    notifyListeners();
  }

  Future<void> _onTimerComplete() async {
    _timer?.cancel();
    _isRunning = false;

    // Store the completed timer type BEFORE switching
    final completedType = _currentTimerType;

    // Compute notification text BEFORE state changes
    String completionTitle = '';
    String completionBody = '';
    switch (completedType) {
      case TimerType.focus:
        if (_currentCycle + 1 >= (_settings?.cyclesBeforeLongBreak ?? 4)) {
          completionTitle = '🎉 Focus Complete!';
          completionBody = 'Time for a long break!';
        } else {
          completionTitle = '🎉 Focus Complete!';
          completionBody = 'Time for a short break!';
        }
        break;
      case TimerType.shortBreak:
        completionTitle = '☕ Break Complete!';
        completionBody = 'Time to focus!';
        break;
      case TimerType.longBreak:
        completionTitle = '🌴 Long Break Complete!';
        completionBody = 'Ready for another cycle!';
        break;
    }

    // --- Synchronous state updates ---
    if (_settings?.autoSwitch ?? false) {
      if (_currentTimerType == TimerType.focus) {
        _currentCycle++;
        _totalFocusSessions++;

        if (_currentCycle >= (_settings?.cyclesBeforeLongBreak ?? 4)) {
          _currentTimerType = TimerType.longBreak;
          _completedCycles++;
          _currentCycle = 0;
        } else {
          _currentTimerType = TimerType.shortBreak;
        }
      } else {
        _currentTimerType = TimerType.focus;
      }
    }

    _remainingSeconds = _getTotalSeconds();
    onTimerComplete?.call(completedType);
    notifyListeners();

    // --- Async side effects (notifications, audio, persistence) ---
    await _notificationService.cancelTimerNotification();
    await _audioService.playCompletionSound();
    await _notificationService.showCompletionNotification(
      title: completionTitle,
      body: completionBody,
    );

    final session = TimerSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: completedType,
      durationMinutes: _getTotalSeconds() ~/ 60,
      startTime: DateTime.now().subtract(Duration(seconds: _getTotalSeconds())),
      endTime: DateTime.now(),
      completed: true,
      taskId: _currentTaskId,
    );
    await _sessionRepository.addSession(session);
  }

  int _getTotalSeconds() {
    if (_settings == null) return 25 * 60;

    switch (_currentTimerType) {
      case TimerType.focus:
        return _settings!.focusDuration * 60;
      case TimerType.shortBreak:
        return _settings!.shortBreakDuration * 60;
      case TimerType.longBreak:
        return _settings!.longBreakDuration * 60;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _notificationSubscription?.cancel();
    super.dispose();
  }
}
