import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_all_scripts_usecase.dart';
import '../../../domain/usecases/delete_script_usecase.dart';
import '../../../domain/usecases/save_script_usecase.dart';
import '../../../data/repositories/script_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetAllScriptsUseCase getAllScriptsUseCase;
  final DeleteScriptUseCase deleteScriptUseCase;
  final SaveScriptUseCase saveScriptUseCase;
  final ScriptRepository scriptRepository;
  
  HomeBloc({
    required this.getAllScriptsUseCase,
    required this.deleteScriptUseCase,
    required this.saveScriptUseCase,
    required this.scriptRepository,
  }) : super(HomeInitial()) {
    on<LoadScripts>(_onLoadScripts);
    on<SearchScripts>(_onSearchScripts);
    on<DeleteScript>(_onDeleteScript);
    on<ToggleFavorite>(_onToggleFavorite);
    on<FilterFavorites>(_onFilterFavorites);
  }
  
  Future<void> _onLoadScripts(LoadScripts event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final scripts = await getAllScriptsUseCase();
      emit(HomeLoaded(scripts: scripts));
    } catch (e) {
      emit(HomeError('Erro ao carregar roteiros: $e'));
    }
  }
  
  Future<void> _onSearchScripts(SearchScripts event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      if (event.query.isEmpty) {
        final scripts = await getAllScriptsUseCase();
        emit(HomeLoaded(scripts: scripts));
      } else {
        final scripts = await scriptRepository.searchScripts(event.query);
        emit(HomeLoaded(scripts: scripts));
      }
    } catch (e) {
      emit(HomeError('Erro ao buscar roteiros: $e'));
    }
  }
  
  Future<void> _onDeleteScript(DeleteScript event, Emitter<HomeState> emit) async {
    try {
      await deleteScriptUseCase(event.id);
      final scripts = await getAllScriptsUseCase();
      emit(HomeLoaded(scripts: scripts));
    } catch (e) {
      emit(HomeError('Erro ao deletar roteiro: $e'));
    }
  }
  
  Future<void> _onToggleFavorite(ToggleFavorite event, Emitter<HomeState> emit) async {
    try {
      final script = await scriptRepository.getScriptById(event.id);
      if (script != null) {
        final updatedScript = script.copyWith(
          isFavorite: !script.isFavorite,
          updatedAt: DateTime.now(),
        );
        await saveScriptUseCase(updatedScript);
        final scripts = await getAllScriptsUseCase();
        emit(HomeLoaded(scripts: scripts));
      }
    } catch (e) {
      emit(HomeError('Erro ao atualizar favorito: $e'));
    }
  }
  
  Future<void> _onFilterFavorites(FilterFavorites event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      if (event.showOnlyFavorites) {
        final scripts = await scriptRepository.getFavoriteScripts();
        emit(HomeLoaded(scripts: scripts, showOnlyFavorites: true));
      } else {
        final scripts = await getAllScriptsUseCase();
        emit(HomeLoaded(scripts: scripts, showOnlyFavorites: false));
      }
    } catch (e) {
      emit(HomeError('Erro ao filtrar favoritos: $e'));
    }
  }
}

