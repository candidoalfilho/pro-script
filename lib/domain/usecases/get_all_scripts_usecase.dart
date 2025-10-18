import '../entities/script_entity.dart';
import '../../data/repositories/script_repository.dart';

class GetAllScriptsUseCase {
  final ScriptRepository repository;
  
  GetAllScriptsUseCase(this.repository);
  
  Future<List<ScriptEntity>> call() async {
    return await repository.getAllScripts();
  }
}

