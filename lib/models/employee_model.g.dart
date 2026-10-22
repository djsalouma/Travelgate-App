// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmployeeAdapter extends TypeAdapter<Employee> {
  @override
  final int typeId = 0;

  @override
  Employee read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Employee(
      id: fields[0] as String,
      employeeId: fields[1] as String,
      firstName: fields[2] as String,
      lastName: fields[3] as String,
      email: fields[4] as String,
      phone: fields[5] as String,
      role: fields[6] as String,
      department: fields[7] as String,
      position: fields[8] as String,
      hireDate: fields[9] as DateTime,
      companyId: fields[10] as String,
      assignedLocationId: fields[11] as String,
      checkInTime: fields[12] as TimeOfDay,
      checkOutTime: fields[13] as TimeOfDay,
      isActive: fields[14] as bool? ?? true,
      profileImage: fields[15] as String?,
      createdAt: fields[16] as DateTime?,
      updatedAt: fields[17] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Employee obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.employeeId)
      ..writeByte(2)
      ..write(obj.firstName)
      ..writeByte(3)
      ..write(obj.lastName)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.phone)
      ..writeByte(6)
      ..write(obj.role)
      ..writeByte(7)
      ..write(obj.department)
      ..writeByte(8)
      ..write(obj.position)
      ..writeByte(9)
      ..write(obj.hireDate)
      ..writeByte(10)
      ..write(obj.companyId)
      ..writeByte(11)
      ..write(obj.assignedLocationId)
      ..writeByte(12)
      ..write(obj.checkInTime)
      ..writeByte(13)
      ..write(obj.checkOutTime)
      ..writeByte(14)
      ..write(obj.isActive)
      ..writeByte(15)
      ..write(obj.profileImage)
      ..writeByte(16)
      ..write(obj.createdAt)
      ..writeByte(17)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
