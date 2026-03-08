import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 8),
        Text('© 2025 ZenFlow. All rights reserved.',
            style: TextStyle(color: AppColors.textSecondary)),
        SizedBox(height: 4),
        Text('Developed by Sag.',
            style: TextStyle(
                color: AppColors.primaryRed, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
