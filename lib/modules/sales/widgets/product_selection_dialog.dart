import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webshop/core/constants/app_text_styles.dart';
import 'package:webshop/modules/inventory/models/product.dart';
import 'package:webshop/modules/inventory/providers/inventory_provider.dart';
import 'package:webshop/modules/sales/models/product_selection.dart';

class ProductSelectionDialog extends StatelessWidget {
  const ProductSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Product to Sell'),
      titleTextStyle: AppTextStyles.titleLarge,
      content: const _ProductSelectionContent(),
      scrollable: true,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _ProductSelectionContent extends StatefulWidget {
  const _ProductSelectionContent();

  @override
  State<_ProductSelectionContent> createState() => _ProductSelectionContentState();
}

class _ProductSelectionContentState extends State<_ProductSelectionContent> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '1');
  Product? _selectedProduct;

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = context.watch<InventoryProvider>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: 'Search product',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => inventoryProvider.setSearchQuery(value),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          width: 300,
          child: _buildProductList(inventoryProvider),
        ),
        const SizedBox(height: 16),
        if (_selectedProduct != null) _buildQuantitySelector(),
        const SizedBox(height: 16),
        if (_selectedProduct != null) _buildAddButton(),
      ],
    );
  }

  Widget _buildProductList(InventoryProvider inventoryProvider) {
    if (inventoryProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (inventoryProvider.products.isEmpty) {
      return const Center(child: Text('No products found'));
    }

    return ListView.builder(
      itemCount: inventoryProvider.products.length,
      itemBuilder: (context, index) {
        final product = inventoryProvider.products[index];
        return ListTile(
          title: Text(product.name),
          subtitle: Text('${product.code} • ${product.price.toStringAsFixed(2)} TZS'),
          trailing: Text(product.category ?? ""),
          selected: _selectedProduct?.id == product.id,
          onTap: () => setState(() => _selectedProduct = product),
        );
      },
    );
  }

  Widget _buildQuantitySelector() {
    return TextField(
      controller: _quantityController,
      decoration: const InputDecoration(
        labelText: 'Quantity',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildAddButton() {
    final quantity = int.tryParse(_quantityController.text) ?? 1;
    final isValid = quantity > 0;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isValid
            ? () {
                Navigator.pop(
                  context,
                  ProductSelection(
                    product: _selectedProduct!,
                    quantity: quantity,
                  ),
                );
              }
            : null,
        child: const Text('Add to Sale'),
      ),
    );
  }
}