import 'package:equatable/equatable.dart';

abstract class EditorEvent extends Equatable {
  const EditorEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadScript extends EditorEvent {
  final String? scriptId;
  
  const LoadScript({this.scriptId});
  
  @override
  List<Object?> get props => [scriptId];
}

class UpdateTitle extends EditorEvent {
  final String title;
  
  const UpdateTitle(this.title);
  
  @override
  List<Object?> get props => [title];
}

class UpdateContent extends EditorEvent {
  final String content;
  
  const UpdateContent(this.content);
  
  @override
  List<Object?> get props => [content];
}

class SaveScript extends EditorEvent {}

class AutoSaveScript extends EditorEvent {}

