import '../entities/settings_entity.dart';
import '../../data/repositories/settings_repository.dart';

class GetSettingsUseCase {
  final SettingsRepository repository;
  
  GetSettingsUseCase(this.repository);
  
  Future<SettingsEntity> call() async {
    return await repository.getSettings();
  }
}

