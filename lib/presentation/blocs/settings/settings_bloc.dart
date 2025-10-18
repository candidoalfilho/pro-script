import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_settings_usecase.dart';
import '../../../domain/usecases/save_settings_usecase.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetSettingsUseCase getSettingsUseCase;
  final SaveSettingsUseCase saveSettingsUseCase;
  
  SettingsBloc({
    required this.getSettingsUseCase,
    required this.saveSettingsUseCase,
  }) : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateSettings>(_onUpdateSettings);
    on<ToggleTheme>(_onToggleTheme);
    on<UpdateScrollSpeed>(_onUpdateScrollSpeed);
    on<UpdateFontSize>(_onUpdateFontSize);
    on<UpdateMargin>(_onUpdateMargin);
    on<ToggleHorizontalMirror>(_onToggleHorizontalMirror);
    on<ToggleVerticalMirror>(_onToggleVerticalMirror);
  }
  
  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    try {
      final settings = await getSettingsUseCase();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError('Erro ao carregar configurações: $e'));
    }
  }
  
  Future<void> _onUpdateSettings(UpdateSettings event, Emitter<SettingsState> emit) async {
    try {
      await saveSettingsUseCase(event.settings);
      emit(SettingsLoaded(event.settings));
    } catch (e) {
      emit(SettingsError('Erro ao salvar configurações: $e'));
    }
  }
  
  Future<void> _onToggleTheme(ToggleTheme event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(
        isDarkMode: !currentState.settings.isDarkMode,
      );
      await saveSettingsUseCase(updatedSettings);
      emit(SettingsLoaded(updatedSettings));
    }
  }
  
  Future<void> _onUpdateScrollSpeed(UpdateScrollSpeed event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(
        scrollSpeed: event.speed,
      );
      await saveSettingsUseCase(updatedSettings);
      emit(SettingsLoaded(updatedSettings));
    }
  }
  
  Future<void> _onUpdateFontSize(UpdateFontSize event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(
        fontSize: event.fontSize,
      );
      await saveSettingsUseCase(updatedSettings);
      emit(SettingsLoaded(updatedSettings));
    }
  }
  
  Future<void> _onUpdateMargin(UpdateMargin event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(
        margin: event.margin,
      );
      await saveSettingsUseCase(updatedSettings);
      emit(SettingsLoaded(updatedSettings));
    }
  }
  
  Future<void> _onToggleHorizontalMirror(ToggleHorizontalMirror event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(
        horizontalMirror: !currentState.settings.horizontalMirror,
      );
      await saveSettingsUseCase(updatedSettings);
      emit(SettingsLoaded(updatedSettings));
    }
  }
  
  Future<void> _onToggleVerticalMirror(ToggleVerticalMirror event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      final updatedSettings = currentState.settings.copyWith(
        verticalMirror: !currentState.settings.verticalMirror,
      );
      await saveSettingsUseCase(updatedSettings);
      emit(SettingsLoaded(updatedSettings));
    }
  }
}

