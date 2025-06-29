import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/http_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/error/failures.dart';

class InventoryProvider with ChangeNotifier {
  final SharedPreferences prefs;
  final HttpClient httpClient;

  bool _isLoading = false;
  String? _error;
  List<dynamic> _products = [];
  List<dynamic> _filteredProducts = [];
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic> get products => _filteredProducts;
  String get searchQuery => _searchQuery;

  InventoryProvider({required this.prefs}) : httpClient = HttpClient(prefs: prefs);

  Future<void> loadProducts() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await httpClient.get(ApiEndpoints.products);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _products = data['data'];
        _filterProducts();
        _error = null;
      } else {
        throw ServerFailure(data['message'] ?? 'Failed to load products');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _filterProducts();
    notifyListeners();
  }

  void _filterProducts() {
    if (_searchQuery.isEmpty) {
      _filteredProducts = List.from(_products);
    } else {
      _filteredProducts = _products.where((product) {
        return product['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
               product['code'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await httpClient.post(ApiEndpoints.products, productData);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        await loadProducts(); // Refresh the list
      } else {
        throw ServerFailure(data['message'] ?? 'Failed to add product');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> productData) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await httpClient.post('${ApiEndpoints.products}/$productId', productData);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await loadProducts(); // Refresh the list
      } else {
        throw ServerFailure(data['message'] ?? 'Failed to update product');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await httpClient.post('${ApiEndpoints.products}/$productId/delete', {});
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await loadProducts(); // Refresh the list
      } else {
        throw ServerFailure(data['message'] ?? 'Failed to delete product');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}