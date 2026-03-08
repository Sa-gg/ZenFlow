import 'package:hive/hive.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../models/settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final Box<SettingsModel> _settingsBox;
  static const String _settingsKey = 'app_settings';

  SettingsRepositoryImpl(this._settingsBox);

  @override
  Future<AppSettings> getSettings() async {
    final model = _settingsBox.get(_settingsKey);
    if (model == null) {
      // Return default settings
      const defaultSettings = AppSettings();
      await saveSettings(defaultSettings);
      return defaultSettings;
    }
    return model.toEntity();
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    final model = SettingsModel.fromEntity(settings);
    await _settingsBox.put(_settingsKey, model);
  }
}
