import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:webshop/core/constants/app_colors.dart';
import 'package:webshop/shared/widgets/app_bar.dart';
import 'package:webshop/shared/widgets/search_field.dart';
import 'package:webshop/modules/inventory/providers/inventory_provider.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.primary.withOpacity(0.1),
      appBar: WebshopAppBar(
        title: "Customers",
        onRefresh: () => context.read<InventoryProvider>().init(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SearchField(
                    hintText: "Search...",
                    onChanged: (value) {},
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
