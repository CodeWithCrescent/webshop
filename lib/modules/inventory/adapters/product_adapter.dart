import '../models/product.dart';

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 0;

  @override
  Product read(BinaryReader reader) {
    // Implement read from binary
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    // Implement write to binary
  }
}