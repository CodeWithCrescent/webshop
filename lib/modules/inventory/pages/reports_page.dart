import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Inventory Reports'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Today'),
              Tab(text: 'Yesterday'),
              Tab(text: 'Weekly'),
              Tab(text: 'Monthly'),
              Tab(text: 'Custom'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildReportView('today'),
            _buildReportView('yesterday'),
            _buildReportView('weekly'),
            _buildReportView('monthly'),
            _buildCustomReportView(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportView(String period) {
    return Consumer<InventoryProvider>(
      builder: (context, provider, _) {
        final report = provider.getSalesReport(period);
        return ListView(
          children: [
            _buildSummaryCards(report),
            _buildTopSellingProducts(report),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCards(SalesReport report) {
    return Row(
      children: [
        Expanded(
            child: SummaryCard(title: 'Total Sales', value: report.totalSales)),
        Expanded(
            child: SummaryCard(title: 'Items Sold', value: report.itemsSold)),
        Expanded(
            child: SummaryCard(title: 'Top Product', value: report.topProduct)),
      ],
    );
  }
}
