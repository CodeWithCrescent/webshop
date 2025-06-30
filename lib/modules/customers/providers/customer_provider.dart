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

  CustomerProvider({required this.localDataSource, required HttpClient httpClient});

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
    _isLoading = true;
    notifyListeners();
    
    try {
      await localDataSource.addCustomer(customer);
      await fetchCustomers();
    } catch (e) {
      debugPrint('Error adding customer: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await localDataSource.updateCustomer(customer);
      await fetchCustomers();
    } catch (e) {
      debugPrint('Error updating customer: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await localDataSource.deleteCustomer(customerId);
      await fetchCustomers();
    } catch (e) {
      debugPrint('Error deleting customer: $e');
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