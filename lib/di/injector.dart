import 'package:get_it/get_it.dart';
import '../data/repositories/script_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../domain/usecases/get_all_scripts_usecase.dart';
import '../domain/usecases/save_script_usecase.dart';
import '../domain/usecases/delete_script_usecase.dart';
import '../domain/usecases/get_settings_usecase.dart';
import '../domain/usecases/save_settings_usecase.dart';
import '../presentation/blocs/home/home_bloc.dart';
import '../presentation/blocs/editor/editor_bloc.dart';
import '../presentation/blocs/teleprompter/teleprompter_bloc.dart';
import '../presentation/blocs/settings/settings_bloc.dart';
import '../core/services/ad_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Services
  getIt.registerSingleton<AdService>(AdService());
  
  // Repositories
  getIt.registerLazySingleton<ScriptRepository>(() => ScriptRepositoryImpl());
  getIt.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl());
  
  // Use Cases - Scripts
  getIt.registerLazySingleton(() => GetAllScriptsUseCase(getIt<ScriptRepository>()));
  getIt.registerLazySingleton(() => SaveScriptUseCase(getIt<ScriptRepository>()));
  getIt.registerLazySingleton(() => DeleteScriptUseCase(getIt<ScriptRepository>()));
  
  // Use Cases - Settings
  getIt.registerLazySingleton(() => GetSettingsUseCase(getIt<SettingsRepository>()));
  getIt.registerLazySingleton(() => SaveSettingsUseCase(getIt<SettingsRepository>()));
  
  // Blocs
  getIt.registerFactory(() => HomeBloc(
    getAllScriptsUseCase: getIt<GetAllScriptsUseCase>(),
    deleteScriptUseCase: getIt<DeleteScriptUseCase>(),
    saveScriptUseCase: getIt<SaveScriptUseCase>(),
    scriptRepository: getIt<ScriptRepository>(),
  ));
  
  getIt.registerFactory(() => EditorBloc(
    saveScriptUseCase: getIt<SaveScriptUseCase>(),
    scriptRepository: getIt<ScriptRepository>(),
  ));
  
  getIt.registerFactory(() => TeleprompterBloc());
  
  getIt.registerLazySingleton(() => SettingsBloc(
    getSettingsUseCase: getIt<GetSettingsUseCase>(),
    saveSettingsUseCase: getIt<SaveSettingsUseCase>(),
  ));
}

