import 'package:equatable/equatable.dart';
import '../../../domain/entities/settings_entity.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateSettings extends SettingsEvent {
  final SettingsEntity settings;
  
  const UpdateSettings(this.settings);
  
  @override
  List<Object?> get props => [settings];
}

class ToggleTheme extends SettingsEvent {}

class UpdateScrollSpeed extends SettingsEvent {
  final double speed;
  
  const UpdateScrollSpeed(this.speed);
  
  @override
  List<Object?> get props => [speed];
}

class UpdateFontSize extends SettingsEvent {
  final double fontSize;
  
  const UpdateFontSize(this.fontSize);
  
  @override
  List<Object?> get props => [fontSize];
}

class UpdateMargin extends SettingsEvent {
  final double margin;
  
  const UpdateMargin(this.margin);
  
  @override
  List<Object?> get props => [margin];
}

class ToggleHorizontalMirror extends SettingsEvent {}

class ToggleVerticalMirror extends SettingsEvent {}

