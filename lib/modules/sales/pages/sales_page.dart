import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:webshop/core/constants/app_colors.dart';
import 'package:webshop/modules/customers/models/customer.dart';
import 'package:webshop/modules/sales/models/product_selection.dart';
import 'package:webshop/modules/sales/models/sale_item.dart';
import 'package:webshop/modules/sales/pages/sale_complete_modal.dart';
import 'package:webshop/modules/sales/providers/sales_provider.dart';
import 'package:webshop/modules/sales/widgets/customer_selection_dialog.dart';
import 'package:webshop/modules/sales/widgets/product_selection_dialog.dart';
import 'package:webshop/shared/widgets/app_bar.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.primary.withOpacity(0.1),
      appBar: WebshopAppBar(
        title: 'Sales',
        onRefresh: () {},
        actions: const [SizedBox()],
      ),
      body: const Column(
        children: [
          _CustomerSection(),
          Expanded(child: _CartItemsList()),
          _TotalsAndCompleteButton(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductSelectionDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  static void _showProductSelectionDialog(BuildContext context) async {
    final saleProviderContext = context.read<SalesProvider>();
    final selectedProduct = await showDialog<ProductSelection>(
      context: context,
      builder: (context) => const ProductSelectionDialog(),
    );

    if (selectedProduct != null) {
      saleProviderContext.addToCart(
        selectedProduct.product,
        quantity: selectedProduct.quantity,
      );
    }
  }

  static Future<void> _showCustomerPhoneModal(BuildContext context) async {
    final provider = context.read<SalesProvider>();
    final phoneController = TextEditingController();
    bool isValid = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Customer Phone Required',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixText: '+255 ',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      isValid = value.length >= 9;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.length < 9) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isValid
                        ? () {
                            provider.selectCustomer(Customer(
                              id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
                              fullName: '',
                              phoneNumber: phoneController.text,
                            ));
                            Navigator.pop(context);
                          }
                        : null,
                    child: const Text('CONTINUE'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CustomerSection extends StatelessWidget {
  const _CustomerSection();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SalesProvider>();

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.person, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: provider.selectedCustomer != null
                  ? Text(
                      provider.selectedCustomer!.fullName,
                      style: Theme.of(context).textTheme.titleMedium,
                    )
                  : const Text('No customer selected'),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _showCustomerSelectionDialog(context),
            ),
            if (provider.selectedCustomer != null)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => provider.selectCustomer(null),
              ),
          ],
        ),
      ),
    );
  }

  void _showCustomerSelectionDialog(BuildContext context) async {
    final saleProviderContext = context.read<SalesProvider>();
    final selectedCustomer = await showDialog<Customer>(
      context: context,
      builder: (context) => const CustomerSelectionDialog(),
    );

    if (selectedCustomer != null) {
      saleProviderContext.selectCustomer(selectedCustomer);
    }
  }
}

class _CartItemsList extends StatelessWidget {
  const _CartItemsList();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SalesProvider>();

    if (provider.cartItems.isEmpty) {
      return const _EmptyCartPlaceholder();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: provider.cartItems.length,
      itemBuilder: (context, index) {
        return _CartItemCard(item: provider.cartItems[index], index: index);
      },
    );
  }
}

class _EmptyCartPlaceholder extends StatelessWidget {
  const _EmptyCartPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add products to start a sale',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final SaleItem item;
  final int index;

  const _CartItemCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SalesProvider>();
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productName, style: theme.textTheme.titleMedium),
                  Text(item.productCode, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => provider.updateCartItemQuantity(
                    index,
                    item.quantity - 1,
                  ),
                ),
                Text(item.quantity.toString()),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => provider.updateCartItemQuantity(
                    index,
                    item.quantity + 1,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.totalAmount.toStringAsFixed(2)} TZS',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => provider.removeFromCart(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalsAndCompleteButton extends StatelessWidget {
  const _TotalsAndCompleteButton();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SalesProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          _TotalRow(label: 'Subtotal', value: provider.subtotal),
          _TotalRow(label: 'Tax', value: provider.taxTotal),
          const Divider(),
          _TotalRow(
            label: 'Total',
            value: provider.grandTotal,
            isBold: true,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: provider.cartItems.isEmpty
                  ? null
                  : () => _showCompleteSaleModal(context),
              child: const Text('COMPLETE SALE'),
            ),
          ),
        ],
      ),
    );
  }

  // Update the _showCompleteSaleModal method in _TotalsAndCompleteButton
  void _showCompleteSaleModal(BuildContext context) async {
    final provider = context.read<SalesProvider>();
    
    // Check if customer is selected
    if (provider.selectedCustomer == null) {
      await SalesPage._showCustomerPhoneModal(context);
      if (provider.selectedCustomer == null) return;
    }

    // Get location automatically
    final location = await _getLocationWithRetry(context);
    if (location == null) {
      if (context.mounted) {
        _showLocationErrorModal(context);
      }
      return;
    }

    // Now show the complete sale modal
    if (context.mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => SaleCompleteModal(location: location),
      );
    }
  }

  // Update the _showLocationErrorModal method
  void _showLocationErrorModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Required'),
        content: const Text(
          'You must allow location access to complete the sale. '
          'Please enable location services in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: const Text('OPEN SETTINGS'),
          ),
        ],
      ),
    );
  }

  Future<Position?> _getLocationWithRetry(BuildContext context) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await Geolocator.openLocationSettings();
        if (!serviceEnabled) return null;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse && 
            permission != LocationPermission.always) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Get current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
    } catch (e) {
      debugPrint('Location error: $e');
      return null;
    }
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isBold;
  final Color? color;

  const _TotalRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
          Text(
            '${value.toStringAsFixed(2)} TZS',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
