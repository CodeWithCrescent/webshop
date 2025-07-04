import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webshop/core/network/api_endpoints.dart';
import 'package:webshop/core/network/http_client.dart';

class DashboardProvider with ChangeNotifier {
  final SharedPreferences prefs;
  final HttpClient httpClient;

  bool _isLoading = false;
  String? _error;
  String? _totalAmount;
  String? _totalMonthAmount;
  String? _date;
  String? _totalReceipts;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get totalMonthAmount => _totalMonthAmount;
  String? get totalReceipts => _totalReceipts;
  String? get totalAmount => _totalAmount;
  String? get date => _date;

  DashboardProvider(this.prefs, this.httpClient);

  Future<void> fetchDashboardData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await httpClient.get(ApiEndpoints.dashboard);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final dashboard = data['dashboard'];

        _totalAmount = dashboard['total_amount'] ?? '0';
        _totalMonthAmount = dashboard['total_month_amount'] ?? '0';
        _date = dashboard['date'] ?? '-';
        _totalReceipts = dashboard['total_rct'] ?? '0';
        _error = null;
      } else {
        _error = 'Failed to load dashboard data';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateZReport() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await httpClient.get(ApiEndpoints.getZReport);

      if (response.statusCode == 200) {
        await fetchDashboardData(); // Refresh after success
      } else {
        _error = 'Failed to generate Z report';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
