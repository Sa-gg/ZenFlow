import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/timer_viewmodel.dart';
import '../viewmodels/task_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../widgets/timer_display.dart';
import '../widgets/timer_controls.dart';
import '../widgets/timer_type_selector.dart';
import '../widgets/cycle_progress.dart';
import '../widgets/task_list_widget.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/settings_widget.dart';
import '../widgets/info_section.dart';
import '../widgets/footer_widget.dart';
import '../widgets/timer_complete_dialog.dart';
import '../../domain/entities/timer_session.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timerVm = context.read<TimerViewModel>();
      timerVm.initialize();
      context.read<TaskViewModel>().loadTasks();

      // Set up timer completion callback
      timerVm.onTimerComplete = (TimerType completedType) {
        // Only show dialog if auto-switch is disabled
        final settingsVm = context.read<SettingsViewModel>();
        if (!settingsVm.settings.autoSwitch) {
          _showTimerCompleteDialog(timerVm, completedType);
        }
      };

      // Set up notification tap callback to scroll to top
      timerVm.onNotificationTap = () {
        _scrollToTop();
      };
    });
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showTimerCompleteDialog(
      TimerViewModel timerVm, TimerType completedType) {
    // The viewmodel has already switched timer type if auto-switch is enabled
    // Just show the completion dialog - user must manually click start
    TimerType nextType = timerVm.currentTimerType;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (context) => TimerCompleteDialog(
        completedType: completedType,
        nextType: nextType,
        onContinue: () {
          Navigator.of(context).pop();
          // User must manually start the timer - never auto-start
        },
        onDismiss: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryRed,
        child: const Icon(Icons.settings),
        onPressed: () {
          // Load settings (non-blocking) then open dialog
          context.read<SettingsViewModel>().loadSettings();
          showDialog(
            context: context,
            builder: (_) => const SettingsWidget(),
          );
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Compact Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pomodoro icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryRed,
                            AppColors.primaryRed.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryRed.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'ZenFlow',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Pomodoro Timer',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Timer Type Selector
                const TimerTypeSelector(),
                const SizedBox(height: 30),

                // Timer Display
                const TimerDisplay(),
                const SizedBox(height: 30),

                // Timer Controls
                const TimerControls(),
                const SizedBox(height: 30),

                // Cycle Progress
                const CycleProgress(),
                const SizedBox(height: 30),

                // Tasks Section
                const TaskListWidget(),
                const SizedBox(height: 24),

                // Info / About section
                const InfoSection(),
                const SizedBox(height: 24),

                // Footer
                const FooterWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
