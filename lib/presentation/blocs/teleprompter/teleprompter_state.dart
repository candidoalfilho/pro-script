import 'package:equatable/equatable.dart';

abstract class TeleprompterState extends Equatable {
  const TeleprompterState();
  
  @override
  List<Object?> get props => [];
}

class TeleprompterInitial extends TeleprompterState {}

class TeleprompterReady extends TeleprompterState {
  final String content;
  final bool isPlaying;
  final double scrollPosition;
  final double speed;
  
  const TeleprompterReady({
    required this.content,
    this.isPlaying = false,
    this.scrollPosition = 0.0,
    this.speed = 50.0,
  });
  
  @override
  List<Object?> get props => [content, isPlaying, scrollPosition, speed];
  
  TeleprompterReady copyWith({
    String? content,
    bool? isPlaying,
    double? scrollPosition,
    double? speed,
  }) {
    return TeleprompterReady(
      content: content ?? this.content,
      isPlaying: isPlaying ?? this.isPlaying,
      scrollPosition: scrollPosition ?? this.scrollPosition,
      speed: speed ?? this.speed,
    );
  }
}

class TeleprompterError extends TeleprompterState {
  final String message;
  
  const TeleprompterError(this.message);
  
  @override
  List<Object?> get props => [message];
}

