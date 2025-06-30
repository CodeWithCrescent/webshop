import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webshop/core/utils/debouncer.dart';
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
  final List<Receipt> _allReceipts = [];
  List<Receipt> _filteredReceipts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  final int _perPage = 20;
  String _searchQuery = '';
  ReceiptFilter _filter = ReceiptFilter.all;
  DateTime? _selectedDate;
  DateTimeRange? _selectedDateRange;
  final Debouncer _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));

  List<Receipt> get receipts => _filteredReceipts;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  ReceiptFilter get currentFilter => _filter;
  DateTime? get selectedDate => _selectedDate;
  DateTimeRange? get selectedDateRange => _selectedDateRange;
  int get receiptCount => _filteredReceipts.length;

  Future<void> fetchReceipts({bool refresh = false}) async {
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
      
      final newReceipts = List.generate(20, (index) => Receipt.fromMap({
        'receipt_number': '2023${(_page * _perPage) + index}',
        'verificationcode': 'E75A80${(_page * _perPage) + index}',
        'receipt_time': '10:00:00',
        'receipt_date': DateTime.now().subtract(Duration(days: index)).toIso8601String(),
        'znum': '20230630',
        'verif_link': '',
        'isdemo': 'no',
        'vrn': '40005434B',
        'total_excl_of_tax': 1000.0 + (index * 100),
        'total_tax': 180.0 + (index * 18),
        'total_incl_of_tax': 1180.0 + (index * 118),
        'discount': 0.0,
        'customer_id_type': 'TIN',
        'customer_id_number': '123456789',
        'customer_name': 'Customer ${index + 1}',
        'customer_mobile': '25578${100000 + index}',
        'items': [
          {
            'itemcode': 'ITEM${index + 1}',
            'itemdesc': 'Product ${index + 1}',
            'itemqty': index + 1,
            'amount': 500.0 + (index * 50),
          }
        ],
      }));

      if (refresh) {
        _allReceipts.clear();
      }

      _allReceipts.addAll(newReceipts);
      _applyFilters();
      
      _hasMore = newReceipts.length == _perPage;
      _page++;
    } catch (e) {
      debugPrint('Error fetching receipts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Receipt> fetchReceiptDetails(String receiptNumber) async {
    // Simulate API call - replace with actual API call
    await Future.delayed(const Duration(seconds: 1));
    
    return Receipt.fromMap({
      'receipt_number': receiptNumber,
      'verificationcode': 'E75A80$receiptNumber',
      'receipt_time': '10:00:00',
      'receipt_date': DateTime.now().toIso8601String(),
      'znum': '20230630',
      'verif_link': '',
      'isdemo': 'no',
      'vrn': '40005434B',
      'total_excl_of_tax': 1000.0,
      'total_tax': 180.0,
      'total_incl_of_tax': 1180.0,
      'discount': 0.0,
      'customer_id_type': 'TIN',
      'customer_id_number': '123456789',
      'customer_name': 'John Doe',
      'customer_mobile': '255784313200',
      'items': [
        {
          'itemcode': 'ITEM001',
          'itemdesc': 'Product 1',
          'itemqty': 2,
          'amount': 500.0,
        },
        {
          'itemcode': 'ITEM002',
          'itemdesc': 'Product 2',
          'itemqty': 1,
          'amount': 600.0,
        }
      ],
    });
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _searchDebouncer.run(_applyFilters);
  }

  void setFilter(ReceiptFilter filter, {DateTime? date, DateTimeRange? range}) {
    _filter = filter;
    _selectedDate = date;
    _selectedDateRange = range;
    _applyFilters();
  }

  void _applyFilters() {
    // Apply date filter
    _filteredReceipts = _allReceipts.where((receipt) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final thisWeek = today.subtract(const Duration(days: 7));
      final lastMonth = DateTime(now.year, now.month - 1, 1);
      
      switch (_filter) {
        case ReceiptFilter.today:
          return receipt.receipt_date.isAfter(today);
        case ReceiptFilter.thisWeek:
          return receipt.receipt_date.isAfter(thisWeek);
        case ReceiptFilter.lastMonth:
          return receipt.receipt_date.isAfter(lastMonth) && 
                 receipt.receipt_date.isBefore(today);
        case ReceiptFilter.date:
          return _selectedDate != null 
              ? receipt.receipt_date.year == _selectedDate!.year &&
                receipt.receipt_date.month == _selectedDate!.month &&
                receipt.receipt_date.day == _selectedDate!.day
              : false;
        case ReceiptFilter.dateRange:
          return _selectedDateRange != null 
              ? receipt.receipt_date.isAfter(_selectedDateRange!.start) &&
                receipt.receipt_date.isBefore(_selectedDateRange!.end)
              : false;
        case ReceiptFilter.all:
        default:
          return true;
      }
    }).toList();

    // Apply search
    if (_searchQuery.isNotEmpty) {
      _filteredReceipts = _filteredReceipts.where((receipt) =>
          receipt.receipt_number.contains(_searchQuery) ||
          receipt.customer_name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          receipt.customer_mobile.contains(_searchQuery)).toList();
    }

    // Sort by newest first
    _filteredReceipts.sort((a, b) => b.receipt_date.compareTo(a.receipt_date));
    notifyListeners();
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    super.dispose();
  }
}