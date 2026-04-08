// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screening_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScreeningHistoryAdapter extends TypeAdapter<ScreeningHistory> {
  @override
  final int typeId = 0;

  @override
  ScreeningHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScreeningHistory(
      date: fields[0] as DateTime,
      score: fields[1] as int,
      riskLevel: fields[2] as String,
      name: fields[3] as String,
      age: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ScreeningHistory obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.score)
      ..writeByte(2)
      ..write(obj.riskLevel)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.age);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScreeningHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
