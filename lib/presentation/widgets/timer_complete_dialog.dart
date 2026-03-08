import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/timer_session.dart';

class TimerCompleteDialog extends StatelessWidget {
  final TimerType completedType;
  final TimerType nextType;
  final VoidCallback onContinue;
  final VoidCallback onDismiss;

  const TimerCompleteDialog({
    super.key,
    required this.completedType,
    required this.nextType,
    required this.onContinue,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isBreakComplete = completedType != TimerType.focus;

    // Simple tap-to-dismiss overlay
    return GestureDetector(
      onTap: onDismiss,
      behavior: HitTestBehavior.opaque,
      child: Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isBreakComplete
                        ? AppColors.progressActive.withValues(alpha: 0.15)
                        : AppColors.primaryRed.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isBreakComplete
                        ? Icons.check_circle_outline_rounded
                        : Icons.local_fire_department_rounded,
                    color: isBreakComplete
                        ? AppColors.progressActive
                        : AppColors.primaryRed,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  _getTitle(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  _getMessage(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),

                // Tap hint
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.darkGrey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Tap anywhere to continue',
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    switch (completedType) {
      case TimerType.focus:
        return 'Focus Complete! 🎯';
      case TimerType.shortBreak:
        return 'Break Complete! ☕';
      case TimerType.longBreak:
        return 'Long Break Complete! 🌟';
    }
  }

  String _getMessage() {
    switch (completedType) {
      case TimerType.focus:
        return 'Great work! Time for a ${nextType == TimerType.longBreak ? 'long' : 'short'} break.';
      case TimerType.shortBreak:
        return 'Refreshed and ready? Let\'s get back to focus!';
      case TimerType.longBreak:
        return 'Well rested! Ready for another focus session?';
    }
  }
}
