import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'receipt.g.dart';

@HiveType(typeId: 4)
class ReceiptItem {
  @HiveField(0)
  final String itemcode;
  @HiveField(1)
  final String itemdesc;
  @HiveField(2)
  final int itemqty;
  @HiveField(3)
  final double amount;

  ReceiptItem({
    required this.itemcode,
    required this.itemdesc,
    required this.itemqty,
    required this.amount,
  });

  factory ReceiptItem.fromMap(Map<String, dynamic> map) {
    return ReceiptItem(
      itemcode: map['itemcode'],
      itemdesc: map['itemdesc'],
      itemqty: int.parse(map['itemqty'].toString()),
      amount: double.parse(map['amount'].toString()),
    );
  }
}

@HiveType(typeId: 5)
class Receipt {
  @HiveField(0)
  final String receipt_number;
  @HiveField(1)
  final String verificationcode;
  @HiveField(2)
  final String receipt_time;
  @HiveField(3)
  final DateTime receipt_date;
  @HiveField(4)
  final String znum;
  @HiveField(5)
  final String verif_link;
  @HiveField(6)
  final String isdemo;
  @HiveField(7)
  final String vrn;
  @HiveField(8)
  final double total_excl_of_tax;
  @HiveField(9)
  final double total_tax;
  @HiveField(10)
  final double total_incl_of_tax;
  @HiveField(11)
  final double discount;
  @HiveField(12)
  final String customer_id_type;
  @HiveField(13)
  final String customer_id_number;
  @HiveField(14)
  final String customer_name;
  @HiveField(15)
  final String customer_mobile;
  @HiveField(16)
  final List<ReceiptItem> items;

  Receipt({
    required this.receipt_number,
    required this.verificationcode,
    required this.receipt_time,
    required this.receipt_date,
    required this.znum,
    required this.verif_link,
    required this.isdemo,
    required this.vrn,
    required this.total_excl_of_tax,
    required this.total_tax,
    required this.total_incl_of_tax,
    required this.discount,
    required this.customer_id_type,
    required this.customer_id_number,
    required this.customer_name,
    required this.customer_mobile,
    required this.items,
  });

  String get formattedDate => DateFormat('dd MMM yyyy').format(receipt_date);

  String get formattedTime => receipt_time;

  factory Receipt.fromMap(Map<String, dynamic> map) {
    return Receipt(
      receipt_number: map['receipt_number'],
      verificationcode: map['verificationcode'],
      receipt_time: map['receipt_time'],
      receipt_date: DateTime.parse(map['receipt_date']),
      znum: map['znum'],
      verif_link: map['verif_link'],
      isdemo: map['isdemo'],
      vrn: map['vrn'],
      total_excl_of_tax: double.parse(map['total_excl_of_tax'].toString()),
      total_tax: double.parse(map['total_tax'].toString()),
      total_incl_of_tax: double.parse(map['total_incl_of_tax'].toString()),
      discount: double.parse(map['discount'].toString()),
      customer_id_type: map['customer_id_type'],
      customer_id_number: map['customer_id_number'],
      customer_name: map['customer_name'],
      customer_mobile: map['customer_mobile'],
      items: List<ReceiptItem>.from(
          map['items'].map((x) => ReceiptItem.fromMap(x))),
    );
  }
}