import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:webshop/core/constants/app_colors.dart';
import 'package:webshop/core/localization/inventory_localizations.dart';
import 'package:webshop/modules/inventory/models/category.dart';
import 'package:webshop/modules/inventory/models/product.dart';
import 'package:webshop/shared/utils/auth_utils.dart';
import 'package:webshop/shared/widgets/app_bar.dart';
import 'package:webshop/shared/widgets/info_tag.dart';
import 'package:webshop/shared/widgets/refreshable_widget.dart';
import 'package:webshop/shared/widgets/search_field.dart';
import 'package:webshop/modules/inventory/providers/inventory_provider.dart';
import 'package:webshop/modules/inventory/pages/product_modal.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAndRedirectAuth(context);
      context.read<InventoryProvider>().init();
    });

    _scrollController.addListener(() {
      final provider = context.read<InventoryProvider>();
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          provider.hasMore &&
          !provider.isLoading) {
        provider.loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = InventoryLocalizations(context);

    return Scaffold(
      backgroundColor: AppColors.primary.withOpacity(0.1),
      appBar: WebshopAppBar(title: loc.title),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.products.isEmpty) {
            return const Center(child: SpinKitCircle(color: AppColors.primary));
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.init(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
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
              Expanded(
                child: RefreshableWidget(
                  onRefresh: () => provider.init(),
                  builder: (context) => _buildProductList(provider, loc),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryChips(
      InventoryProvider provider, InventoryLocalizations loc) {
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: provider.categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = provider.selectedCategory == null;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InfoTag(
                label: loc.allCategories,
                color: AppColors.primary,
                isSelected: isSelected,
                onTap: () => provider.setCategoryFilter(null),
              ),
            );
          }

          final category = provider.categories[index - 1];
          final isSelected = provider.selectedCategory == category.name;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onLongPress: () =>
                  _showCategoryOptions(context, category, provider),
              child: InfoTag(
                label: category.name,
                color: AppColors.primary,
                isSelected: isSelected,
                onTap: () => provider.setCategoryFilter(category.name),
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
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: provider.products.length + (provider.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.products.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return _buildProductCard(provider.products[index], loc);
      },
    );
  }

  Widget _buildProductCard(Product product, InventoryLocalizations loc) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 10),
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
                    Row(
                      children: [
                        Text(product.code,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6))),
                        Text(
                          " • ",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          product.category ?? "Uncategorized",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
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
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            : null,
      ),
    );
  }

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
