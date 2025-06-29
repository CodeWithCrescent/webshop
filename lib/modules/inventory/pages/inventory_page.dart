import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webshop/core/localization/inventory_localizations.dart';
import 'package:webshop/modules/inventory/models/product.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/search_field.dart';
import '../providers/inventory_provider.dart';
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
      Provider.of<InventoryProvider>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = InventoryLocalizations(context);
    final theme = AppTheme.lightTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchField(
              hintText: loc.searchProducts,
              onChanged: (query) =>
                  context.read<InventoryProvider>().setSearchQuery(query),
            ),
          ),
          _buildCategoryChips(),
          Expanded(
            child: _buildProductList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () => _showProductModal(context, null),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final loc = InventoryLocalizations(context);

    return Consumer<InventoryProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                FilterChip(
                  label: Text(loc.allCategories),
                  selected: provider.selectedCategory == null,
                  onSelected: (_) => provider.setCategoryFilter(null),
                ),
                const SizedBox(width: 4),
                ...provider.categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text(category.name),
                      selected: provider.selectedCategory == category.name,
                      onSelected: (_) =>
                          provider.setCategoryFilter(category.name),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductList() {
    final loc = InventoryLocalizations(context);

    return Consumer<InventoryProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  loc.emptyInventoryTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  loc.emptyInventorySubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
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
            final product = provider.products[index];
            return _buildProductCard(context, product);
          },
        );
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final theme = AppTheme.lightTheme;
    final loc = InventoryLocalizations(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                child: Icon(
                  Icons.shopping_bag,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.code,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${product.price.toStringAsFixed(2)} TZS',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.primaryColor,
                    ),
                  ),
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
            if (product == null) {
              await Provider.of<InventoryProvider>(context, listen: false)
                  .addProduct(productData);
            } else {
              await Provider.of<InventoryProvider>(context, listen: false)
                  .updateProduct(productData);
            }
          },
          onDelete: product != null
              ? () async {
                  await Provider.of<InventoryProvider>(context, listen: false)
                      .deleteProduct(product.id);
                  Navigator.pop(context);
                }
              : null,
        );
      },
    );
  }

  void _showFilterDialog(BuildContext context) {
    final loc = InventoryLocalizations(context);
    final provider = Provider.of<InventoryProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
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
