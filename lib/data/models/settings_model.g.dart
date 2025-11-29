// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 2;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      focusDuration: fields[0] as int,
      shortBreakDuration: fields[1] as int,
      longBreakDuration: fields[2] as int,
      cyclesBeforeLongBreak: fields[3] as int,
      soundEnabled: fields[4] as bool,
      notificationsEnabled: fields[5] as bool,
      autoSwitch: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.focusDuration)
      ..writeByte(1)
      ..write(obj.shortBreakDuration)
      ..writeByte(2)
      ..write(obj.longBreakDuration)
      ..writeByte(3)
      ..write(obj.cyclesBeforeLongBreak)
      ..writeByte(4)
      ..write(obj.soundEnabled)
      ..writeByte(5)
      ..write(obj.notificationsEnabled)
      ..writeByte(6)
      ..write(obj.autoSwitch);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
