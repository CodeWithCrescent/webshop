import 'package:intl/intl.dart';

class Receipt {
  final String receiptNumber;
  final String receiptDate;
  final String receiptTime;
  final String verificationCode;
  final String zNumber;
  final String verificationLink;
  final String isDemo;
  final String vrn;
  final num totalExclOfTax;
  final num totalTax;
  final num totalInclOfTax;
  final num discount;
  final String customerIdType;
  final String customerIdNumber;
  final String customerName;
  final String customerMobile;
  final List<ReceiptItem> items;

  Receipt({
    required this.receiptNumber,
    required this.receiptDate,
    required this.receiptTime,
    required this.verificationCode,
    required this.zNumber,
    required this.verificationLink,
    required this.isDemo,
    required this.vrn,
    required this.totalExclOfTax,
    required this.totalTax,
    required this.totalInclOfTax,
    required this.discount,
    required this.customerIdType,
    required this.customerIdNumber,
    required this.customerName,
    required this.customerMobile,
    required this.items,
  });

  String get formattedDate {
    final date = DateTime.parse(receiptDate);
    return DateFormat('d MMMM y').format(date);
  }

  factory Receipt.fromMap(Map<String, dynamic> map) {
    return Receipt(
      receiptNumber: map['receipt_number'] ?? '',
      receiptDate: map['receipt_date'] ?? '',
      receiptTime: map['receipt_time'] ?? '',
      verificationCode: map['verificationcode'] ?? '',
      zNumber: map['znum'] ?? '',
      verificationLink: map['verif_link'] ?? '',
      isDemo: map['isdemo'] ?? 'no',
      vrn: map['vrn'] ?? '',
      totalExclOfTax: num.tryParse(map['total_excl_of_tax']?.toString() ?? '0') ?? 0,
      totalTax: num.tryParse(map['total_tax']?.toString() ?? '0') ?? 0,
      totalInclOfTax: num.tryParse(map['total_incl_of_tax']?.toString() ?? '0') ?? 0,
      discount: num.tryParse(map['discount']?.toString() ?? '0') ?? 0,
      customerIdType: map['customer_id_type'] ?? '',
      customerIdNumber: map['customer_id_number'] ?? '',
      customerName: map['customer_name'] ?? '',
      customerMobile: map['customer_mobile'] ?? '',
      items: List<ReceiptItem>.from(
        (map['items'] ?? []).map((x) => ReceiptItem.fromMap(x))),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'receipt_number': receiptNumber,
      'receipt_date': receiptDate,
      'receipt_time': receiptTime,
      'verificationcode': verificationCode,
      'znum': zNumber,
      'verif_link': verificationLink,
      'isdemo': isDemo,
      'vrn': vrn,
      'total_excl_of_tax': totalExclOfTax,
      'total_tax': totalTax,
      'total_incl_of_tax': totalInclOfTax,
      'discount': discount,
      'customer_id_type': customerIdType,
      'customer_id_number': customerIdNumber,
      'customer_name': customerName,
      'customer_mobile': customerMobile,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }
}

class ReceiptItem {
  final String itemCode;
  final String itemDescription;
  final num itemQuantity;
  final num amount;

  ReceiptItem({
    required this.itemCode,
    required this.itemDescription,
    required this.itemQuantity,
    required this.amount,
  });

  factory ReceiptItem.fromMap(Map<String, dynamic> map) {
    return ReceiptItem(
      itemCode: map['itemcode'] ?? '',
      itemDescription: map['itemdesc'] ?? '',
      itemQuantity: num.tryParse(map['itemqty']?.toString() ?? '0') ?? 0,
      amount: num.tryParse(map['amount']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemcode': itemCode,
      'itemdesc': itemDescription,
      'itemqty': itemQuantity,
      'amount': amount,
    };
  }
}