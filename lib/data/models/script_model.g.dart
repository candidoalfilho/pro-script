// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'script_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScriptModelAdapter extends TypeAdapter<ScriptModel> {
  @override
  final int typeId = 0;

  @override
  ScriptModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScriptModel(
      id: fields[0] as String,
      title: fields[1] as String,
      content: fields[2] as String,
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
      isFavorite: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ScriptModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.isFavorite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScriptModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
