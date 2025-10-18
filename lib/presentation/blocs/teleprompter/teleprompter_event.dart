import 'package:equatable/equatable.dart';

abstract class TeleprompterEvent extends Equatable {
  const TeleprompterEvent();
  
  @override
  List<Object?> get props => [];
}

class StartTeleprompter extends TeleprompterEvent {
  final String content;
  
  const StartTeleprompter(this.content);
  
  @override
  List<Object?> get props => [content];
}

class PlayTeleprompter extends TeleprompterEvent {}

class PauseTeleprompter extends TeleprompterEvent {}

class ResetTeleprompter extends TeleprompterEvent {}

class UpdateScrollPosition extends TeleprompterEvent {
  final double position;
  
  const UpdateScrollPosition(this.position);
  
  @override
  List<Object?> get props => [position];
}

class UpdateSpeed extends TeleprompterEvent {
  final double speed;
  
  const UpdateSpeed(this.speed);
  
  @override
  List<Object?> get props => [speed];
}

