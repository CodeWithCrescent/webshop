import 'package:intl/intl.dart';
import 'package:webshop/core/utils/helpers.dart';

class ReceiptData {
  final Object? invoiceNumber;
  final Object? receiptNumber;
  final Object? receiptDate;
  final Object? receiptTime;
  final Object? verificationCode;
  final Object? zNumber;
  final Object? verificationLink;
  final Object? isDemo;
  final Object? vrn;
  final Object? totalExclOfTax;
  final Object? totalTax;
  final Object? totalInclOfTax;
  final Object? ackCode;
  final Object? ackMsg;
  final Object? discount;
  final Object? customerIdType;
  final Object? customerIdNumber;
  final Object? customerName;
  final Object? customerMobile;
  final Object? customerVrn;
  final List<ReceiptDataItem> items;

  ReceiptData({
    this.invoiceNumber,
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
    required this.ackCode,
    required this.ackMsg,
    required this.discount,
    this.customerIdType,
    this.customerIdNumber,
    this.customerName,
    this.customerMobile,
    this.customerVrn,
    required this.items,
  });

  /// Parse [receiptDate] as readable format or fallback
  String get formattedDate {
    try {
      final dateStr = parseString(receiptDate);
      final date = DateTime.parse(dateStr);
      return DateFormat('d MMMM y').format(date);
    } catch (_) {
      return '';
    }
  }

  factory ReceiptData.fromMap(Map<String, dynamic> map) {
    return ReceiptData(
      invoiceNumber: map['invoice_number'],
      receiptNumber: map['receipt_number'],
      receiptDate: map['receipt_date'],
      receiptTime: map['receipt_time'],
      verificationCode: map['verificationcode'],
      zNumber: map['znum'],
      verificationLink: map['verif_link'],
      isDemo: map['isdemo'] ?? 'no',
      vrn: map['vrn'],
      totalExclOfTax: map['total_excl_of_tax'],
      totalTax: map['total_tax'],
      totalInclOfTax: map['total_incl_of_tax'],
      ackCode: map['tra_ackcode'],
      ackMsg: map['tra_ackmsg'],
      discount: map['discount'],
      customerIdType: map['customer_id_type'],
      customerIdNumber: map['customer_id_number'],
      customerName: map['customer_name'],
      customerMobile: map['customer_mobile'],
      customerVrn: map['customer_vrn'],
      items: List<ReceiptDataItem>.from(
        (map['items'] ?? []).map((x) => ReceiptDataItem.fromMap(x)),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'invoice_number': invoiceNumber,
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
      'tra_ackcode': ackCode,
      'tra_ackmsg': ackMsg,
      'discount': discount,
      'customer_id_type': customerIdType,
      'customer_id_number': customerIdNumber,
      'customer_name': customerName,
      'customer_mobile': customerMobile,
      'customer_vrn': customerVrn,
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
