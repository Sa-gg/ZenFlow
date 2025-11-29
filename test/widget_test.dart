// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zenflow/main.dart';
import 'package:zenflow/core/constants/app_constants.dart';
import 'package:zenflow/data/models/task_model.dart';
import 'package:zenflow/data/models/timer_session_model.dart';
import 'package:zenflow/data/models/settings_model.dart';
import 'package:zenflow/data/repositories/task_repository_impl.dart';
import 'package:zenflow/data/repositories/session_repository_impl.dart';
import 'package:zenflow/data/repositories/settings_repository_impl.dart';
import 'package:zenflow/presentation/viewmodels/timer_viewmodel.dart';
import 'package:zenflow/presentation/viewmodels/task_viewmodel.dart';
import 'package:zenflow/presentation/viewmodels/settings_viewmodel.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive for testing
    await Hive.initFlutter();

    // Register Hive Adapters
    Hive.registerAdapter(TaskModelAdapter());
    Hive.registerAdapter(TimerSessionModelAdapter());
    Hive.registerAdapter(SettingsModelAdapter());

    // Open Hive boxes
    await Hive.openBox<TaskModel>(AppConstants.tasksBox);
    await Hive.openBox<TimerSessionModel>(AppConstants.sessionsBox);
    await Hive.openBox<SettingsModel>(AppConstants.settingsBox);
  });

  tearDownAll(() async {
    // Close Hive boxes after tests
    await Hive.close();
  });

  testWidgets('ZenFlow app smoke test', (WidgetTester tester) async {
    // Setup test repositories and viewmodels
    final taskRepo = TaskRepositoryImpl(
      Hive.box<TaskModel>(AppConstants.tasksBox),
    );
    final sessionRepo = SessionRepositoryImpl(
      Hive.box<TimerSessionModel>(AppConstants.sessionsBox),
    );
    final settingsRepo = SettingsRepositoryImpl(
      Hive.box<SettingsModel>(AppConstants.settingsBox),
    );

    final timerVm = TimerViewModel(sessionRepo, settingsRepo);
    final taskVm = TaskViewModel(taskRepo);
    final settingsVm = SettingsViewModel(settingsRepo);

    await timerVm.initialize();
    await taskVm.loadTasks();
    await settingsVm.loadSettings();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ZenFlowApp.preloaded(
        timerVm: timerVm,
        taskVm: taskVm,
        settingsVm: settingsVm,
      ),
    );

    // Verify that the app title is displayed.
    expect(find.text('ZenFlow'), findsOneWidget);
  });
}
