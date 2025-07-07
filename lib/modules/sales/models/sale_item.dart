class SaleItem {
  final String? id;
  final String saleId;
  final String productId;
  final String productCode;
  final String productName;
  final int quantity;
  final double price;
  final int taxCategory; // Store tax category instead of rate
  final double totalAmount;

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
  });

  // Proper copyWith implementation
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
    );
  }

  // Helper method to calculate tax amount based on category
  double get taxAmount {
    return calculateTax(price * quantity, taxCategory);
  }

  // Helper method to calculate net amount
  double get netAmount {
    return price * quantity;
  }

  // Static tax calculation method
  static double calculateTax(double amount, int taxCategory) {
    switch (taxCategory) {
      case 1: return amount * 0.18; // Standard 18%
      case 2: return 0.0;           // Special rate
      case 3: return 0.0;           // Zero Rated
      case 4: return 0.0;           // Special Relief
      case 5: return 0.0;           // Exempted
      default: return 0.0;
    }
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
    );
  }
}