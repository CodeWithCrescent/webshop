// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReceiptItemAdapter extends TypeAdapter<ReceiptItem> {
  @override
  final int typeId = 4;

  @override
  ReceiptItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReceiptItem(
      itemcode: fields[0] as String,
      itemdesc: fields[1] as String,
      itemqty: fields[2] as int,
      amount: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ReceiptItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.itemcode)
      ..writeByte(1)
      ..write(obj.itemdesc)
      ..writeByte(2)
      ..write(obj.itemqty)
      ..writeByte(3)
      ..write(obj.amount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceiptItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReceiptAdapter extends TypeAdapter<Receipt> {
  @override
  final int typeId = 5;

  @override
  Receipt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Receipt(
      receipt_number: fields[0] as String,
      verificationcode: fields[1] as String,
      receipt_time: fields[2] as String,
      receipt_date: fields[3] as DateTime,
      znum: fields[4] as String,
      verif_link: fields[5] as String,
      isdemo: fields[6] as String,
      vrn: fields[7] as String,
      total_excl_of_tax: fields[8] as double,
      total_tax: fields[9] as double,
      total_incl_of_tax: fields[10] as double,
      discount: fields[11] as double,
      customer_id_type: fields[12] as String,
      customer_id_number: fields[13] as String,
      customer_name: fields[14] as String,
      customer_mobile: fields[15] as String,
      items: (fields[16] as List).cast<ReceiptItem>(),
    );
  }

  @override
  void write(BinaryWriter writer, Receipt obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.receipt_number)
      ..writeByte(1)
      ..write(obj.verificationcode)
      ..writeByte(2)
      ..write(obj.receipt_time)
      ..writeByte(3)
      ..write(obj.receipt_date)
      ..writeByte(4)
      ..write(obj.znum)
      ..writeByte(5)
      ..write(obj.verif_link)
      ..writeByte(6)
      ..write(obj.isdemo)
      ..writeByte(7)
      ..write(obj.vrn)
      ..writeByte(8)
      ..write(obj.total_excl_of_tax)
      ..writeByte(9)
      ..write(obj.total_tax)
      ..writeByte(10)
      ..write(obj.total_incl_of_tax)
      ..writeByte(11)
      ..write(obj.discount)
      ..writeByte(12)
      ..write(obj.customer_id_type)
      ..writeByte(13)
      ..write(obj.customer_id_number)
      ..writeByte(14)
      ..write(obj.customer_name)
      ..writeByte(15)
      ..write(obj.customer_mobile)
      ..writeByte(16)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceiptAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
