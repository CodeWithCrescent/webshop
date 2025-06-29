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

  Future<void> addProduct(Product product) async {
    await productBox.put(product.id, product);
  }

  // TODO: Add other CRUD operations
}