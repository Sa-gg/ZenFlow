import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/timer_viewmodel.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  final _focusController = TextEditingController();
  final _shortBreakController = TextEditingController();
  final _longBreakController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsViewModel>().settings;
    _focusController.text = settings.focusDuration.toString();
    _shortBreakController.text = settings.shortBreakDuration.toString();
    _longBreakController.text = settings.longBreakDuration.toString();
  }

  @override
  void dispose() {
    _focusController.dispose();
    _shortBreakController.dispose();
    _longBreakController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsViewModel, TimerViewModel>(
      builder: (context, settingsVm, timerVm, child) {
        final s = settingsVm.settings;
        return Dialog(
          backgroundColor: AppColors.cardBackground,
          insetPadding: const EdgeInsets.all(20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.primaryRed.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.settings,
                                color: AppColors.primaryRed, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Text('Settings',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.darkGrey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: AppColors.textSecondary, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Divider(color: AppColors.darkGrey, thickness: 1),
                  const SizedBox(height: 24),

                  // Time Settings Section
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeInput(
                          icon: Icons.circle,
                          iconColor: AppColors.primaryRed,
                          label: 'Focus',
                          controller: _focusController,
                          hintText: '25',
                          currentValue: s.focusDuration,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTimeInput(
                          icon: Icons.coffee,
                          iconColor: AppColors.progressActive,
                          label: 'Short Break',
                          controller: _shortBreakController,
                          hintText: '5',
                          currentValue: s.shortBreakDuration,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTimeInput(
                          icon: Icons.bed_rounded,
                          iconColor: AppColors.progressActive,
                          label: 'Long Break',
                          controller: _longBreakController,
                          hintText: '15',
                          currentValue: s.longBreakDuration,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Auto-switch toggle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkGrey.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.darkGrey,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Auto-switch between modes',
                                  style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(height: 6),
                              Text(
                                  'Automatically switch between focus and break modes when timer completes',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Switch(
                          value: s.autoSwitch,
                          activeThumbColor: AppColors.progressActive,
                          activeTrackColor:
                              AppColors.progressActive.withValues(alpha: 0.5),
                          onChanged: (v) async {
                            await settingsVm.toggleAutoSwitch();
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Focus sessions stats
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.darkGrey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.darkGrey,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.local_fire_department_rounded,
                                    color: AppColors.primaryRed, size: 20),
                                SizedBox(width: 8),
                                Text('Focus Sessions',
                                    style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                timerVm.resetAll();
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: const Text('Reset'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryRed,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _statColumn('${timerVm.completedCycles}',
                                'Total Completed'),
                            Container(
                              height: 40,
                              width: 1,
                              color: AppColors.darkGrey,
                            ),
                            _statColumn(
                                '${timerVm.currentCycle}', 'Current Cycle'),
                            Container(
                              height: 40,
                              width: 1,
                              color: AppColors.darkGrey,
                            ),
                            _statColumn('${timerVm.completedCycles}/4',
                                'Cycle Progress'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                              4,
                              (index) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: index < timerVm.completedCycles
                                        ? const Icon(Icons.check_circle,
                                            color: AppColors.progressActive,
                                            size: 24)
                                        : Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: AppColors.darkGrey,
                                                  width: 2),
                                            ),
                                          ),
                                  )),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Apply settings
                        final focus = int.tryParse(_focusController.text) ??
                            s.focusDuration;
                        final shortBreak =
                            int.tryParse(_shortBreakController.text) ??
                                s.shortBreakDuration;
                        final longBreak =
                            int.tryParse(_longBreakController.text) ??
                                s.longBreakDuration;

                        // Capture navigator before async gaps
                        final navigator = Navigator.of(context);

                        await settingsVm.updateFocusDuration(focus);
                        await settingsVm.updateShortBreakDuration(shortBreak);
                        await settingsVm.updateLongBreakDuration(longBreak);

                        // Re-initialize timer VM so lengths update
                        await timerVm.initialize();

                        navigator.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_rounded, size: 20),
                          SizedBox(width: 8),
                          Text('Apply',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeInput({
    required IconData icon,
    required Color iconColor,
    required String label,
    required TextEditingController controller,
    required String hintText,
    required int currentValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: AppColors.textTertiary),
            filled: true,
            fillColor: AppColors.darkGrey.withValues(alpha: 0.3),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.darkGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.darkGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: iconColor, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            '$currentValue minutes',
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statColumn(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 24)),
        const SizedBox(height: 6),
        Text(label,
            textAlign: TextAlign.center,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}
