class Product {
  final String id;
  final String code;
  final String name;
  final String category;
  final double price;
  final int taxCategory;
  final int stock;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.code,
    required this.name,
    required this.category,
    required this.price,
    required this.taxCategory,
    required this.stock,
    required this.createdAt,
    this.updatedAt,
  });

  // TODO: Add fromMap, toMap, copyWith methods
}