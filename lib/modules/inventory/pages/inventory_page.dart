import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:webshop/core/constants/app_colors.dart';
import 'package:webshop/core/localization/inventory_localizations.dart';
import 'package:webshop/modules/inventory/models/category.dart';
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
      body: RefreshIndicator(
        onRefresh: () => context.read<InventoryProvider>().init(),
        child: Consumer<InventoryProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.products.isEmpty) {
              return const Center(
                  child: SpinKitCircle(color: AppColors.primary));
            }

            if (provider.error != null) {
              return Center(child: Text('Error: ${provider.error}'));
            }

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
                        onPressed: () => _showFilterDialog(context, provider),
                      ),
                    ],
                  ),
                ),
                _buildCategoryChips(provider, loc),
                Expanded(child: _buildProductList(provider, loc)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryChips(
      InventoryProvider provider, InventoryLocalizations loc) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: provider.categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(loc.allCategories),
                selected: provider.selectedCategory == null,
                onSelected: (_) => provider.setCategoryFilter(null),
                backgroundColor: AppColors.cardLight,
                selectedColor: AppColors.primary.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: provider.selectedCategory == null
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: provider.selectedCategory == null
                        ? AppColors.primary
                        : Colors.grey[300]!,
                  ),
                ),
              ),
            );
          }

          final category = provider.categories[index - 1];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onLongPress: () =>
                  _showCategoryOptions(context, category, provider),
              child: ChoiceChip(
                label: Text(category.name),
                selected: provider.selectedCategory == category.name,
                onSelected: (_) => provider.setCategoryFilter(category.name),
                backgroundColor: AppColors.cardLight,
                selectedColor: AppColors.primary.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: provider.selectedCategory == category.name
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: provider.selectedCategory == category.name
                        ? AppColors.primary
                        : Colors.grey[300]!,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCategoryOptions(
      BuildContext context, Category category, InventoryProvider provider) {
    final loc = InventoryLocalizations(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditCategoryDialog(context, category, provider);
            },
            child: Text(loc.edit),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.deleteCategory(category.id);
            },
            child: Text(loc.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(
      BuildContext context, Category category, InventoryProvider provider) {
    final loc = InventoryLocalizations(context);
    final controller = TextEditingController(text: category.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.editCategory),
        content: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: loc.categoryName,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final navigator = Navigator.of(context);
                final updated = Category(
                  id: category.id,
                  name: controller.text,
                  createdAt: category.createdAt,
                );
                await provider.updateCategory(updated);
                navigator.pop();
              }
            },
            child: Text(loc.save),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(
      InventoryProvider provider, InventoryLocalizations loc) {
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
              onPressed: () => _showProductModal(context),
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
        return _buildProductCard(provider.products[index], loc);
      },
    );
  }

  Widget _buildProductCard(Product product, InventoryLocalizations loc) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showProductModal(context, product: product),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.cardColor,
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
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(product.code,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.6))),
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

  void _showProductModal(BuildContext context, {Product? product}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ProductModal(
        product: product,
        onSuccess: () {
          // Refresh product list
          context.read<InventoryProvider>().loadProducts();
        },
        onDelete: product != null
            ? () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await context
                      .read<InventoryProvider>()
                      .deleteProduct(product.id);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            InventoryLocalizations(context).deletedSuccess),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            : null,
      ),
    );
  }

  // void _showProductModal(BuildContext context, Product? product) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) {
  //       return ProductModal(
  //         product: product,
  //         onSave: (productData) async {
  //           final provider = context.read<InventoryProvider>();
  //           if (product == null) {
  //             await provider.addProduct(productData);
  //           } else {
  //             await provider.updateProduct(productData);
  //           }
  //           if (context.mounted) Navigator.pop(context);
  //         },
  //         onDelete: product != null
  //             ? () async {
  //                 await context.read<InventoryProvider>().deleteProduct(product.id);
  //                 if (context.mounted) Navigator.pop(context);
  //               }
  //             : null,
  //       );
  //     },
  //   );
  // }

  void _showFilterDialog(BuildContext context, InventoryProvider provider) {
    final loc = InventoryLocalizations(context);

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

  String _getSortOptionText(
      ProductSortOption option, InventoryLocalizations loc) {
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
