import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webshop/core/constants/app_colors.dart';
import 'package:webshop/core/constants/app_text_styles.dart';
import 'package:webshop/core/localization/app_localizations.dart';
import 'package:webshop/core/utils/format_utils.dart';
import 'package:webshop/modules/dashboard/dashboard_provider.dart';
import 'package:webshop/modules/receipts/pages/receipts_page.dart';
import 'package:webshop/modules/sales/pages/sales_page.dart';
import 'package:webshop/modules/zreport/zreports_page.dart';
import 'package:webshop/shared/providers/auth_provider.dart';
import 'package:webshop/shared/widgets/action_button.dart';
import 'package:webshop/shared/widgets/app_bar.dart';
import 'package:webshop/shared/widgets/horizontal_stat_card.dart';
import 'package:webshop/shared/widgets/refreshable_widget.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDashboardData();
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

  Future<void> _fetchDashboardData() async {
    await Provider.of<DashboardProvider>(context, listen: false)
        .fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.primary.withOpacity(0.1),
      appBar: WebshopAppBar(
        title: loc.translate('common.app_name'),
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && !provider.hasData) {
            return const Center(child: SpinKitCircle(color: AppColors.primary));
          }

          if (provider.error != null) {
            return _buildErrorWidget(provider.error!, provider);
          }

          return RefreshableWidget(
            onRefresh: _fetchDashboardData,
            builder: (context) =>
                _buildDashboardContent(context, provider, loc),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error, DashboardProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            error,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.red.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => provider.fetchDashboardData(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    DashboardProvider provider,
    AppLocalizations loc,
  ) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildWelcomeSection(provider, loc)),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          sliver: SliverToBoxAdapter(
            child: HorizontalStatCard(
              icon: Icons.receipt_long,
              iconColor: AppColors.secondary,
              title: loc.translate('dashboard.today_receipts'),
              value: provider.totalReceipts ?? '0',
              subtitle: loc.translate('dashboard.date'),
              subtitleValue: provider.date ?? '-',
            ),
          ),
        ),
        SliverToBoxAdapter(child: _buildQuickActionsSection(context, loc)),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildWelcomeSection(
    DashboardProvider provider,
    AppLocalizations loc,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.translate('dashboard.monthly_sales'),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textLight.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      FormatUtils.formatCurrency(provider.totalMonthAmount),
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.textLight.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.dashboard,
                  color: AppColors.textLight,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.textLight.withOpacity(0.75),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textLight.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.attach_money_outlined,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.translate("dashboard.today_sales"),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        FormatUtils.formatCurrency(provider.totalAmount),
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.textPrimary.withOpacity(0.75),
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            loc.translate('dashboard.quick_actions'),
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  title: loc.translate('menu.cash_sales'),
                  icon: Icons.add_shopping_cart,
                  color: AppColors.primary,
                  onTap: () => _navigateToCashSales(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ActionButton(
                  title: loc.translate('menu.receipts'),
                  icon: Icons.receipt_long,
                  color: AppColors.secondary,
                  onTap: () => _navigateToReceipts(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  title: loc.translate('menu.fm_reports'),
                  icon: Icons.show_chart,
                  color: AppColors.secondary,
                  onTap: () => _navigateToFmReports(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ActionButton(
                  title: loc.translate('menu.z_reports'),
                  icon: Icons.bar_chart,
                  color: AppColors.primary,
                  onTap: () => _navigateToZreports(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToCashSales(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SalesPage(),
      ),
    );
  }

  void _navigateToReceipts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReceiptsPage()),
    );
  }

  void _navigateToFmReports(BuildContext context) {
    // TODO: Create page view for FM Reports
    debugPrint("FM Reports Clicked!");
  }

  void _navigateToZreports(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ZReportsPage()),
    );
  }
}
