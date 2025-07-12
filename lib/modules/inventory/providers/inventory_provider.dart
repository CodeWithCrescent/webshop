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

  // Pagination
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMore = true;

  // Debouncer
  Timer? _debounceTimer;
  final Debouncer _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));

  InventoryProvider({required this.localDataSource});

  List<Product> get products => _filteredProducts;
  List<Category> get categories => _categories;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  ProductSortOption get sortOption => _sortOption;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchDebouncer.dispose();
    super.dispose();
  }

  Future<void> init() async {
    _currentPage = 1;
    _hasMore = true;
    await loadProducts();
    await loadCategories();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await localDataSource.getProducts();
      _applyFilters(resetPage: true);
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

  void _applyFilters({bool resetPage = false}) {
    if (resetPage) {
      _currentPage = 1;
      _hasMore = true;
    }

    List<Product> filtered = _products.where((product) {
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.code.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategory == null || product.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    _sortProducts(filtered);

    final int startIndex = (_currentPage - 1) * _pageSize;
    final int endIndex = startIndex + _pageSize;

    if (startIndex >= filtered.length) {
      _hasMore = false;
      return;
    }

    _filteredProducts = filtered.sublist(
      startIndex,
      endIndex > filtered.length ? filtered.length : endIndex,
    );

    _hasMore = endIndex < filtered.length;
    notifyListeners();
  }

  void loadNextPage() {
    if (_isLoading || !_hasMore) return;

    _currentPage++;
    _applyFilters();
  }

  void _sortProducts(List<Product> list) {
    switch (_sortOption) {
      case ProductSortOption.nameAsc:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case ProductSortOption.nameDesc:
        list.sort((a, b) => b.name.compareTo(a.name));
        break;
      case ProductSortOption.priceAsc:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOption.priceDesc:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSortOption.stockAsc:
        list.sort((a, b) => a.stock.compareTo(b.stock));
        break;
      case ProductSortOption.stockDesc:
        list.sort((a, b) => b.stock.compareTo(a.stock));
        break;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _searchDebouncer.run(() => _applyFilters(resetPage: true));
  }

  void setCategoryFilter(String? category) {
    _selectedCategory = category;
    _applyFilters(resetPage: true);
  }

  void setSortOption(ProductSortOption option) {
    _sortOption = option;
    _applyFilters(resetPage: true);
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
      final oldCategory = _categories.firstWhere((c) => c.id == category.id);

      if (oldCategory.name != category.name) {
        await localDataSource.updateCategoryName(oldCategory.name, category.name);
      }

      await localDataSource.updateCategory(category);
      await loadCategories();
      await loadProducts();

      if (_selectedCategory == oldCategory.name) {
        _selectedCategory = category.name;
      }

      _applyFilters(resetPage: true);
    } catch (e) {
      debugPrint('Error updating category: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      final categoryToDelete = _categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => Category(name: ''),
      );
      final categoryName = categoryToDelete.name;

      await localDataSource.deleteProductsByCategory(categoryName);
      await localDataSource.deleteCategory(categoryId);

      await loadCategories();
      await loadProducts();

      if (_selectedCategory == categoryName) {
        _selectedCategory = null;
      }

      _applyFilters(resetPage: true);
    } catch (e) {
      debugPrint('Error deleting category and its products: $e');
      rethrow;
    }
  }
}
