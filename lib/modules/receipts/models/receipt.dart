import 'dart:convert';

class Receipt {
  final String receiptNumber;
  final String receiptDate;
  final String receiptTime;
  final String subtotal;
  final String discount;
  final String total;
  final String verifyLink;
  final String ackCode;
  final String ackMsg;
  final String rctvNum;
  final String customerId;
  final String customerName; // <- Only the name now
  final String createdBy;

  Receipt({
    required this.receiptNumber,
    required this.receiptDate,
    required this.receiptTime,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.verifyLink,
    required this.ackCode,
    required this.ackMsg,
    required this.rctvNum,
    required this.customerId,
    required this.customerName,
    required this.createdBy,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    dynamic payload = json['jsonPayload'];
    String name = '';

    try {
      if (payload is String) {
        final parsed = jsonDecode(payload);
        name = parsed['customer']?['name']?.toString() ?? '';
      } else if (payload is Map<String, dynamic>) {
        name = payload['customer']?['name']?.toString() ?? '';
      }
    } catch (_) {
      name = '';
    }

    return Receipt(
      receiptNumber: json['receipt_number'],
      receiptDate: json['receipt_date'],
      receiptTime: json['receipt_time'],
      subtotal: json['subtotal'],
      discount: json['discount'],
      total: json['total'],
      verifyLink: json['verify_link'],
      ackCode: json['ACKCODE'],
      ackMsg: json['ACKMSG'],
      rctvNum: json['RCTVNUM'],
      customerId: json['customerId'],
      customerName: name,
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() => {
        'receipt_number': receiptNumber,
        'receipt_date': receiptDate,
        'receipt_time': receiptTime,
        'subtotal': subtotal,
        'discount': discount,
        'total': total,
        'verify_link': verifyLink,
        'ACKCODE': ackCode,
        'ACKMSG': ackMsg,
        'RCTVNUM': rctvNum,
        'customerId': customerId,
        'customerName': customerName,
        'created_by': createdBy,
      };
}