class SaleItem {
  final String? id;
  final String saleId;
  final String productId;
  final String productCode;
  final String productName;
  final int quantity;
  final double price;
  final int taxCategory;
  final double totalAmount;
  final bool isVatRegistered;

  SaleItem({
    this.id,
    required this.saleId,
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.taxCategory,
    required this.totalAmount,
    required this.isVatRegistered,
  });

  SaleItem copyWith({
    String? id,
    String? saleId,
    String? productId,
    String? productCode,
    String? productName,
    int? quantity,
    double? price,
    int? taxCategory,
    double? totalAmount,
    bool? isVatRegistered,
  }) {
    return SaleItem(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      productCode: productCode ?? this.productCode,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      taxCategory: taxCategory ?? this.taxCategory,
      totalAmount: totalAmount ?? this.totalAmount,
      isVatRegistered: isVatRegistered ?? this.isVatRegistered,
    );
  }

  // Tax calculation based on VAT registration and tax category
  double get taxAmount {
    if (!isVatRegistered || taxCategory != 1) {
      return 0.0;
    }
    // Calculate tax as: totalAmount * (taxRate / (1 + taxRate))
    return totalAmount * (0.18 / 1.18);
  }

  double get netAmount {
    return totalAmount - taxAmount;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'saleId': saleId,
      'productId': productId,
      'productCode': productCode,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'taxCategory': taxCategory,
      'totalAmount': totalAmount,
      'isVatRegistered': isVatRegistered,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'],
      saleId: map['saleId'],
      productId: map['productId'],
      productCode: map['productCode'],
      productName: map['productName'],
      quantity: map['quantity'],
      price: map['price'],
      taxCategory: map['taxCategory'],
      totalAmount: map['totalAmount'],
      isVatRegistered: map['isVatRegistered'] ?? false,
    );
  }
}
