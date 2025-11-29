import 'package:flutter/material.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _settingsRepository;

  SettingsViewModel(this._settingsRepository);

  AppSettings _settings = const AppSettings();

  AppSettings get settings => _settings;

  Future<void> loadSettings() async {
    _settings = await _settingsRepository.getSettings();
    notifyListeners();
  }

  Future<void> updateFocusDuration(int minutes) async {
    _settings = _settings.copyWith(focusDuration: minutes);
    await _settingsRepository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateShortBreakDuration(int minutes) async {
    _settings = _settings.copyWith(shortBreakDuration: minutes);
    await _settingsRepository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateLongBreakDuration(int minutes) async {
    _settings = _settings.copyWith(longBreakDuration: minutes);
    await _settingsRepository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateCyclesBeforeLongBreak(int cycles) async {
    _settings = _settings.copyWith(cyclesBeforeLongBreak: cycles);
    await _settingsRepository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> toggleSound() async {
    _settings = _settings.copyWith(soundEnabled: !_settings.soundEnabled);
    await _settingsRepository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _settings = _settings.copyWith(
        notificationsEnabled: !_settings.notificationsEnabled);
    await _settingsRepository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> toggleAutoSwitch() async {
    _settings = _settings.copyWith(autoSwitch: !_settings.autoSwitch);
    await _settingsRepository.saveSettings(_settings);
    notifyListeners();
  }
}
