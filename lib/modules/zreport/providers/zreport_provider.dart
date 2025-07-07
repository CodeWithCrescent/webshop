import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webshop/core/network/api_endpoints.dart';
import 'package:webshop/core/network/http_client.dart';
import 'package:webshop/core/utils/debouncer.dart';
import 'package:webshop/modules/zreport/models/zreport.dart';

class ZReportProvider with ChangeNotifier {
  final HttpClient _httpClient;
  List<ZReport> _reports = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  final int _perPage = 20;
  String _searchQuery = '';
  final Debouncer _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));

  List<ZReport> get reports => _reports;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  ZReportProvider({required HttpClient httpClient}) : _httpClient = httpClient;

  @override
  void dispose() {
    _searchDebouncer.dispose();
    super.dispose();
  }

  Future<void> fetchZReports({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
    }

    if (!_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _httpClient.get(
        '${ApiEndpoints.getZReport}?page=$_page&per_page=$_perPage',
      );

      if (response!.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> reportList = data['zreport'];
        final newReports = reportList.map((map) => ZReport.fromMap(map)).toList();

        if (refresh) {
          _reports.clear();
        }

        _reports.addAll(newReports);
        _hasMore = newReports.length == _perPage;
        _page++;
      } else {
        throw Exception('Failed to load Z-Reports: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching Z-Reports: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _searchDebouncer.run(_filterReports);
  }

  void _filterReports() {
    if (_searchQuery.isEmpty) {
      notifyListeners();
      return;
    }

    _reports = _reports.where((report) =>
      report.reportNumber.contains(_searchQuery) ||
      report.reportDate.toString().contains(_searchQuery)
    ).toList();
    notifyListeners();
  }
}