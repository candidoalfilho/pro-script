import '../../domain/entities/script_entity.dart';
import '../models/script_model.dart';
import '../local/hive_database.dart';

abstract class ScriptRepository {
  Future<List<ScriptEntity>> getAllScripts();
  Future<ScriptEntity?> getScriptById(String id);
  Future<void> saveScript(ScriptEntity script);
  Future<void> updateScript(ScriptEntity script);
  Future<void> deleteScript(String id);
  Future<List<ScriptEntity>> getFavoriteScripts();
  Future<List<ScriptEntity>> searchScripts(String query);
}

class ScriptRepositoryImpl implements ScriptRepository {
  @override
  Future<List<ScriptEntity>> getAllScripts() async {
    final box = HiveDatabase.scriptsBox;
    final scripts = box.values.map((model) => model.toEntity()).toList();
    // Sort by updated date (most recent first)
    scripts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return scripts;
  }
  
  @override
  Future<ScriptEntity?> getScriptById(String id) async {
    final box = HiveDatabase.scriptsBox;
    final model = box.values.firstWhere(
      (script) => script.id == id,
      orElse: () => throw Exception('Script not found'),
    );
    return model.toEntity();
  }
  
  @override
  Future<void> saveScript(ScriptEntity script) async {
    final box = HiveDatabase.scriptsBox;
    final model = ScriptModel.fromEntity(script);
    await box.put(script.id, model);
  }
  
  @override
  Future<void> updateScript(ScriptEntity script) async {
    final box = HiveDatabase.scriptsBox;
    final model = ScriptModel.fromEntity(script);
    await box.put(script.id, model);
  }
  
  @override
  Future<void> deleteScript(String id) async {
    final box = HiveDatabase.scriptsBox;
    await box.delete(id);
  }
  
  @override
  Future<List<ScriptEntity>> getFavoriteScripts() async {
    final box = HiveDatabase.scriptsBox;
    final favorites = box.values
        .where((script) => script.isFavorite)
        .map((model) => model.toEntity())
        .toList();
    favorites.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return favorites;
  }
  
  @override
  Future<List<ScriptEntity>> searchScripts(String query) async {
    final box = HiveDatabase.scriptsBox;
    final queryLower = query.toLowerCase();
    final results = box.values
        .where((script) =>
            script.title.toLowerCase().contains(queryLower) ||
            script.content.toLowerCase().contains(queryLower))
        .map((model) => model.toEntity())
        .toList();
    results.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return results;
  }
}

