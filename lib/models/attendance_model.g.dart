// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AttendanceRecordAdapter extends TypeAdapter<AttendanceRecord> {
  @override
  final int typeId = 1;

  @override
  AttendanceRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AttendanceRecord(
      id: fields[0] as String,
      employeeId: fields[1] as String,
      date: fields[2] as DateTime,
      clockInTime: fields[3] as DateTime?,
      clockOutTime: fields[4] as DateTime?,
      status: fields[5] as String,
      clockInLatitude: fields[6] as double?,
      clockInLongitude: fields[7] as double?,
      clockOutLatitude: fields[8] as double?,
      clockOutLongitude: fields[9] as double?,
      isWithinRadius: fields[10] as bool? ?? false,
      lateMinutes: fields[11] as int? ?? 0,
      earlyDepartureMinutes: fields[12] as int? ?? 0,
      notes: fields[13] as String?,
      createdAt: fields[14] as DateTime?,
      updatedAt: fields[15] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AttendanceRecord obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.employeeId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.clockInTime)
      ..writeByte(4)
      ..write(obj.clockOutTime)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.clockInLatitude)
      ..writeByte(7)
      ..write(obj.clockInLongitude)
      ..writeByte(8)
      ..write(obj.clockOutLatitude)
      ..writeByte(9)
      ..write(obj.clockOutLongitude)
      ..writeByte(10)
      ..write(obj.isWithinRadius)
      ..writeByte(11)
      ..write(obj.lateMinutes)
      ..writeByte(12)
      ..write(obj.earlyDepartureMinutes)
      ..writeByte(13)
      ..write(obj.notes)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
