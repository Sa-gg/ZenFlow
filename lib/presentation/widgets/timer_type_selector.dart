import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/timer_session.dart';
import '../viewmodels/timer_viewmodel.dart';
import '../../core/theme/app_colors.dart';

class TimerTypeSelector extends StatefulWidget {
  const TimerTypeSelector({super.key});

  @override
  State<TimerTypeSelector> createState() => _TimerTypeSelectorState();
}

class _TimerTypeSelectorState extends State<TimerTypeSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  TimerType? _previousType;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateAnimation(TimerType currentType) {
    double targetPosition;
    switch (currentType) {
      case TimerType.focus:
        targetPosition = 0;
        break;
      case TimerType.shortBreak:
        targetPosition = 1;
        break;
      case TimerType.longBreak:
        targetPosition = 2;
        break;
    }

    if (_previousType != currentType) {
      _slideAnimation = Tween<double>(
        begin: _slideAnimation.value,
        end: targetPosition,
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );
      _animationController.forward(from: 0);
      _previousType = currentType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerViewModel>(
      builder: (context, viewModel, child) {
        _updateAnimation(viewModel.currentTimerType);

        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(30),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = (constraints.maxWidth - 8) / 3;

              return Stack(
                children: [
                  // Animated sliding background
                  AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return AnimatedPositioned(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        left: 4 + (_slideAnimation.value * tabWidth),
                        top: 0,
                        bottom: 0,
                        width: tabWidth,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryRed.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Tab buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildTab(
                          context,
                          'Focus',
                          Icons.psychology_rounded,
                          TimerType.focus,
                          viewModel.currentTimerType == TimerType.focus,
                          () => viewModel.setTimerType(TimerType.focus),
                        ),
                      ),
                      Expanded(
                        child: _buildTab(
                          context,
                          'Short Break',
                          Icons.coffee_rounded,
                          TimerType.shortBreak,
                          viewModel.currentTimerType == TimerType.shortBreak,
                          () => viewModel.setTimerType(TimerType.shortBreak),
                        ),
                      ),
                      Expanded(
                        child: _buildTab(
                          context,
                          'Long Break',
                          Icons.beach_access_rounded,
                          TimerType.longBreak,
                          viewModel.currentTimerType == TimerType.longBreak,
                          () => viewModel.setTimerType(TimerType.longBreak),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTab(
    BuildContext context,
    String label,
    IconData icon,
    TimerType type,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 18,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
              child: Icon(
                icon,
                size: 18,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                ),
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
