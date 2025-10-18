import 'package:equatable/equatable.dart';
import '../../../domain/entities/script_entity.dart';

abstract class EditorState extends Equatable {
  const EditorState();
  
  @override
  List<Object?> get props => [];
}

class EditorInitial extends EditorState {}

class EditorLoading extends EditorState {}

class EditorReady extends EditorState {
  final ScriptEntity script;
  final bool isSaving;
  final bool hasUnsavedChanges;
  
  const EditorReady({
    required this.script,
    this.isSaving = false,
    this.hasUnsavedChanges = false,
  });
  
  @override
  List<Object?> get props => [script, isSaving, hasUnsavedChanges];
  
  EditorReady copyWith({
    ScriptEntity? script,
    bool? isSaving,
    bool? hasUnsavedChanges,
  }) {
    return EditorReady(
      script: script ?? this.script,
      isSaving: isSaving ?? this.isSaving,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }
}

class EditorSaved extends EditorState {
  final ScriptEntity script;
  
  const EditorSaved(this.script);
  
  @override
  List<Object?> get props => [script];
}

class EditorError extends EditorState {
  final String message;
  
  const EditorError(this.message);
  
  @override
  List<Object?> get props => [message];
}

