import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import 'package:webshop/core/constants/app_colors.dart';
import 'package:webshop/core/localization/inventory_localizations.dart';
import 'package:webshop/modules/inventory/models/product.dart';
import 'package:webshop/shared/widgets/app_bar.dart';
import 'package:webshop/shared/widgets/search_field.dart';
import 'package:webshop/modules/inventory/providers/inventory_provider.dart';
import 'package:webshop/modules/inventory/pages/product_modal.dart';

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
      context.read<InventoryProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = InventoryLocalizations(context);

    return Scaffold(
      backgroundColor: AppColors.primary.withOpacity(0.1),
      appBar: WebshopAppBar(
        title: loc.title,
        onRefresh: () => context.read<InventoryProvider>().init(),
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.products.isEmpty) {
            return const Center(child: SpinKitCircle(color: AppColors.primary));
          }

          // if (provider.error != null) {
          //   return Center(child: Text('Error: ${provider.error}'));
          // }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: SearchField(
                        hintText: loc.searchProducts,
                        onChanged: provider.setSearchQuery,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () => _showFilterDialog(context),
                    ),
                  ],
                ),
              ),
              _buildCategoryChips(provider),
              Expanded(child: _buildProductList(provider)),
            ],
          );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Theme.of(context).primaryColor,
      //   foregroundColor: Colors.white,
      //   child: const Icon(Icons.add),
      //   onPressed: () => _showProductModal(context, null),
      // ),
    );
  }

  Widget _buildCategoryChips(InventoryProvider provider) {
    final loc = InventoryLocalizations(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          FilterChip(
            label: Text(loc.allCategories),
            selected: provider.selectedCategory == null,
            onSelected: (_) => provider.setCategoryFilter(null),
          ),
          const SizedBox(width: 4),
          ...provider.categories.map((category) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(category.name),
                  selected: provider.selectedCategory == category.name,
                  onSelected: (_) => provider.setCategoryFilter(category.name),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildProductList(InventoryProvider provider) {
    final loc = InventoryLocalizations(context);

    if (provider.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(loc.emptyInventoryTitle,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(loc.emptyInventorySubtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _showProductModal(context, null),
              child: Text(loc.addFirstProduct),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: provider.products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(provider.products[index]);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final loc = InventoryLocalizations(context);
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.shopping_bag, color: theme.primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(product.code,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6))),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${product.price.toStringAsFixed(2)} TZS',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.primaryColor,
                      )),
                  const SizedBox(height: 4),
                  Text(
                    '${product.stock} ${loc.inStock}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: product.stock > 0
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.error,
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

  void _showProductModal(BuildContext context, Product? product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ProductModal(
          product: product,
          onSave: (productData) async {
            final provider = context.read<InventoryProvider>();
            if (product == null) {
              await provider.addProduct(productData);
            } else {
              await provider.updateProduct(productData);
            }
            if (context.mounted) Navigator.pop(context);
          },
          onDelete: product != null
              ? () async {
                  await context.read<InventoryProvider>().deleteProduct(product.id);
                  if (context.mounted) Navigator.pop(context);
                }
              : null,
        );
      },
    );
  }

  void _showFilterDialog(BuildContext context) {
    final loc = InventoryLocalizations(context);
    final provider = context.read<InventoryProvider>();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(loc.sortOptions),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ProductSortOption.values.map((option) {
              return RadioListTile<ProductSortOption>(
                title: Text(_getSortOptionText(option, loc)),
                value: option,
                groupValue: provider.sortOption,
                onChanged: (value) {
                  provider.setSortOption(value!);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _getSortOptionText(ProductSortOption option, InventoryLocalizations loc) {
    switch (option) {
      case ProductSortOption.nameAsc:
        return loc.sortNameAsc;
      case ProductSortOption.nameDesc:
        return loc.sortNameDesc;
      case ProductSortOption.priceAsc:
        return loc.sortPriceAsc;
      case ProductSortOption.priceDesc:
        return loc.sortPriceDesc;
      case ProductSortOption.stockAsc:
        return loc.sortStockAsc;
      case ProductSortOption.stockDesc:
        return loc.sortStockDesc;
    }
  }
}
