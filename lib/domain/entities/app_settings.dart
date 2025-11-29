import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final int focusDuration;
  final int shortBreakDuration;
  final int longBreakDuration;
  final int cyclesBeforeLongBreak;
  final bool soundEnabled;
  final bool notificationsEnabled;
  final bool autoSwitch;

  const AppSettings({
    this.focusDuration = 25,
    this.shortBreakDuration = 5,
    this.longBreakDuration = 15,
    this.cyclesBeforeLongBreak = 4,
    this.soundEnabled = true,
    this.notificationsEnabled = true,
    this.autoSwitch = true,
  });

  AppSettings copyWith({
    int? focusDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    int? cyclesBeforeLongBreak,
    bool? soundEnabled,
    bool? notificationsEnabled,
    bool? autoSwitch,
  }) {
    return AppSettings(
      focusDuration: focusDuration ?? this.focusDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      cyclesBeforeLongBreak:
          cyclesBeforeLongBreak ?? this.cyclesBeforeLongBreak,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoSwitch: autoSwitch ?? this.autoSwitch,
    );
  }

  @override
  List<Object?> get props => [
        focusDuration,
        shortBreakDuration,
        longBreakDuration,
        cyclesBeforeLongBreak,
        soundEnabled,
        notificationsEnabled,
        autoSwitch,
      ];
}
