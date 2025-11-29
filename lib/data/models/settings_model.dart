import 'package:hive/hive.dart';
import '../../domain/entities/app_settings.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 2)
class SettingsModel extends HiveObject {
  @HiveField(0)
  int focusDuration;

  @HiveField(1)
  int shortBreakDuration;

  @HiveField(2)
  int longBreakDuration;

  @HiveField(3)
  int cyclesBeforeLongBreak;

  @HiveField(4)
  bool soundEnabled;

  @HiveField(5)
  bool notificationsEnabled;

  @HiveField(6)
  bool autoSwitch;

  SettingsModel({
    this.focusDuration = 25,
    this.shortBreakDuration = 5,
    this.longBreakDuration = 15,
    this.cyclesBeforeLongBreak = 4,
    this.soundEnabled = true,
    this.notificationsEnabled = true,
    this.autoSwitch = true,
  });

  // Convert from domain entity
  factory SettingsModel.fromEntity(AppSettings settings) {
    return SettingsModel(
      focusDuration: settings.focusDuration,
      shortBreakDuration: settings.shortBreakDuration,
      longBreakDuration: settings.longBreakDuration,
      cyclesBeforeLongBreak: settings.cyclesBeforeLongBreak,
      soundEnabled: settings.soundEnabled,
      notificationsEnabled: settings.notificationsEnabled,
      autoSwitch: settings.autoSwitch,
    );
  }

  // Convert to domain entity
  AppSettings toEntity() {
    return AppSettings(
      focusDuration: focusDuration,
      shortBreakDuration: shortBreakDuration,
      longBreakDuration: longBreakDuration,
      cyclesBeforeLongBreak: cyclesBeforeLongBreak,
      soundEnabled: soundEnabled,
      notificationsEnabled: notificationsEnabled,
      autoSwitch: autoSwitch,
    );
  }
}
