// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimerSessionModelAdapter extends TypeAdapter<TimerSessionModel> {
  @override
  final int typeId = 1;

  @override
  TimerSessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimerSessionModel(
      id: fields[0] as String,
      timerTypeIndex: fields[1] as int,
      durationMinutes: fields[2] as int,
      startTime: fields[3] as DateTime,
      endTime: fields[4] as DateTime?,
      completed: fields[5] as bool,
      taskId: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TimerSessionModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timerTypeIndex)
      ..writeByte(2)
      ..write(obj.durationMinutes)
      ..writeByte(3)
      ..write(obj.startTime)
      ..writeByte(4)
      ..write(obj.endTime)
      ..writeByte(5)
      ..write(obj.completed)
      ..writeByte(6)
      ..write(obj.taskId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimerSessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
