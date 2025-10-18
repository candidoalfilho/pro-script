import 'package:hive/hive.dart';
import '../../domain/entities/settings_entity.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 1)
class SettingsModel extends HiveObject {
  @HiveField(0)
  final bool isDarkMode;
  
  @HiveField(1)
  final double scrollSpeed;
  
  @HiveField(2)
  final double fontSize;
  
  @HiveField(3)
  final double margin;
  
  @HiveField(4)
  final int countdown;
  
  @HiveField(5)
  final bool horizontalMirror;
  
  @HiveField(6)
  final bool verticalMirror;
  
  @HiveField(7)
  final String fontFamily;
  
  SettingsModel({
    this.isDarkMode = true,
    this.scrollSpeed = 50.0,
    this.fontSize = 24.0,
    this.margin = 16.0,
    this.countdown = 3,
    this.horizontalMirror = false,
    this.verticalMirror = false,
    this.fontFamily = 'Roboto',
  });
  
  // Convert to Entity
  SettingsEntity toEntity() {
    return SettingsEntity(
      isDarkMode: isDarkMode,
      scrollSpeed: scrollSpeed,
      fontSize: fontSize,
      margin: margin,
      countdown: countdown,
      horizontalMirror: horizontalMirror,
      verticalMirror: verticalMirror,
      fontFamily: fontFamily,
    );
  }
  
  // Convert from Entity
  factory SettingsModel.fromEntity(SettingsEntity entity) {
    return SettingsModel(
      isDarkMode: entity.isDarkMode,
      scrollSpeed: entity.scrollSpeed,
      fontSize: entity.fontSize,
      margin: entity.margin,
      countdown: entity.countdown,
      horizontalMirror: entity.horizontalMirror,
      verticalMirror: entity.verticalMirror,
      fontFamily: entity.fontFamily,
    );
  }
  
  SettingsModel copyWith({
    bool? isDarkMode,
    double? scrollSpeed,
    double? fontSize,
    double? margin,
    int? countdown,
    bool? horizontalMirror,
    bool? verticalMirror,
    String? fontFamily,
  }) {
    return SettingsModel(
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
}

