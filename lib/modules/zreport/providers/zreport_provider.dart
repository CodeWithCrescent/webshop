import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webshop/core/utils/debouncer.dart';
import 'package:webshop/modules/zreport/models/zreport.dart';

enum ZReportFilter {
  all,
  today,
  date,
  lastMonth,
  dateRange,
}

enum ZReportSort {
  newestFirst,
  oldestFirst,
  highestAmount,
  lowestAmount,
}

class ZReportProvider with ChangeNotifier {
  final List<ZReport> _allReports = [];
  List<ZReport> _filteredReports = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  final int _perPage = 20;
  String _searchQuery = '';
  ZReportFilter _filter = ZReportFilter.all;
  DateTime? _selectedDate;
  DateTimeRange? _selectedDateRange;
  ZReportSort _sort = ZReportSort.newestFirst;

  final Debouncer _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));

  List<ZReport> get reports => _filteredReports;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  ZReportFilter get currentFilter => _filter;
  ZReportSort get currentSort => _sort;
  DateTime? get selectedDate => _selectedDate;
  DateTimeRange? get selectedDateRange => _selectedDateRange;

  Future<void> fetchZReports({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
    }

    if (!_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call - replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      final newReports = List.generate(20, (index) => ZReport(
        reportNumber: '2023${(_page * _perPage) + index}',
        reportDate: DateTime.now().subtract(Duration(days: index)),
        reportTime: '10:00:00',
        subtotal: 1000.0 + (index * 100),
        discount: 0.0,
        total: 1000.0 + (index * 100),
        vat: 180.0 + (index * 18),
        totalGross: 1180.0 + (index * 118),
      ));

      if (refresh) {
        _allReports.clear();
      }

      _allReports.addAll(newReports);
      _applyFilters();
      
      _hasMore = newReports.length == _perPage;
      _page++;
    } catch (e) {
      debugPrint('Error fetching Z-Reports: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _searchDebouncer.run(_applyFilters);
  }

  void setFilter(ZReportFilter filter, {DateTime? date, DateTimeRange? range}) {
    _filter = filter;
    _selectedDate = date;
    _selectedDateRange = range;
    _applyFilters();
  }

  void setSort(ZReportSort sort) {
    _sort = sort;
    _applyFilters();
  }

  void _applyFilters() {
    // Apply date filter
    _filteredReports = _allReports.where((report) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      switch (_filter) {
        case ZReportFilter.today:
          return report.reportDate.isAfter(today);
        case ZReportFilter.date:
          return _selectedDate != null 
              ? report.reportDate.year == _selectedDate!.year &&
                report.reportDate.month == _selectedDate!.month &&
                report.reportDate.day == _selectedDate!.day
              : false;
        case ZReportFilter.lastMonth:
          final lastMonth = DateTime(now.year, now.month - 1, 1);
          return report.reportDate.isAfter(lastMonth) && report.reportDate.isBefore(today);
        case ZReportFilter.dateRange:
          return _selectedDateRange != null 
              ? report.reportDate.isAfter(_selectedDateRange!.start) &&
                report.reportDate.isBefore(_selectedDateRange!.end)
              : false;
        case ZReportFilter.all:
        default:
          return true;
      }
    }).toList();

    // Apply search
    if (_searchQuery.isNotEmpty) {
      _filteredReports = _filteredReports.where((report) =>
          report.reportNumber.contains(_searchQuery)).toList();
    }

    // Apply sorting
    switch (_sort) {
      case ZReportSort.newestFirst:
        _filteredReports.sort((a, b) => b.reportDate.compareTo(a.reportDate));
        break;
      case ZReportSort.oldestFirst:
        _filteredReports.sort((a, b) => a.reportDate.compareTo(b.reportDate));
        break;
      case ZReportSort.highestAmount:
        _filteredReports.sort((a, b) => b.total.compareTo(a.total));
        break;
      case ZReportSort.lowestAmount:
        _filteredReports.sort((a, b) => a.total.compareTo(b.total));
        break;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    super.dispose();
  }
}