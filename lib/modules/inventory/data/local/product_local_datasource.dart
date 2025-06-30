import 'package:hive/hive.dart';
import '../../models/product.dart';
import '../../models/category.dart';

class ProductLocalDataSource {
  final Box<Product> productBox;
  final Box<Category> categoryBox;

  ProductLocalDataSource({
    required this.productBox,
    required this.categoryBox,
  });

  Future<List<Product>> getProducts() async {
    return productBox.values.toList();
  }

  Future<List<Category>> getCategories() async {
    return categoryBox.values.toList();
  }

  Future<void> addProduct(Product product) async {
    await productBox.put(product.id, product);
  }

  Future<void> updateProduct(Product product) async {
    await productBox.put(product.id, product);
  }

  Future<void> deleteProduct(String productId) async {
    await productBox.delete(productId);
  }

  Future<void> addCategory(Category category) async {
    await categoryBox.put(category.id, category);
  }

  Future<void> updateCategory(Category category) async {
    await categoryBox.put(category.id, category);
  }

  Future<void> deleteCategory(String categoryId) async {
    await categoryBox.delete(categoryId);
  }
}