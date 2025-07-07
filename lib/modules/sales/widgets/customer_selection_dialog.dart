import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webshop/modules/customers/providers/customer_provider.dart';

class CustomerSelectionDialog extends StatefulWidget {
  const CustomerSelectionDialog({super.key});

  @override
  State<CustomerSelectionDialog> createState() => _CustomerSelectionDialogState();
}

class _CustomerSelectionDialogState extends State<CustomerSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().fetchCustomers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = context.watch<CustomerProvider>();

    return AlertDialog(
      title: const Text('Select Customer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search customers',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => customerProvider.setSearchQuery(value),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            width: 400,
            child: customerProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : customerProvider.customers.isEmpty
                    ? const Center(child: Text('No customers found'))
                    : ListView.builder(
                        itemCount: customerProvider.customers.length,
                        itemBuilder: (context, index) {
                          final customer = customerProvider.customers[index];
                          return ListTile(
                            title: Text(customer.fullName),
                            subtitle: Text(customer.phoneNumber),
                            onTap: () => Navigator.pop(context, customer),
                          );
                        },
                      ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}