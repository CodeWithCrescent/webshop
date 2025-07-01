// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zreport.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ZReportAdapter extends TypeAdapter<ZReport> {
  @override
  final int typeId = 7;

  @override
  ZReport read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ZReport(
      reportNumber: fields[0] as String,
      reportDate: fields[1] as DateTime,
      reportTime: fields[2] as String,
      subtotal: fields[3] as double,
      discount: fields[4] as double,
      total: fields[5] as double,
      vat: fields[6] as double,
      totalGross: fields[7] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ZReport obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.reportNumber)
      ..writeByte(1)
      ..write(obj.reportDate)
      ..writeByte(2)
      ..write(obj.reportTime)
      ..writeByte(3)
      ..write(obj.subtotal)
      ..writeByte(4)
      ..write(obj.discount)
      ..writeByte(5)
      ..write(obj.total)
      ..writeByte(6)
      ..write(obj.vat)
      ..writeByte(7)
      ..write(obj.totalGross);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZReportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
