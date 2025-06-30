import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'customer.g.dart';

@HiveType(typeId: 3)
class Customer {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String fullName;
  @HiveField(2)
  final String phoneNumber;
  @HiveField(3)
  final String? email;
  @HiveField(4)
  final String? tinNumber;
  @HiveField(5)
  final String? vrn;
  @HiveField(6)
  final DateTime createdAt;
  @HiveField(7)
  final DateTime? updatedAt;

  Customer({
    String? id,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    this.tinNumber,
    this.vrn,
    DateTime? createdAt,
    this.updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Customer copyWith({
    String? fullName,
    String? phoneNumber,
    String? email,
    String? tinNumber,
    String? vrn,
  }) {
    return Customer(
      id: id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      tinNumber: tinNumber ?? this.tinNumber,
      vrn: vrn ?? this.vrn,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'tinNumber': tinNumber,
      'vrn': vrn,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      fullName: map['fullName'],
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      tinNumber: map['tinNumber'],
      vrn: map['vrn'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
    );
  }
}