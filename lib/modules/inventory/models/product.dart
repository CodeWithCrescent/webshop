import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String code;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String category;
  @HiveField(4)
  final double price;
  @HiveField(5)
  final int taxCategory;
  @HiveField(6)
  final int stock;
  @HiveField(7)
  final DateTime createdAt;
  @HiveField(8)
  final DateTime? updatedAt;

  Product({
    String? id,
    required this.code,
    required this.name,
    required this.category,
    required this.price,
    required this.taxCategory,
    required this.stock,
    DateTime? createdAt,
    this.updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Product copyWith({
    String? code,
    String? name,
    String? category,
    double? price,
    int? taxCategory,
    int? stock,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id,
      code: code ?? this.code,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      taxCategory: taxCategory ?? this.taxCategory,
      stock: stock ?? this.stock,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'category': category,
      'price': price,
      'taxCategory': taxCategory,
      'stock': stock,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      code: map['code'],
      name: map['name'],
      category: map['category'],
      price: map['price'],
      taxCategory: map['taxCategory'],
      stock: map['stock'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
    );
  }
}