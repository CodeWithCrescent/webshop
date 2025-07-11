class Sale {
  final String? id;
  final String? customerId;
  final String? invoiceId;
  final DateTime date;
  final double totalAmount;
  final double totalTax;
  final double totalNet;
  final String paymentType;
  final double? latitude;
  final double? longitude;
  final bool isVatRegistered;

  Sale({
    this.id,
    this.customerId,
    this.invoiceId,
    required this.date,
    required this.totalAmount,
    required this.totalTax,
    required this.totalNet,
    required this.paymentType,
    this.latitude,
    this.longitude,
    required this.isVatRegistered,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'invoiceId': invoiceId,
      'date': date.toIso8601String(),
      'totalAmount': totalAmount,
      'totalTax': totalTax,
      'totalNet': totalNet,
      'paymentType': paymentType,
      'latitude': latitude,
      'longitude': longitude,
      'isVatRegistered': isVatRegistered,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      customerId: map['customerId'],
      invoiceId: map['invoiceId'],
      date: DateTime.parse(map['date']),
      totalAmount: map['totalAmount'],
      totalTax: map['totalTax'],
      totalNet: map['totalNet'],
      paymentType: map['paymentType'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      isVatRegistered: map['isVatRegistered'] ?? false,
    );
  }
}