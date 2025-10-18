import '../../data/repositories/script_repository.dart';

class DeleteScriptUseCase {
  final ScriptRepository repository;
  
  DeleteScriptUseCase(this.repository);
  
  Future<void> call(String id) async {
    await repository.deleteScript(id);
  }
}

