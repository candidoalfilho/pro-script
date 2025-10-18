import 'package:flutter_bloc/flutter_bloc.dart';
import 'teleprompter_event.dart';
import 'teleprompter_state.dart';

class TeleprompterBloc extends Bloc<TeleprompterEvent, TeleprompterState> {
  TeleprompterBloc() : super(TeleprompterInitial()) {
    on<StartTeleprompter>(_onStartTeleprompter);
    on<PlayTeleprompter>(_onPlayTeleprompter);
    on<PauseTeleprompter>(_onPauseTeleprompter);
    on<ResetTeleprompter>(_onResetTeleprompter);
    on<UpdateScrollPosition>(_onUpdateScrollPosition);
    on<UpdateSpeed>(_onUpdateSpeed);
  }
  
  void _onStartTeleprompter(StartTeleprompter event, Emitter<TeleprompterState> emit) {
    emit(TeleprompterReady(content: event.content));
  }
  
  void _onPlayTeleprompter(PlayTeleprompter event, Emitter<TeleprompterState> emit) {
    if (state is TeleprompterReady) {
      final currentState = state as TeleprompterReady;
      emit(currentState.copyWith(isPlaying: true));
    }
  }
  
  void _onPauseTeleprompter(PauseTeleprompter event, Emitter<TeleprompterState> emit) {
    if (state is TeleprompterReady) {
      final currentState = state as TeleprompterReady;
      emit(currentState.copyWith(isPlaying: false));
    }
  }
  
  void _onResetTeleprompter(ResetTeleprompter event, Emitter<TeleprompterState> emit) {
    if (state is TeleprompterReady) {
      final currentState = state as TeleprompterReady;
      emit(currentState.copyWith(
        isPlaying: false,
        scrollPosition: 0.0,
      ));
    }
  }
  
  void _onUpdateScrollPosition(UpdateScrollPosition event, Emitter<TeleprompterState> emit) {
    if (state is TeleprompterReady) {
      final currentState = state as TeleprompterReady;
      emit(currentState.copyWith(scrollPosition: event.position));
    }
  }
  
  void _onUpdateSpeed(UpdateSpeed event, Emitter<TeleprompterState> emit) {
    if (state is TeleprompterReady) {
      final currentState = state as TeleprompterReady;
      emit(currentState.copyWith(speed: event.speed));
    }
  }
}

