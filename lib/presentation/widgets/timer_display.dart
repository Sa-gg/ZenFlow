import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../viewmodels/timer_viewmodel.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/timer_session.dart';

class TimerDisplay extends StatelessWidget {
  const TimerDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerViewModel>(
      builder: (context, viewModel, child) {
        return SizedBox(
          width: double.infinity,
          height: 380,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Circular progress indicator
              SizedBox(
                width: 320,
                height: 320,
                child: CustomPaint(
                  painter: CircularTimerPainter(
                    progress: viewModel.progress,
                    timerType: viewModel.currentTimerType,
                  ),
                ),
              ),

              // Inner circle with time
              Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cardBackground,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      viewModel.timeDisplay,
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 3,
                      width: 100,
                      decoration: BoxDecoration(
                        color: _getTimerColor(viewModel.currentTimerType),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getTimerColor(TimerType type) {
    switch (type) {
      case TimerType.focus:
        return AppColors.focusColor;
      case TimerType.shortBreak:
        return AppColors.shortBreakColor;
      case TimerType.longBreak:
        return AppColors.longBreakColor;
    }
  }
}

class CircularTimerPainter extends CustomPainter {
  final double progress;
  final TimerType timerType;

  CircularTimerPainter({
    required this.progress,
    required this.timerType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = AppColors.progressInactive
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = _getTimerColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  Color _getTimerColor() {
    switch (timerType) {
      case TimerType.focus:
        return AppColors.focusColor;
      case TimerType.shortBreak:
        return AppColors.shortBreakColor;
      case TimerType.longBreak:
        return AppColors.longBreakColor;
    }
  }

  @override
  bool shouldRepaint(CircularTimerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.timerType != timerType;
  }
}
