import '../../domain/entities/settings_entity.dart';
import '../models/settings_model.dart';
import '../local/hive_database.dart';

abstract class SettingsRepository {
  Future<SettingsEntity> getSettings();
  Future<void> saveSettings(SettingsEntity settings);
}

class SettingsRepositoryImpl implements SettingsRepository {
  static const String _settingsKey = 'app_settings';
  
  @override
  Future<SettingsEntity> getSettings() async {
    final box = HiveDatabase.settingsBox;
    final model = box.get(_settingsKey);
    
    if (model != null) {
      return model.toEntity();
    }
    
    // Return default settings if not found
    return const SettingsEntity();
  }
  
  @override
  Future<void> saveSettings(SettingsEntity settings) async {
    final box = HiveDatabase.settingsBox;
    final model = SettingsModel.fromEntity(settings);
    await box.put(_settingsKey, model);
  }
}

