import '../entities/script_entity.dart';
import '../../data/repositories/script_repository.dart';

class SaveScriptUseCase {
  final ScriptRepository repository;
  
  SaveScriptUseCase(this.repository);
  
  Future<void> call(ScriptEntity script) async {
    await repository.saveScript(script);
  }
}

