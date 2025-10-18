import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadScripts extends HomeEvent {}

class SearchScripts extends HomeEvent {
  final String query;
  
  const SearchScripts(this.query);
  
  @override
  List<Object?> get props => [query];
}

class DeleteScript extends HomeEvent {
  final String id;
  
  const DeleteScript(this.id);
  
  @override
  List<Object?> get props => [id];
}

class ToggleFavorite extends HomeEvent {
  final String id;
  
  const ToggleFavorite(this.id);
  
  @override
  List<Object?> get props => [id];
}

class FilterFavorites extends HomeEvent {
  final bool showOnlyFavorites;
  
  const FilterFavorites(this.showOnlyFavorites);
  
  @override
  List<Object?> get props => [showOnlyFavorites];
}

