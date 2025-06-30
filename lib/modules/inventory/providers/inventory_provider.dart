import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webshop/core/utils/debouncer.dart';
import 'package:webshop/modules/inventory/data/local/product_local_datasource.dart';
import 'package:webshop/modules/inventory/models/category.dart';
import 'package:webshop/modules/inventory/models/product.dart';

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
  String? _error;

  Timer? _debounceTimer;
  final Debouncer _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));

  List<Product> get products => _filteredProducts;
  List<Category> get categories => _categories;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  ProductSortOption get sortOption => _sortOption;
  bool get isLoading => _isLoading;
  String? get error => _error;

  InventoryProvider({required this.localDataSource});

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchDebouncer.dispose();
    super.dispose();
  }

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
      _error = null;
    } catch (e) {
      _error = e.toString();
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
      _error = e.toString();
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

  Future<void> updateCategory(Category category) async {
    try {
      await localDataSource.updateCategory(category);
      await loadCategories();
    } catch (e) {
      debugPrint('Error updating category: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await localDataSource.deleteCategory(categoryId);
      await loadCategories();
      if (_selectedCategory != null) {
        final category = _categories.firstWhere(
          (c) => c.id == categoryId,
          orElse: () => Category(name: ''),
        );
        if (category.name == _selectedCategory) {
          _selectedCategory = null;
        }
      }
      _applyFilters();
    } catch (e) {
      debugPrint('Error deleting category: $e');
      rethrow;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _searchDebouncer.run(_applyFilters);
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
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
          product.code.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == null || 
                            product.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    _sortProducts();
    notifyListeners();
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