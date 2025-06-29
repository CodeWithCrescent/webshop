import '../models/product.dart';

class InventoryProvider with ChangeNotifier {
  final ProductLocalDataSource localDataSource;
  
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<Category> _categories = [];
  String _searchQuery = '';
  String? _selectedCategory;
  ProductSortOption _sortOption = ProductSortOption.nameAsc;

  // Getters...

  InventoryProvider({required this.localDataSource});

  Future<void> loadProducts() async {
    _products = await localDataSource.getProducts();
    _categories = await localDataSource.getCategories();
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setCategoryFilter(String? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void setSortOption(ProductSortOption option) {
    _sortOption = option;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredProducts = _products.where((product) {
      final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                          product.code.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == null || 
                            product.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    _sortProducts();
  }

  void _sortProducts() {
    switch (_sortOption) {
      case ProductSortOption.nameAsc:
        _filteredProducts.sort((a, b) => a.name.compareTo(b.name));
        break;
      case ProductSortOption.nameDesc:
        _filteredProducts.sort((a, b) => b.name.compareTo(a.name));
        break;
      // Add other sort cases
    }
  }
}