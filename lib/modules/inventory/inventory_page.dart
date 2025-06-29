import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/search_field.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/empty_state.dart';
import 'inventory_provider.dart';
import 'product_modal.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InventoryProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = Provider.of<InventoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('menu.inventory')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: provider.loadProducts,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onPressed: () => _showProductModal(context, null),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchField(
              hintText: loc.translate('search_products'),
              onChanged: provider.setSearchQuery,
            ),
          ),
          Expanded(
            child: _buildContent(context, provider, loc),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, InventoryProvider provider, AppLocalizations loc) {
    if (provider.isLoading && provider.products.isEmpty) {
      return const Center(child: SpinKitCircle(color: AppColors.primary));
    }

    if (provider.error != null) {
      return Center(
        child: Text(
          provider.error!,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
        ),
      );
    }

    if (provider.products.isEmpty) {
      return EmptyState(
        icon: Icons.inventory,
        title: loc.translate('empty_inventory_title'),
        subtitle: loc.translate('empty_inventory_subtitle'),
        actionText: loc.translate('add_first_product'),
        onAction: () => _showProductModal(context, null),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.loadProducts,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: provider.products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final product = provider.products[index];
          return _buildProductCard(context, product, loc);
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, dynamic product, AppLocalizations loc) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showProductModal(context, product),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.shopping_bag,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['code'],
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${product['price']} TZS',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product['stock']} in stock',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: product['stock'] > 0 
                          ? AppColors.success 
                          : AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProductModal(BuildContext context, dynamic product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ProductModal(
          product: product,
          onSave: (productData) async {
            if (product == null) {
              await Provider.of<InventoryProvider>(context, listen: false)
                  .addProduct(productData);
            } else {
              await Provider.of<InventoryProvider>(context, listen: false)
                  .updateProduct(product['id'], productData);
            }
          },
          onDelete: product != null 
              ? () async {
                  await Provider.of<InventoryProvider>(context, listen: false)
                      .deleteProduct(product['id']);
                  Navigator.pop(context);
                }
              : null,
        );
      },
    );
  }
}