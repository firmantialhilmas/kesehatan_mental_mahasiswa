// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screening_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScreeningHistoryAdapter extends TypeAdapter<ScreeningHistory> {
  @override
  final int typeId = 2;

  @override
  ScreeningHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScreeningHistory(
      score: fields[0] as int,
      name: fields[1] as String,
      age: fields[2] as int,
      timestamp: fields[3] as DateTime,
      answers: (fields[4] as List?)?.cast<int>(),
      category: fields[5] as String?,
      probability: fields[6] as double?,
      allProbabilities: (fields[7] as Map?)?.cast<String, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, ScreeningHistory obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.score)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.age)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.answers)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.probability)
      ..writeByte(7)
      ..write(obj.allProbabilities);
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
