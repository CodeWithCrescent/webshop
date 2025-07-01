import 'package:flutter/material.dart';
import 'package:webshop/core/network/http_client.dart';
import 'package:webshop/core/utils/debouncer.dart';
import 'package:webshop/modules/customers/data/local/customer_local_datasource.dart';
import 'package:webshop/modules/customers/models/customer.dart';

class CustomerProvider with ChangeNotifier {
  final CustomerLocalDataSource localDataSource;
  
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  String _searchQuery = '';
  bool _isLoading = false;
  final Debouncer _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));

  List<Customer> get customers => _filteredCustomers;
  bool get isLoading => _isLoading;
  String? _error;

  CustomerProvider({required this.localDataSource, required HttpClient httpClient});
  String? get error => _error;

  @override
  void dispose() {
    _searchDebouncer.dispose();
    super.dispose();
  }

  Future<void> fetchCustomers() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _customers = await localDataSource.getCustomers();
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading customers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCustomer(Customer customer) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await localDataSource.addCustomer(customer);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await localDataSource.updateCustomer(customer);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await localDataSource.deleteCustomer(customerId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Customer>> getCustomers() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final customers = await localDataSource.getCustomers();
      _error = null;
      return customers;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _searchDebouncer.run(_applyFilters);
  }

  void _applyFilters() {
    _filteredCustomers = _customers.where((customer) {
      final matchesSearch = _searchQuery.isEmpty ||
          customer.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) || 
          customer.phoneNumber.contains(_searchQuery) ||
          (customer.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesSearch;
    }).toList();

    // Sort by name
    _filteredCustomers.sort((a, b) => a.fullName.compareTo(b.fullName));
    notifyListeners();
  }
}