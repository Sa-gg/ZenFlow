import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class InfoSection extends StatelessWidget {
  const InfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What is Pomodoro Technique?',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryRed)),
          const SizedBox(height: 8),
          Text(
            'The Pomodoro Technique is created by Francesco Cirillo for a more productive way to work and study. The technique uses a timer to break down work into intervals, traditionally 25 minutes in length, separated by short breaks. Each interval is known as a pomodoro, from the Italian word for \"tomato\", after the tomato-shaped kitchen timer that Cirillo used as a university student.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Text('What is ZenFlow?',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryRed)),
          const SizedBox(height: 8),
          Text(
            'ZenFlow is a small clone project inspired by pomofocus.io. This application is built with Flutter and styled to provide a focused dark UI. It employs the Pomodoro Technique, helping users break down their work into focused intervals interspersed with short breaks. This approach enhances concentration, minimizes distractions, and ultimately boosts overall productivity.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
