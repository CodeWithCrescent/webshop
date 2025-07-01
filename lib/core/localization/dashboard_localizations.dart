import 'package:flutter/material.dart';
import 'package:webshop/core/localization/app_localizations.dart';

class DashboardLocalizations {
  final BuildContext context;

  DashboardLocalizations(this.context);

  String get title => _translate('dashboard.title');
  String get welcome => _translate('dashboard.welcome');
  String get subtitle => _translate('dashboard.subtitle');
  String get todaySales => _translate('dashboard.today_sales');
  String get todayReceipts => _translate('dashboard.today_receipts');
  String get monthlySales => _translate('dashboard.monthly_sales');
  String get date => _translate('dashboard.date');
  String get saleDate => _translate('dashboard.sale_date');
  String get totalOrders => _translate('dashboard.total_orders');
  String get avgSale => _translate('dashboard.avg_sale');
  String get topSelling => _translate('dashboard.top_selling');
  String get salesOverview => _translate('dashboard.sales_overview');
  String get daily => _translate('dashboard.daily');
  String get monthly => _translate('dashboard.monthly');
  String get recentSales => _translate('dashboard.recent_sales');
  String get viewAll => _translate('dashboard.view_all');
  String get generateZReport => _translate('dashboard.generate_z_report');
  String get lastUpdated => _translate('dashboard.last_updated');
  String get quickActions => _translate('dashboard.quick_actions');
  String get cashSales => _translate('dashboard.cash_sales');
  String get registerCustomer => _translate('dashboard.register_customer');
  String get createInvoice => _translate('dashboard.create_invoice');

  String _translate(String key) => AppLocalizations.of(context)!.translate(key);
}
