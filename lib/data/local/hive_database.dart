import 'package:hive_flutter/hive_flutter.dart';
import '../models/script_model.dart';
import '../models/settings_model.dart';
import '../../core/constants/app_constants.dart';

class HiveDatabase {
  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register Adapters
    Hive.registerAdapter(ScriptModelAdapter());
    Hive.registerAdapter(SettingsModelAdapter());
    
    // Open Boxes
    await Hive.openBox<ScriptModel>(AppConstants.scriptsBoxName);
    await Hive.openBox<SettingsModel>(AppConstants.settingsBoxName);
  }
  
  static Box<ScriptModel> get scriptsBox => 
      Hive.box<ScriptModel>(AppConstants.scriptsBoxName);
  
  static Box<SettingsModel> get settingsBox => 
      Hive.box<SettingsModel>(AppConstants.settingsBoxName);
  
  static Future<void> close() async {
    await Hive.close();
  }
}

