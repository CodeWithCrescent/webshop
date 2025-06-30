import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:webshop/core/localization/app_localizations.dart';
import 'package:webshop/modules/receipts/models/receipt.dart';
import 'package:webshop/modules/receipts/pages/receipt_detail_page.dart';
import 'package:webshop/modules/receipts/providers/receipt_provider.dart';
import 'package:webshop/shared/widgets/app_bar.dart';
import 'package:webshop/shared/widgets/search_field.dart';

class ReceiptsPage extends StatefulWidget {
  const ReceiptsPage({super.key});

  @override
  State<ReceiptsPage> createState() => _ReceiptsPageState();
}

class _ReceiptsPageState extends State<ReceiptsPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReceiptProvider>().fetchReceipts();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<ReceiptProvider>().fetchReceipts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.watch<ReceiptProvider>();

    return Scaffold(
      appBar: WebshopAppBar(
        title: loc?.translate('receipts.title') ?? 'Receipts',
        onRefresh: () => provider.fetchReceipts(refresh: true),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SearchField(
                    controller: _searchController,
                    hintText: loc?.translate('common.search') ?? 'Search receipts',
                    onChanged: provider.setSearchQuery,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_alt),
                  onPressed: () => _showFilterDialog(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${loc?.translate('common.total') ?? 'Total'}: ${provider.receiptCount}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _getFilterText(provider.currentFilter, loc),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.fetchReceipts(refresh: true),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: provider.receipts.length + (provider.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == provider.receipts.length) {
                    return Center(
                      child: provider.isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            )
                          : const SizedBox(),
                    );
                  }
                  return _buildReceiptCard(provider.receipts[index], loc);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptCard(Receipt receipt, AppLocalizations? loc) {
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: 'TZS');
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _navigateToReceiptDetail(receipt.receipt_number),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Receipt #${receipt.receipt_number}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    receipt.formattedDate,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    receipt.customer_name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    currencyFormat.format(receipt.total_incl_of_tax),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${loc?.translate('receipts.items') ?? 'Items'}: ${receipt.items.length}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    receipt.receipt_time,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFilterText(ReceiptFilter filter, AppLocalizations? loc) {
    switch (filter) {
      case ReceiptFilter.today:
        return loc?.translate('receipts.filter_today') ?? 'Today';
      case ReceiptFilter.thisWeek:
        return loc?.translate('receipts.filter_this_week') ?? 'This Week';
      case ReceiptFilter.lastMonth:
        return loc?.translate('receipts.filter_last_month') ?? 'Last Month';
      case ReceiptFilter.date:
        return loc?.translate('receipts.filter_date') ?? 'Specific Date';
      case ReceiptFilter.dateRange:
        return loc?.translate('receipts.filter_date_range') ?? 'Date Range';
      case ReceiptFilter.all:
      default:
        return loc?.translate('receipts.filter_all') ?? 'All Receipts';
    }
  }

  void _showFilterDialog(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.read<ReceiptProvider>();
    DateTimeRange? tempDateRange;
    DateTime? tempDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(loc?.translate('common.filter') ?? 'Filter'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFilterOption(
                      context,
                      provider.currentFilter == ReceiptFilter.all,
                      loc?.translate('receipts.filter_all') ?? 'All Receipts',
                      () => setState(() => tempDateRange = tempDate = null),
                    ),
                    _buildFilterOption(
                      context,
                      provider.currentFilter == ReceiptFilter.today,
                      loc?.translate('receipts.filter_today') ?? 'Today',
                      () => setState(() => tempDateRange = tempDate = null),
                    ),
                    _buildFilterOption(
                      context,
                      provider.currentFilter == ReceiptFilter.thisWeek,
                      loc?.translate('receipts.filter_this_week') ?? 'This Week',
                      () => setState(() => tempDateRange = tempDate = null),
                    ),
                    _buildFilterOption(
                      context,
                      provider.currentFilter == ReceiptFilter.lastMonth,
                      loc?.translate('receipts.filter_last_month') ?? 'Last Month',
                      () => setState(() => tempDateRange = tempDate = null),
                    ),
                    _buildFilterOption(
                      context,
                      provider.currentFilter == ReceiptFilter.date,
                      loc?.translate('receipts.filter_date') ?? 'Specific Date',
                      () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => tempDate = date);
                        }
                      },
                      trailing: tempDate != null
                          ? Text(DateFormat('dd MMM yyyy').format(tempDate!))
                          : null,
                    ),
                    _buildFilterOption(
                      context,
                      provider.currentFilter == ReceiptFilter.dateRange,
                      loc?.translate('receipts.filter_date_range') ?? 'Date Range',
                      () async {
                        final range = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          initialDateRange: DateTimeRange(
                            start: DateTime.now().subtract(const Duration(days: 7)),
                            end: DateTime.now(),
                          ),
                        );
                        if (range != null) {
                          setState(() => tempDateRange = range);
                        }
                      },
                      trailing: tempDateRange != null
                          ? Text(
                              '${DateFormat('dd MMM').format(tempDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(tempDateRange!.end)}')
                          : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(loc?.translate('common.cancel') ?? 'Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    ReceiptFilter selectedFilter = provider.currentFilter;
                    if (tempDate != null) {
                      selectedFilter = ReceiptFilter.date;
                    } else if (tempDateRange != null) {
                      selectedFilter = ReceiptFilter.dateRange;
                    }
                    provider.setFilter(
                      selectedFilter,
                      date: tempDate,
                      range: tempDateRange,
                    );
                    Navigator.pop(context);
                  },
                  child: Text(loc?.translate('common.apply') ?? 'Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFilterOption(
    BuildContext context,
    bool isSelected,
    String title,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return ListTile(
      title: Text(title),
      trailing: trailing,
      leading: Radio<bool>(
        value: isSelected,
        groupValue: true,
        onChanged: (value) => onTap(),
      ),
      onTap: onTap,
    );
  }

  void _navigateToReceiptDetail(String receiptNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptDetailPage(receiptNumber: receiptNumber),
      ),
    );
  }
}