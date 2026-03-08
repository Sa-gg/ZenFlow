import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/timer_viewmodel.dart';
import '../../domain/entities/timer_session.dart';
import '../../core/theme/app_colors.dart';

class CycleProgress extends StatefulWidget {
  const CycleProgress({super.key});

  @override
  State<CycleProgress> createState() => _CycleProgressState();
}

class _CycleProgressState extends State<CycleProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerViewModel>(
      builder: (context, viewModel, child) {
        // Control animation: animate whenever we're in focus mode (regardless of running state)
        final shouldAnimate = viewModel.currentTimerType == TimerType.focus;

        if (shouldAnimate) {
          if (!_blinkController.isAnimating) {
            _blinkController.repeat(reverse: true);
          }
        } else {
          if (_blinkController.isAnimating) {
            _blinkController.stop();
            _blinkController.reset();
          }
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(
                    icon: Icons.local_fire_department_rounded,
                    value: '${viewModel.currentCycle}/4',
                    label: 'Current Cycle',
                  ),
                  _buildStat(
                    icon: Icons.emoji_events_rounded,
                    value: '${viewModel.completedCycles}',
                    label: 'Cycle Number',
                  ),
                  _buildStat(
                    icon: Icons.trending_up_rounded,
                    value: '${viewModel.totalFocusSessions}',
                    label: 'Total Focus',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Cycle Progress',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 32, // Fixed height to prevent jumping
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    // Dots before currentCycle are completed (green checks)
                    final isCompleted = index < viewModel.currentCycle;
                    // The current ongoing focus session dot (the one actively being worked on)
                    final isCurrentFocus = index == viewModel.currentCycle &&
                        viewModel.currentTimerType == TimerType.focus;
                    // Inactive/upcoming dots
                    final isInactive = index > viewModel.currentCycle;
                    // During breaks, the "current" dot should appear inactive
                    final isBreakMode =
                        viewModel.currentTimerType != TimerType.focus;

                    Widget dot;
                    if (isCompleted) {
                      // Completed: show a green check
                      dot = _buildCompletedDot();
                    } else if (isCurrentFocus && !isBreakMode) {
                      // Current focus session: red ring with pulse animation (always animate in focus mode)
                      dot = ScaleTransition(
                        scale: _blinkController
                            .drive(Tween(begin: 0.85, end: 1.15)),
                        child: _buildCurrentFocusDot(),
                      );
                    } else if (index == viewModel.currentCycle && isBreakMode) {
                      // During break mode, the "current" dot shows as inactive (no red ring)
                      dot = _buildInactiveDot();
                    } else if (isInactive) {
                      dot = _buildInactiveDot();
                    } else {
                      dot = _buildInactiveDot();
                    }

                    return SizedBox(
                      width: 40, // Fixed width for each dot slot
                      child: Center(child: dot), // Center dot within fixed space
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primaryRed,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressDot(bool isActive, bool isCurrent) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.progressActive : AppColors.progressInactive,
        border: Border.all(
          color: isActive ? AppColors.primaryRed : AppColors.textTertiary,
          width: isCurrent ? 3 : 2,
        ),
      ),
      child: isCurrent
          ? Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.primaryRed),
            )
          : null,
    );
  }

  Widget _buildCompletedDot() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.success,
        border: Border.all(color: AppColors.success, width: 2),
      ),
      child: Icon(Icons.check, size: 14, color: Colors.white),
    );
  }

  Widget _buildCurrentFocusDot() {
    // Red ring around the current focus dot (like in the reference)
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryRed, width: 3),
      ),
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryRed,
        ),
      ),
    );
  }

  Widget _buildCurrentDot() {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.progressActive,
        border: Border.all(color: AppColors.primaryRed, width: 3),
      ),
      child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: AppColors.primaryRed)),
    );
  }

  Widget _buildInactiveDot() {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.progressInactive,
          border: Border.all(color: AppColors.textTertiary, width: 2)),
    );
  }
}
