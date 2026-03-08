import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

// Data layer
import 'data/models/task_model.dart';
import 'data/models/timer_session_model.dart';
import 'data/models/settings_model.dart';
import 'data/repositories/task_repository_impl.dart';
import 'data/repositories/session_repository_impl.dart';
import 'data/repositories/settings_repository_impl.dart';

// Presentation layer
import 'presentation/viewmodels/timer_viewmodel.dart';
import 'presentation/viewmodels/task_viewmodel.dart';
import 'presentation/viewmodels/settings_viewmodel.dart';
import 'presentation/screens/home_screen.dart';

// Core
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(TimerSessionModelAdapter());
  Hive.registerAdapter(SettingsModelAdapter());

  // Open Hive boxes
  await Hive.openBox<TaskModel>(AppConstants.tasksBox);
  await Hive.openBox<TimerSessionModel>(AppConstants.sessionsBox);
  await Hive.openBox<SettingsModel>(AppConstants.settingsBox);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Create repositories early so we can preload data before the UI starts.
  final taskRepository = TaskRepositoryImpl(
    Hive.box<TaskModel>(AppConstants.tasksBox),
  );
  final sessionRepository = SessionRepositoryImpl(
    Hive.box<TimerSessionModel>(AppConstants.sessionsBox),
  );
  final settingsRepository = SettingsRepositoryImpl(
    Hive.box<SettingsModel>(AppConstants.settingsBox),
  );

  // Pre-initialize viewmodels so persisted settings/tasks are loaded before UI shows.
  final timerVm = TimerViewModel(sessionRepository, settingsRepository);
  await timerVm.initialize();

  final taskVm = TaskViewModel(taskRepository);
  await taskVm.loadTasks();

  final settingsVm = SettingsViewModel(settingsRepository);
  await settingsVm.loadSettings();

  runApp(ZenFlowApp.preloaded(
    timerVm: timerVm,
    taskVm: taskVm,
    settingsVm: settingsVm,
  ));
}

class ZenFlowApp extends StatelessWidget {
  final TimerViewModel timerVm;
  final TaskViewModel taskVm;
  final SettingsViewModel settingsVm;

  const ZenFlowApp._({
    required this.timerVm,
    required this.taskVm,
    required this.settingsVm,
  });

  /// Construct a preloaded app with initialized viewmodels.
  factory ZenFlowApp.preloaded({
    required TimerViewModel timerVm,
    required TaskViewModel taskVm,
    required SettingsViewModel settingsVm,
  }) {
    return ZenFlowApp._(
        timerVm: timerVm, taskVm: taskVm, settingsVm: settingsVm);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TimerViewModel>.value(value: timerVm),
        ChangeNotifierProvider<TaskViewModel>.value(value: taskVm),
        ChangeNotifierProvider<SettingsViewModel>.value(value: settingsVm),
      ],
      child: MaterialApp(
        title: 'ZenFlow - Pomodoro Timer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
