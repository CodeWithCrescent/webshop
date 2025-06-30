// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompanyProfileAdapter extends TypeAdapter<CompanyProfile> {
  @override
  final int typeId = 6;

  @override
  CompanyProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompanyProfile(
      name: fields[0] as String,
      allowedInstances: fields[1] as String,
      installedInstances: fields[2] as String,
      mobile: fields[3] as String,
      address1: fields[4] as String,
      address2: fields[5] as String,
      address3: fields[6] as String,
      vin: fields[7] as String,
      tin: fields[8] as String,
      vrn: fields[9] as String,
      serial: fields[10] as String,
      taxoffice: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CompanyProfile obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.allowedInstances)
      ..writeByte(2)
      ..write(obj.installedInstances)
      ..writeByte(3)
      ..write(obj.mobile)
      ..writeByte(4)
      ..write(obj.address1)
      ..writeByte(5)
      ..write(obj.address2)
      ..writeByte(6)
      ..write(obj.address3)
      ..writeByte(7)
      ..write(obj.vin)
      ..writeByte(8)
      ..write(obj.tin)
      ..writeByte(9)
      ..write(obj.vrn)
      ..writeByte(10)
      ..write(obj.serial)
      ..writeByte(11)
      ..write(obj.taxoffice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
