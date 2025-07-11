import 'package:flutter/material.dart';
import 'package:webshop/core/network/api_endpoints.dart';
import 'package:webshop/core/network/http_client.dart';
import 'package:webshop/modules/customers/models/customer.dart';
import 'package:webshop/modules/inventory/models/product.dart';
import 'package:webshop/modules/sales/models/sale.dart';
import 'package:webshop/modules/sales/models/sale_item.dart';
import 'package:webshop/modules/settings/providers/business_profile_provider.dart';

class SalesProvider with ChangeNotifier {
  final HttpClient httpClient;
  final BusinessProfileProvider businessProfileProvider;

  final List<SaleItem> _cartItems = [];
  Customer? _selectedCustomer;
  bool _isLoading = false;
  String? _error;
  double? _latitude;
  double? _longitude;

  List<SaleItem> get cartItems => _cartItems;
  Customer? get selectedCustomer => _selectedCustomer;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  SalesProvider({
    required this.httpClient,
    required this.businessProfileProvider,
  });

  void addToCart(Product product, {int quantity = 1}) {
    final isVatRegistered =
        businessProfileProvider.businessProfile?.vrn.isNotEmpty ?? false;
    final existingIndex =
        _cartItems.indexWhere((item) => item.productId == product.id);

    if (existingIndex >= 0) {
      final existingItem = _cartItems[existingIndex];
      final newQuantity = existingItem.quantity + quantity;
      _cartItems[existingIndex] = existingItem.copyWith(
        quantity: newQuantity,
        totalAmount: (product.price * newQuantity) +
            _calculateTax(product.price * newQuantity, product.taxCategory,
                isVatRegistered),
      );
    } else {
      final totalAmount = (product.price * quantity) +
          _calculateTax(
              product.price * quantity, product.taxCategory, isVatRegistered);

      _cartItems.add(SaleItem(
        saleId: '',
        productId: product.id,
        productCode: product.code,
        productName: product.name,
        quantity: quantity,
        price: product.price,
        taxCategory: product.taxCategory,
        totalAmount: totalAmount,
        isVatRegistered: isVatRegistered,
      ));
    }

    notifyListeners();
  }

  // Helper method for tax calculation
  double _calculateTax(double amount, int taxCategory, bool isVatRegistered) {
    if (!isVatRegistered || taxCategory != 1) {
      return 0.0;
    }
    return amount * 0.18; // 18% VAT for standard rated items
  }

  void updateCartItemQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(index);
      return;
    }

    final item = _cartItems[index];
    _cartItems[index] = item.copyWith(
      quantity: newQuantity,
      totalAmount: (item.price * newQuantity) +
          _calculateTax(
              item.price * newQuantity, item.taxCategory, item.isVatRegistered),
    );

    notifyListeners();
  }

  void removeFromCart(int index) {
    _cartItems.removeAt(index);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _selectedCustomer = null;
    _latitude = null;
    _longitude = null;
    notifyListeners();
  }

  void selectCustomer(Customer? customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }

  void setLocation(double latitude, double longitude) {
    _latitude = latitude;
    _longitude = longitude;
    notifyListeners();
  }

  double get subtotal {
    return _cartItems.fold(0, (sum, item) => sum + item.netAmount);
  }

  double get taxTotal {
    return _cartItems.fold(0, (sum, item) => sum + item.taxAmount);
  }

  double get grandTotal {
    return _cartItems.fold(0, (sum, item) => sum + item.totalAmount);
  }

  Future<void> completeSale(String paymentType) async {
    _isLoading = true;
    notifyListeners();
    final isVatRegistered =
        businessProfileProvider.businessProfile?.vrn.isNotEmpty ?? false;

    try {
      final sale = Sale(
        date: DateTime.now(),
        customerId: _selectedCustomer?.id,
        totalAmount: grandTotal,
        totalTax: taxTotal,
        totalNet: subtotal,
        paymentType: paymentType,
        latitude: _latitude,
        longitude: _longitude,
        isVatRegistered: isVatRegistered,
      );

      // Prepare receipt payload
      final payload = _buildReceiptPayload(sale);

      // Send to API
      final response = await httpClient.post(
        ApiEndpoints.generateReceipt,
        payload,
      );

      if (response!.statusCode == 200) {
        // Success - clear cart
        clearCart();
      } else {
        throw Exception('Failed to complete sale: ${response.statusCode}');
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _buildReceiptPayload(Sale sale) {
    return {
      "dbrecord": {
        "invoice_id": "INV${DateTime.now().millisecondsSinceEpoch}",
        "invoice_date": sale.date.toIso8601String().split('T')[0],
      },
      "customer": _selectedCustomer != null
          ? {
              "idtype": "6", // Using Telephone as default
              "idnumber": _selectedCustomer!.phoneNumber,
              "mobile": _selectedCustomer!.phoneNumber,
              "name": _selectedCustomer!.fullName,
            }
          : null,
      "items": _cartItems
          .map((item) => {
                "itemcode": item.productCode,
                "itemdesc": item.productName,
                "itemqty": item.quantity,
                "net": item.netAmount,
                "tax": item.taxAmount,
                "amount": item.totalAmount,
                "discountamout": 0,
                "itemtaxcode": item.taxCategory,
              })
          .toList(),
      "payment": {
        "paymenttype": sale.paymentType,
      }
    };
  }
}
