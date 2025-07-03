import 'package:intl/intl.dart';

class ReceiptData {
  final String receiptNumber;
  final String receiptDate;
  final String receiptTime;
  final String verificationCode;
  final String zNumber;
  final String verificationLink;
  final String isDemo;
  final String vrn;
  final String totalExclOfTax;
  final String totalTax;
  final String totalInclOfTax;
  final String discount;
  final String customerIdType;
  final String customerIdNumber;
  final String customerName;
  final String customerMobile;
  final List<ReceiptDataItem> items;

  ReceiptData({
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

  factory ReceiptData.fromMap(Map<String, dynamic> map) {
    return ReceiptData(
      receiptNumber: map['receipt_number'] ?? '',
      receiptDate: map['receipt_date'] ?? '',
      receiptTime: map['receipt_time'] ?? '',
      verificationCode: map['verificationcode'] ?? '',
      zNumber: map['znum'] ?? '',
      verificationLink: map['verif_link'] ?? '',
      isDemo: map['isdemo'] ?? 'no',
      vrn: map['vrn'] ?? '',
      totalExclOfTax: map['total_excl_of_tax'] ?? '0',
      totalTax: map['total_tax'] ?? '0',
      totalInclOfTax: map['total_incl_of_tax'] ?? '0',
      discount: map['discount'] ?? '0',
      customerIdType: map['customer_id_type'] ?? '',
      customerIdNumber: map['customer_id_number'] ?? '',
      customerName: map['customer_name'] ?? '',
      customerMobile: map['customer_mobile'] ?? '',
      items: List<ReceiptDataItem>.from(
          (map['items'] ?? []).map((x) => ReceiptDataItem.fromMap(x))),
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

class ReceiptDataItem {
  final String itemCode;
  final String itemDescription;
  final String itemQuantity;
  final String amount;

  ReceiptDataItem({
    required this.itemCode,
    required this.itemDescription,
    required this.itemQuantity,
    required this.amount,
  });

  factory ReceiptDataItem.fromMap(Map<String, dynamic> map) {
    return ReceiptDataItem(
      itemCode: map['itemcode'] ?? '',
      itemDescription: map['itemdesc'] ?? '',
      itemQuantity: map['itemqty'] ?? '0',
      amount: map['amount'] ?? '0',
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
