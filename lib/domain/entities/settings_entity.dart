import 'package:equatable/equatable.dart';

class SettingsEntity extends Equatable {
  final bool isDarkMode;
  final double scrollSpeed;
  final double fontSize;
  final double margin;
  final int countdown;
  final bool horizontalMirror;
  final bool verticalMirror;
  final String fontFamily;
  
  const SettingsEntity({
    this.isDarkMode = true,
    this.scrollSpeed = 50.0,
    this.fontSize = 24.0,
    this.margin = 16.0,
    this.countdown = 3,
    this.horizontalMirror = false,
    this.verticalMirror = false,
    this.fontFamily = 'Roboto',
  });
  
  SettingsEntity copyWith({
    bool? isDarkMode,
    double? scrollSpeed,
    double? fontSize,
    double? margin,
    int? countdown,
    bool? horizontalMirror,
    bool? verticalMirror,
    String? fontFamily,
  }) {
    return SettingsEntity(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      scrollSpeed: scrollSpeed ?? this.scrollSpeed,
      fontSize: fontSize ?? this.fontSize,
      margin: margin ?? this.margin,
      countdown: countdown ?? this.countdown,
      horizontalMirror: horizontalMirror ?? this.horizontalMirror,
      verticalMirror: verticalMirror ?? this.verticalMirror,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
  
  @override
  List<Object?> get props => [
    isDarkMode,
    scrollSpeed,
    fontSize,
    margin,
    countdown,
    horizontalMirror,
    verticalMirror,
    fontFamily,
  ];
}

