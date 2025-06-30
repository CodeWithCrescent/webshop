import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:webshop/core/constants/app_colors.dart';
import 'package:webshop/core/localization/app_localizations.dart';
import 'package:webshop/modules/zreport/models/zreport.dart';
import 'package:webshop/modules/zreport/providers/zreport_provider.dart';
import 'package:webshop/shared/widgets/app_bar.dart';
import 'package:webshop/shared/widgets/custom_date_range_picker.dart';
import 'package:webshop/shared/widgets/search_field.dart';

class ZReportsPage extends StatefulWidget {
  const ZReportsPage({super.key});

  @override
  State<ZReportsPage> createState() => _ZReportsPageState();
}

class _ZReportsPageState extends State<ZReportsPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ZReportProvider>().fetchZReports();
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
      context.read<ZReportProvider>().fetchZReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.watch<ZReportProvider>();

    return Scaffold(
      appBar: WebshopAppBar(
        title: loc?.translate('zreport.title') ?? 'Z-Reports',
        onRefresh: () => provider.fetchZReports(refresh: true),
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
                    hintText: loc?.translate('common.search') ?? 'Search',
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
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.fetchZReports(refresh: true),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: provider.reports.length + (provider.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == provider.reports.length) {
                    return Center(
                      child: provider.isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            )
                          : const SizedBox(),
                    );
                  }
                  return _buildReportCard(provider.reports[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(ZReport report) {
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: 'TZS');
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Report #${report.reportNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  report.formattedDate,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Time: ${report.reportTime}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  currencyFormat.format(report.total),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'VAT: ${currencyFormat.format(report.vat)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  'Gross: ${currencyFormat.format(report.totalGross)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.read<ZReportProvider>();
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
                      provider.currentFilter == ZReportFilter.all,
                      loc?.translate('zreport.filter_all') ?? 'All Reports',
                      () => setState(() => tempDateRange = tempDate = null),
                    ),
                    _buildFilterOption(
                      context,
                      provider.currentFilter == ZReportFilter.today,
                      loc?.translate('zreport.filter_today') ?? 'Today',
                      () => setState(() => tempDateRange = tempDate = null),
                    ),
                    _buildFilterOption(
                      context,
                      provider.currentFilter == ZReportFilter.lastMonth,
                      loc?.translate('zreport.filter_last_month') ?? 'Last Month',
                      () => setState(() => tempDateRange = tempDate = null),
                    ),
                    _buildFilterOption(
                      context,
                      provider.currentFilter == ZReportFilter.date,
                      loc?.translate('zreport.filter_date') ?? 'Specific Date',
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
                      provider.currentFilter == ZReportFilter.dateRange,
                      loc?.translate('zreport.filter_date_range') ?? 'Date Range',
                      () async {
                        final range = await showCustomDateRangePicker(
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
                    const Divider(),
                    Text(loc?.translate('common.sort_by') ?? 'Sort By'),
                    RadioListTile<ZReportSort>(
                      title: Text(loc?.translate('zreport.sort_newest') ?? 'Newest First'),
                      value: ZReportSort.newestFirst,
                      groupValue: provider.currentSort,
                      onChanged: (value) => setState(() {}),
                    ),
                    RadioListTile<ZReportSort>(
                      title: Text(loc?.translate('zreport.sort_oldest') ?? 'Oldest First'),
                      value: ZReportSort.oldestFirst,
                      groupValue: provider.currentSort,
                      onChanged: (value) => setState(() {}),
                    ),
                    RadioListTile<ZReportSort>(
                      title: Text(loc?.translate('zreport.sort_highest') ?? 'Highest Amount'),
                      value: ZReportSort.highestAmount,
                      groupValue: provider.currentSort,
                      onChanged: (value) => setState(() {}),
                    ),
                    RadioListTile<ZReportSort>(
                      title: Text(loc?.translate('zreport.sort_lowest') ?? 'Lowest Amount'),
                      value: ZReportSort.lowestAmount,
                      groupValue: provider.currentSort,
                      onChanged: (value) => setState(() {}),
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
                    ZReportFilter selectedFilter = provider.currentFilter;
                    if (tempDate != null) {
                      selectedFilter = ZReportFilter.date;
                    } else if (tempDateRange != null) {
                      selectedFilter = ZReportFilter.dateRange;
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
}