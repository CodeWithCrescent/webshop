import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../models/product.dart';
import '../../models/category.dart';
import '../../data/local/product_local_datasource.dart';

enum ProductSortOption {
  nameAsc,
  nameDesc,
  priceAsc,
  priceDesc,
  stockAsc,
  stockDesc,
}

class InventoryProvider with ChangeNotifier {
  final ProductLocalDataSource localDataSource;
  
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<Category> _categories = [];
  String _searchQuery = '';
  String? _selectedCategory;
  ProductSortOption _sortOption = ProductSortOption.nameAsc;
  bool _isLoading = false;

  List<Product> get products => _filteredProducts;
  List<Category> get categories => _categories;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  ProductSortOption get sortOption => _sortOption;
  bool get isLoading => _isLoading;

  InventoryProvider({required this.localDataSource});

  Future<void> init() async {
    await loadProducts();
    await loadCategories();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _products = await localDataSource.getProducts();
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      _categories = await localDataSource.getCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> addProduct(Product product) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await localDataSource.addProduct(product);
      await loadProducts();
    } catch (e) {
      debugPrint('Error adding product: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(Product product) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await localDataSource.updateProduct(product);
      await loadProducts();
    } catch (e) {
      debugPrint('Error updating product: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await localDataSource.deleteProduct(productId);
      await loadProducts();
    } catch (e) {
      debugPrint('Error deleting product: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      await localDataSource.addCategory(category);
      await loadCategories();
    } catch (e) {
      debugPrint('Error adding category: $e');
      rethrow;
    }
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
      case ProductSortOption.priceAsc:
        _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOption.priceDesc:
        _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSortOption.stockAsc:
        _filteredProducts.sort((a, b) => a.stock.compareTo(b.stock));
        break;
      case ProductSortOption.stockDesc:
        _filteredProducts.sort((a, b) => b.stock.compareTo(a.stock));
        break;
    }
  }
}