import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webshop/core/network/api_endpoints.dart';
import 'package:webshop/core/network/http_client.dart';
import 'package:webshop/modules/receipts/models/receipt.dart';

enum ReceiptFilter {
  all,
  today,
  thisWeek,
  lastMonth,
  date,
  dateRange,
}

class ReceiptProvider with ChangeNotifier {
  final HttpClient httpClient;
  List<Receipt> _receipts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  String _searchQuery = '';
  ReceiptFilter _currentFilter = ReceiptFilter.all;

  ReceiptProvider({required this.httpClient});

  List<Receipt> get receipts => _receipts;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  int get receiptCount => _receipts.length;
  String get searchQuery => _searchQuery;
  ReceiptFilter get currentFilter => _currentFilter;

  Future<void> fetchReceipts({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _page = 1;
      _hasMore = true;
      _receipts = [];
    }

    if (!_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final url = '${ApiEndpoints.getReceipts}?page=$_page&search=$_searchQuery';
      final response = await httpClient.get(url);
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> receiptsData = data['receipts'] ?? [];
        final newReceipts = receiptsData.map((r) => Receipt.fromMap(r)).toList();

        _hasMore = newReceipts.isNotEmpty;
        if (refresh) {
          _receipts = newReceipts;
        } else {
          _receipts.addAll(newReceipts);
        }
        _page++;
      } else {
        throw Exception('Failed to load receipts');
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Receipt> fetchReceiptDetails(String receiptNumber) async {
    try {
      final url = '${ApiEndpoints.getReceipts}/receiptno/$receiptNumber';
      final response = await httpClient.get(url);
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return Receipt.fromMap(data['receiptData']);
      } else {
        throw Exception('Failed to load receipt details');
      }
    } catch (e) {
      rethrow;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchReceipts(refresh: true);
  }

  void setFilter(
    ReceiptFilter filter, {
    DateTime? date,
    DateTimeRange? range,
  }) {
    _currentFilter = filter;
    fetchReceipts(refresh: true);
  }
}