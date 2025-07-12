import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:webshop/core/constants/app_colors.dart';
import 'package:webshop/core/localization/app_localizations.dart';
import 'package:webshop/modules/zreport/models/zreport.dart';
import 'package:webshop/modules/zreport/providers/zreport_provider.dart';
import 'package:webshop/shared/providers/auth_provider.dart';
import 'package:webshop/shared/widgets/app_bar.dart';
import 'package:webshop/shared/widgets/refreshable_widget.dart';
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
    _checkAuthentication();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ZReportProvider>().fetchZReports();
    });
  }

  Future<void> _checkAuthentication() async {
    final authProvider = context.read<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      await authProvider.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
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
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: 'TZS');

    return Scaffold(
      appBar: WebshopAppBar(
        title: loc?.translate('zreport.title') ?? 'Z-Reports',
      ),
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SearchField(
                controller: _searchController,
                hintText: loc?.translate('common.search') ?? 'Search Z-Reports',
                onChanged: provider.setSearchQuery,
              ),
            ),
            Expanded(
              child: RefreshableWidget(
                onRefresh: () => provider.fetchZReports(refresh: true),
                enablePullUp: provider.hasMore,
                builder: (context) => ListView.builder(
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
                    final report = provider.reports[index];
                    return _buildReportCard(report, currencyFormat);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(ZReport report, NumberFormat currencyFormat) {
    return Card(
      elevation: 0.5,
      surfaceTintColor: AppColors.cardLight,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Z-Report #${report.reportNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  report.formattedDate,
                  style: TextStyle(color: Colors.grey[600]),
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
                  currencyFormat.format(report.totalGross),
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
                  'Subtotal: ${currencyFormat.format(report.subtotal)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  'VAT: ${currencyFormat.format(report.vat)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}