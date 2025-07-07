import 'package:webshop/modules/inventory/models/product.dart';

class ProductSelection {
  final Product product;
  final int quantity;

  ProductSelection({
    required this.product,
    this.quantity = 1,
  });
}