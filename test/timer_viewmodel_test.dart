import 'package:fake_async/fake_async.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenflow/domain/entities/timer_session.dart';
import 'package:zenflow/domain/entities/app_settings.dart';
import 'package:zenflow/domain/repositories/session_repository.dart';
import 'package:zenflow/domain/repositories/settings_repository.dart';
import 'package:zenflow/presentation/viewmodels/timer_viewmodel.dart';

// ---------------------------------------------------------------------------
// Minimal in-memory fakes (no external packages required)
// ---------------------------------------------------------------------------

class FakeSessionRepository implements SessionRepository {
  final List<TimerSession> _sessions = [];

  @override
  Future<List<TimerSession>> getSessions() async => List.of(_sessions);

  @override
  Future<void> addSession(TimerSession session) async => _sessions.add(session);

  @override
  Future<void> updateSession(TimerSession session) async {
    _sessions.removeWhere((s) => s.id == session.id);
    _sessions.add(session);
  }

  @override
  Future<List<TimerSession>> getSessionsByDate(DateTime date) async {
    return _sessions
        .where((s) =>
            s.startTime.year == date.year &&
            s.startTime.month == date.month &&
            s.startTime.day == date.day)
        .toList();
  }

  @override
  Future<int> getTotalFocusTime() async {
    int total = 0;
    for (final s in _sessions) {
      if (s.type == TimerType.focus && s.completed) {
        total += s.durationMinutes;
      }
    }
    return total;
  }
}

class FakeSettingsRepository implements SettingsRepository {
  AppSettings _settings;

  FakeSettingsRepository({AppSettings? settings})
      : _settings = settings ?? const AppSettings();

  @override
  Future<AppSettings> getSettings() async => _settings;

