import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/timer_viewmodel.dart';
import '../../core/theme/app_colors.dart';

class TimerControls extends StatelessWidget {
  const TimerControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerViewModel>(
      builder: (context, viewModel, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (viewModel.isRunning) ...[
              // Pause button
              _buildControlButton(
                icon: Icons.pause_rounded,
                onPressed: viewModel.pause,
                isPrimary: true,
              ),
            ] else ...[
              // Start button
              _buildControlButton(
                icon: Icons.play_arrow_rounded,
                label: 'START',
                onPressed: viewModel.start,
                isPrimary: true,
                isLarge: true,
              ),
            ],
            if (viewModel.isRunning) ...[
              const SizedBox(width: 16),
              // Reset button (visible only while running)
              _buildControlButton(
                icon: Icons.refresh_rounded,
                onPressed: viewModel.reset,
                isPrimary: false,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    String? label,
    required VoidCallback onPressed,
    required bool isPrimary,
    bool isLarge = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? AppColors.primaryRed : AppColors.darkGrey,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isLarge ? 48 : 24,
          vertical: isLarge ? 20 : 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 6,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isLarge ? 28 : 24),
          if (label != null) ...[
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isLarge ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
