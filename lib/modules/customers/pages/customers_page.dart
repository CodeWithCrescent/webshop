import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webshop/core/constants/app_colors.dart';
import 'package:webshop/core/localization/app_localizations.dart';
import 'package:webshop/core/utils/format_utils.dart';
import 'package:webshop/modules/customers/models/customer.dart';
import 'package:webshop/modules/customers/pages/customer_modal.dart';
import 'package:webshop/modules/customers/providers/customer_provider.dart';
import 'package:webshop/shared/widgets/app_bar.dart';
import 'package:webshop/shared/widgets/info_tag.dart';
import 'package:webshop/shared/widgets/search_field.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().fetchCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.watch<CustomerProvider>();

    return Scaffold(
      backgroundColor: AppColors.primary.withOpacity(0.1),
      appBar: WebshopAppBar(
        title: loc?.translate('customers.title') ?? 'Customers',
        onRefresh: () => provider.fetchCustomers(),
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.fetchCustomers(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SearchField(
                hintText: loc?.translate('common.search') ?? 'Search customers',
                onChanged: provider.setSearchQuery,
              ),
            ),
            Expanded(
              child: _buildCustomerList(provider, loc),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerList(CustomerProvider provider, AppLocalizations? loc) {
    if (provider.isLoading && provider.customers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.customers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_alt, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              loc?.translate('customers.empty_title') ?? 'No customers yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              loc?.translate('customers.empty_subtitle') ??
                  'Add your first customer',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: provider.customers.length,
      itemBuilder: (context, index) {
        return _buildCustomerCard(provider.customers[index], loc);
      },
    );
  }

  Widget _buildCustomerCard(Customer customer, AppLocalizations? loc) {
    return Card(
      elevation: 0.5,
      surfaceTintColor: AppColors.cardLight,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showCustomerModal(context, customer: customer),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    customer.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.phone, color: AppColors.primary),
                        onPressed: () => _makePhoneCall(customer.phoneNumber),
                      ),
                      IconButton(
                        icon: SvgPicture.asset('assets/images/whatsapp-icon.svg', width: 32),
                        onPressed: () => _openWhatsApp(customer.phoneNumber),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                customer.phoneNumber,
                style: TextStyle(color: Colors.grey[600]),
              ),
              if (customer.email != null) ...[
                const SizedBox(height: 4),
                Text(
                  customer.email!,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
              if (customer.tinNumber != null || customer.vrn != null) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (customer.tinNumber != null)
                      InfoTag(
                        label: 'TIN: ${customer.tinNumber}',
                        color: AppColors.primary,
                        isSelected: true,
                      ),
                    if (customer.vrn != null)
                      InfoTag(
                        label: 'VRN: ${customer.vrn}',
                        color: AppColors.secondary,
                        isSelected: true,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final normalizedNumber = FormatUtils.normalizePhoneNumber(phoneNumber);
    final url = Uri.parse('https://wa.me/$normalizedNumber');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showCustomerModal(BuildContext context, {Customer? customer}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CustomerModal(
        customer: customer,
        onSuccess: () {
          // Refresh your customer list here
          context.read<CustomerProvider>().getCustomers();
        },
        onDelete: customer != null
            ? () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await context
                      .read<CustomerProvider>()
                      .deleteCustomer(customer.id);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)
                                ?.translate('customers.deleted_success') ??
                            'Customer deleted successfully'),
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
}
