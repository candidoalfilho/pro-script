import 'package:equatable/equatable.dart';
import '../../../domain/entities/script_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ScriptEntity> scripts;
  final bool showOnlyFavorites;
  
  const HomeLoaded({
    required this.scripts,
    this.showOnlyFavorites = false,
  });
  
  @override
  List<Object?> get props => [scripts, showOnlyFavorites];
}

class HomeError extends HomeState {
  final String message;
  
  const HomeError(this.message);
  
  @override
  List<Object?> get props => [message];
}

