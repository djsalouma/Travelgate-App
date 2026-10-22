// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompanyLocationAdapter extends TypeAdapter<CompanyLocation> {
  @override
  final int typeId = 2;

  @override
  CompanyLocation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompanyLocation(
      id: fields[0] as String,
      name: fields[1] as String,
      address: fields[2] as String,
      latitude: fields[3] as double,
      longitude: fields[4] as double,
      radius: fields[5] as double? ?? 1000.0,
      companyId: fields[6] as String,
      isActive: fields[7] as bool? ?? true,
      createdAt: fields[8] as DateTime?,
      updatedAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CompanyLocation obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.radius)
      ..writeByte(6)
      ..write(obj.companyId)
      ..writeByte(7)
      ..write(obj.isActive)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyLocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocationLogAdapter extends TypeAdapter<LocationLog> {
  @override
  final int typeId = 3;

  @override
  LocationLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationLog(
      id: fields[0] as String,
      employeeId: fields[1] as String,
      timestamp: fields[2] as DateTime,
      latitude: fields[3] as double,
      longitude: fields[4] as double,
      accuracy: fields[5] as double,
      action: fields[6] as String,
      isWithinRadius: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LocationLog obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.employeeId)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.accuracy)
      ..writeByte(6)
      ..write(obj.action)
      ..writeByte(7)
      ..write(obj.isWithinRadius);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