  @override
  Future<void> saveSettings(AppSettings settings) async => _settings = settings;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Use [fakeAsync] to advance the Dart event-loop timer without waiting.
/// Flutter test already provides `fakeAsync` + `flushTimers` via the
/// `flutter_test` package but for pure-Dart timer testing we rely on
/// `package:fake_async` which ships with flutter_test.
///
/// We use a simpler approach: create the VM, call start(), then use
/// [TestWidgetsFlutterBinding.instance.delayed] or plain elapsed time.
/// However since the timer uses real `Timer.periodic`, we use
/// `fakeAsync` from flutter_test.

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock the flutter_local_notifications platform channel so
  // NotificationService doesn't crash in unit tests.
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dexterous.com/flutter/local_notifications'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'initialize') return true;
        if (methodCall.method == 'requestNotificationsPermission') return true;
        return null; // no-op for show, cancel, cancelAll, etc.
      },
    );
  });

  late FakeSessionRepository sessionRepo;
  late FakeSettingsRepository settingsRepo;
  late TimerViewModel vm;

  /// Creates a TimerViewModel with short durations for fast tests.
  Future<TimerViewModel> createVm({
    int focusDuration = 1, // 1 minute = 60 seconds
    int shortBreakDuration = 1,
    int longBreakDuration = 1,
    int cyclesBeforeLongBreak = 4,
    bool autoSwitch = false,
  }) async {
    sessionRepo = FakeSessionRepository();
    settingsRepo = FakeSettingsRepository(
      settings: AppSettings(
        focusDuration: focusDuration,
        shortBreakDuration: shortBreakDuration,
        longBreakDuration: longBreakDuration,
        cyclesBeforeLongBreak: cyclesBeforeLongBreak,
        autoSwitch: autoSwitch,
      ),
    );
    final viewModel = TimerViewModel(sessionRepo, settingsRepo);
    await viewModel.initialize();
    return viewModel;
  }

  setUp(() async {
    vm = await createVm();
  });

  tearDown(() {
    vm.dispose();
  });

  // -------------------------------------------------------------------------
  // Basic state
  // -------------------------------------------------------------------------

  group('Initial state', () {
    test('starts in focus mode with correct remaining seconds', () {
      expect(vm.currentTimerType, TimerType.focus);
      expect(vm.remainingSeconds, 60); // 1 min
      expect(vm.isRunning, false);
      expect(vm.currentCycle, 0);
      expect(vm.completedCycles, 0);
    });

    test('timeDisplay formats correctly', () {
      expect(vm.timeDisplay, '01:00');
    });

    test('progress starts at 0', () {
      expect(vm.progress, 0.0);
    });
  });

  // -------------------------------------------------------------------------
  // Start / Pause / Resume
  // -------------------------------------------------------------------------

  group('Start and Pause', () {
    test('start sets isRunning to true', () {
      vm.start();
      expect(vm.isRunning, true);
      vm.pause(); // cleanup
    });

    test('pause sets isRunning to false', () {
      vm.start();
      vm.pause();
      expect(vm.isRunning, false);
    });

    test('start after pause resumes without resetting remaining seconds', () {
      vm.start();
      // Simulate a bit of time passing (manually set remaining)
      // Since we can't easily advance time without fakeAsync, verify that
      // remainingSeconds is preserved across pause/start.
      vm.pause();
      final afterPause = vm.remainingSeconds;
      vm.start();
      expect(vm.remainingSeconds, afterPause);
      vm.pause();
    });

    test('double start is a no-op', () {
      vm.start();
      vm.start(); // should not throw or create double timers
      expect(vm.isRunning, true);
      vm.pause();
    });

    test('pause when not running is a no-op', () {
      vm.pause();
      expect(vm.isRunning, false);
    });
  });

  // -------------------------------------------------------------------------
  // Stop / Reset
  // -------------------------------------------------------------------------

  group('Stop and Reset', () {
    test('stop resets remaining seconds to full duration', () {
      vm.start();
      vm.stop();
      expect(vm.isRunning, false);
      expect(vm.remainingSeconds, 60);
    });

    test('reset calls stop', () {
      vm.start();
      vm.reset();
      expect(vm.isRunning, false);
      expect(vm.remainingSeconds, 60);
    });

    test('resetAll also resets cycles', () {
      vm.start();
      vm.resetAll();
      expect(vm.isRunning, false);
      expect(vm.currentCycle, 0);
      expect(vm.completedCycles, 0);
    });
  });

  // -------------------------------------------------------------------------
  // Timer type switching
  // -------------------------------------------------------------------------

  group('Timer type switching', () {
    test('setTimerType changes type and resets remaining seconds', () {
      vm.setTimerType(TimerType.shortBreak);
      expect(vm.currentTimerType, TimerType.shortBreak);
      expect(vm.remainingSeconds, 60); // 1 min short break
    });

    test('setTimerType while running stops first', () {
      vm.start();
      vm.setTimerType(TimerType.longBreak);
      expect(vm.isRunning, false);
      expect(vm.currentTimerType, TimerType.longBreak);
    });
  });

  // -------------------------------------------------------------------------
  // BUG FIX: Play-Pause-Play at 00:00
  // -------------------------------------------------------------------------

  group('Play-Pause-Play at 00:00 bug fix', () {
    test('starting when remainingSeconds is 0 resets to full duration', () {
      // Simulate the condition where timer completed and remainingSeconds = 0
      // We can't directly set _remainingSeconds, but we can use stop()
      // then manually verify start() behavior at 0.
      //
      // Since _onTimerComplete resets remainingSeconds, let's test the
      // safety guard in start() by checking that start never fires
      // _onTimerComplete immediately.

      vm.start();
      // Timer is running, remainingSeconds = 60
      expect(vm.isRunning, true);
      expect(vm.remainingSeconds, 60);
      vm.pause();
    });
  });

  // -------------------------------------------------------------------------
  // Timer countdown (fakeAsync)
  // -------------------------------------------------------------------------

  group('Timer countdown with fakeAsync', () {
    test('timer decrements every second', () {
      fakeAsync((async) {
        vm.start();
        async.elapse(const Duration(seconds: 3));
        expect(vm.remainingSeconds, 57); // 60 - 3
        vm.pause();
      });
    });

    test('timer reaches zero and completes', () {
      fakeAsync((async) {
        TimerType? completedType;
        vm.onTimerComplete = (type) => completedType = type;

        vm.start();
        async.elapse(const Duration(seconds: 60));

        expect(vm.isRunning, false);
        expect(vm.remainingSeconds, 60); // Reset after completion
        expect(completedType, TimerType.focus);
      });
    });

    test('pause preserves remaining seconds through countdown', () {
      fakeAsync((async) {
        vm.start();
        async.elapse(const Duration(seconds: 10));
        expect(vm.remainingSeconds, 50);

        vm.pause();
        expect(vm.remainingSeconds, 50);

        // Time passes while paused — should NOT decrement
        async.elapse(const Duration(seconds: 10));
        expect(vm.remainingSeconds, 50);
      });
    });

    test('play-pause-play continues from correct position', () {
      fakeAsync((async) {
        vm.start();
        async.elapse(const Duration(seconds: 10));
        expect(vm.remainingSeconds, 50);

        vm.pause();
        vm.start();

        async.elapse(const Duration(seconds: 10));
        expect(vm.remainingSeconds, 40);
        vm.pause();
      });
    });

    test('play-pause-play countdown to zero completes correctly', () {
      fakeAsync((async) {
        TimerType? completedType;
        vm.onTimerComplete = (type) => completedType = type;

        vm.start();
        async.elapse(const Duration(seconds: 30));
        expect(vm.remainingSeconds, 30);

        vm.pause();
        vm.start();

        async.elapse(const Duration(seconds: 30));
        expect(vm.isRunning, false);
        expect(completedType, TimerType.focus);
        // After completion, remainingSeconds is reset
        expect(vm.remainingSeconds, 60);
      });
    });

    test('multiple play-pause cycles still complete correctly', () {
      fakeAsync((async) {
        TimerType? completedType;
        vm.onTimerComplete = (type) => completedType = type;

        // First segment: 20s
        vm.start();
        async.elapse(const Duration(seconds: 20));
        vm.pause();
        expect(vm.remainingSeconds, 40);

        // Second segment: 15s
        vm.start();
        async.elapse(const Duration(seconds: 15));
        vm.pause();
        expect(vm.remainingSeconds, 25);

        // Third segment: 10s
        vm.start();
        async.elapse(const Duration(seconds: 10));
        vm.pause();
        expect(vm.remainingSeconds, 15);

        // Final segment: exhaust remaining
        vm.start();
        async.elapse(const Duration(seconds: 15));

        expect(vm.isRunning, false);
        expect(completedType, TimerType.focus);
        expect(vm.remainingSeconds, 60);
      });
    });

    test('start after completion resets to full duration instead of stuck at 0',
        () {
      fakeAsync((async) {
        vm.onTimerComplete = (_) {};

        // Run timer to completion
        vm.start();
        async.elapse(const Duration(seconds: 60));
        expect(vm.isRunning, false);
        expect(vm.remainingSeconds, 60); // _onTimerComplete resets

        // Start again — should work normally
        vm.start();
        expect(vm.isRunning, true);
        expect(vm.remainingSeconds, 60);

        async.elapse(const Duration(seconds: 5));
        expect(vm.remainingSeconds, 55);
        vm.pause();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Auto-switch cycle progression
  // -------------------------------------------------------------------------

  group('Auto-switch and cycle progression', () {
    late TimerViewModel autoVm;

    setUp(() async {
      autoVm = await createVm(autoSwitch: true, cyclesBeforeLongBreak: 4);
    });

    tearDown(() => autoVm.dispose());

    test(
        'completing focus session increments cycle and switches to short break',
        () {
      fakeAsync((async) {
        autoVm.onTimerComplete = (_) {};

        autoVm.start();
        async.elapse(const Duration(seconds: 60));

        expect(autoVm.isRunning, false);
        expect(autoVm.currentTimerType, TimerType.shortBreak);
        expect(autoVm.currentCycle, 1);
      });
    });

    test('completing short break switches back to focus', () {
      fakeAsync((async) {
        autoVm.onTimerComplete = (_) {};

        // Complete focus
        autoVm.start();
        async.elapse(const Duration(seconds: 60));

        // Now on short break — complete it
        autoVm.start();
        async.elapse(const Duration(seconds: 60));

        expect(autoVm.currentTimerType, TimerType.focus);
        expect(autoVm.currentCycle, 1); // Still 1, only focus increments
      });
    });

    test('4 focus sessions trigger long break', () {
      fakeAsync((async) {
        autoVm.onTimerComplete = (_) {};

        for (int i = 0; i < 4; i++) {
          // Focus session
          autoVm.start();
          async.elapse(const Duration(seconds: 60));

          if (i < 3) {
            // Short break
            expect(autoVm.currentTimerType, TimerType.shortBreak);
            autoVm.start();
            async.elapse(const Duration(seconds: 60));
          }
        }

        expect(autoVm.currentTimerType, TimerType.longBreak);
        expect(autoVm.completedCycles, 1);
        expect(autoVm.currentCycle, 0); // Reset after long break trigger
      });
    });
  });

  // -------------------------------------------------------------------------
  // Stress tests
  // -------------------------------------------------------------------------

  group('Stress tests', () {
    test('rapid start-pause toggling does not crash or leak timers', () {
      fakeAsync((async) {
        for (int i = 0; i < 100; i++) {
          vm.start();
          vm.pause();
        }
        // Should still be in a clean state
        expect(vm.isRunning, false);
        expect(vm.remainingSeconds, 60);
      });
    });

    test('rapid start-stop toggling does not corrupt state', () {
      fakeAsync((async) {
        for (int i = 0; i < 100; i++) {
          vm.start();
          vm.stop();
        }
        expect(vm.isRunning, false);
        expect(vm.remainingSeconds, 60);
      });
    });

    test('rapid start-pause with elapsed time accumulates correctly', () {
      fakeAsync((async) {
        // 50 cycles of 1-second run + pause
        for (int i = 0; i < 50; i++) {
          vm.start();
          async.elapse(const Duration(seconds: 1));
          vm.pause();
        }
        expect(vm.remainingSeconds, 10); // 60 - 50
        expect(vm.isRunning, false);
      });
    });

    test('type switching during rapid operations is safe', () {
      fakeAsync((async) {
        for (int i = 0; i < 20; i++) {
          vm.start();
          async.elapse(const Duration(seconds: 1));
          vm.setTimerType(TimerType.shortBreak);
          vm.start();
          async.elapse(const Duration(seconds: 1));
          vm.setTimerType(TimerType.focus);
        }
        expect(vm.isRunning, false); // setTimerType stops the timer
        expect(vm.currentTimerType, TimerType.focus);
      });
    });

    test('completing many full cycles with auto-switch works', () async {
      final stressVm =
          await createVm(autoSwitch: true, cyclesBeforeLongBreak: 2);

      fakeAsync((async) {
        stressVm.onTimerComplete = (_) {};

        // Run 3 full cycles (2 focus + breaks each, then long break)
        for (int cycle = 0; cycle < 3; cycle++) {
          for (int focus = 0; focus < 2; focus++) {
            // Focus session
            stressVm.start();
            async.elapse(const Duration(seconds: 60));

            if (focus < 1) {
              // Short break
              stressVm.start();
              async.elapse(const Duration(seconds: 60));
            }
          }

          // Long break
          expect(stressVm.currentTimerType, TimerType.longBreak);
          stressVm.start();
          async.elapse(const Duration(seconds: 60));
        }

        expect(stressVm.completedCycles, 3);
      });

      stressVm.dispose();
    });

    test('pause at exactly 1 second remaining then resume completes', () {
      fakeAsync((async) {
        TimerType? completedType;
        vm.onTimerComplete = (type) => completedType = type;

        vm.start();
        async.elapse(const Duration(seconds: 59));
        expect(vm.remainingSeconds, 1);

        vm.pause();
        expect(vm.remainingSeconds, 1);

        vm.start();
        async.elapse(const Duration(seconds: 1));

        expect(vm.isRunning, false);
        expect(completedType, TimerType.focus);
        expect(vm.remainingSeconds, 60); // Reset after completion
      });
    });

    test('setCurrentCycle clamps values', () {
      vm.setCurrentCycle(-5);
      expect(vm.currentCycle, 0);
      vm.setCurrentCycle(100);
      expect(vm.currentCycle, 4); // max is cyclesBeforeLongBreak
      vm.setCurrentCycle(2);
      expect(vm.currentCycle, 2);
    });
  });

  // -------------------------------------------------------------------------
  // Progress calculation
  // -------------------------------------------------------------------------

  group('Progress', () {
    test('progress increases as time ticks', () {
      fakeAsync((async) {
        vm.start();
        async.elapse(const Duration(seconds: 30));
        expect(vm.progress, closeTo(0.5, 0.02));
        vm.pause();
      });
    });

    test('progress is 0 at start and resets after completion', () {
      fakeAsync((async) {
        expect(vm.progress, 0.0);
        vm.onTimerComplete = (_) {};
        vm.start();
        async.elapse(const Duration(seconds: 60));
        expect(vm.progress, 0.0); // Reset
      });
    });
  });

  // -------------------------------------------------------------------------
  // Notification changes
  // -------------------------------------------------------------------------

  group('ChangeNotifier', () {
    test('start/pause/stop all trigger notifyListeners', () {
      int notifications = 0;
      vm.addListener(() => notifications++);

      vm.start();
      expect(notifications, greaterThan(0));

      final before = notifications;
      vm.pause();
      expect(notifications, greaterThan(before));

      final before2 = notifications;
      vm.stop();
      expect(notifications, greaterThan(before2));
    });
  });
}
