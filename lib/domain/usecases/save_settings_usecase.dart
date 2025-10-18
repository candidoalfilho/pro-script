import '../entities/settings_entity.dart';
import '../../data/repositories/settings_repository.dart';

class SaveSettingsUseCase {
  final SettingsRepository repository;
  
  SaveSettingsUseCase(this.repository);
  
  Future<void> call(SettingsEntity settings) async {
    await repository.saveSettings(settings);
  }
}

