import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/script_entity.dart';
import '../../../domain/usecases/save_script_usecase.dart';
import '../../../data/repositories/script_repository.dart';
import 'editor_event.dart';
import 'editor_state.dart';

class EditorBloc extends Bloc<EditorEvent, EditorState> {
  final SaveScriptUseCase saveScriptUseCase;
  final ScriptRepository scriptRepository;
  Timer? _autoSaveTimer;
  
  EditorBloc({
    required this.saveScriptUseCase,
    required this.scriptRepository,
  }) : super(EditorInitial()) {
    on<LoadScript>(_onLoadScript);
    on<UpdateTitle>(_onUpdateTitle);
    on<UpdateContent>(_onUpdateContent);
    on<SaveScript>(_onSaveScript);
    on<AutoSaveScript>(_onAutoSaveScript);
  }
  
  Future<void> _onLoadScript(LoadScript event, Emitter<EditorState> emit) async {
    emit(EditorLoading());
    try {
      if (event.scriptId != null) {
        final script = await scriptRepository.getScriptById(event.scriptId!);
        if (script != null) {
          emit(EditorReady(script: script));
        } else {
          emit(const EditorError('Roteiro não encontrado'));
        }
      } else {
        // Create new script
        final newScript = ScriptEntity(
          id: const Uuid().v4(),
          title: 'Novo Roteiro',
          content: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        emit(EditorReady(script: newScript, hasUnsavedChanges: true));
      }
    } catch (e) {
      emit(EditorError('Erro ao carregar roteiro: $e'));
    }
  }
  
  void _onUpdateTitle(UpdateTitle event, Emitter<EditorState> emit) {
    if (state is EditorReady) {
      final currentState = state as EditorReady;
      final updatedScript = currentState.script.copyWith(
        title: event.title,
        updatedAt: DateTime.now(),
      );
      emit(currentState.copyWith(
        script: updatedScript,
        hasUnsavedChanges: true,
      ));
      _scheduleAutoSave();
    }
  }
  
  void _onUpdateContent(UpdateContent event, Emitter<EditorState> emit) {
    if (state is EditorReady) {
      final currentState = state as EditorReady;
      final updatedScript = currentState.script.copyWith(
        content: event.content,
        updatedAt: DateTime.now(),
      );
      emit(currentState.copyWith(
        script: updatedScript,
        hasUnsavedChanges: true,
      ));
      _scheduleAutoSave();
    }
  }
  
  Future<void> _onSaveScript(SaveScript event, Emitter<EditorState> emit) async {
    if (state is EditorReady) {
      final currentState = state as EditorReady;
      emit(currentState.copyWith(isSaving: true));
      
      try {
        await saveScriptUseCase(currentState.script);
        emit(EditorSaved(currentState.script));
        emit(currentState.copyWith(
          isSaving: false,
          hasUnsavedChanges: false,
        ));
      } catch (e) {
        emit(EditorError('Erro ao salvar roteiro: $e'));
        emit(currentState.copyWith(isSaving: false));
      }
    }
  }
  
  Future<void> _onAutoSaveScript(AutoSaveScript event, Emitter<EditorState> emit) async {
    if (state is EditorReady) {
      final currentState = state as EditorReady;
      if (currentState.hasUnsavedChanges) {
        try {
          await saveScriptUseCase(currentState.script);
          emit(currentState.copyWith(hasUnsavedChanges: false));
        } catch (e) {
          // Silent fail for auto-save
        }
      }
    }
  }
  
  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 3), () {
      add(AutoSaveScript());
    });
  }
  
  @override
  Future<void> close() {
    _autoSaveTimer?.cancel();
    return super.close();
  }
}

