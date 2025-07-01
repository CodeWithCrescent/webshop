import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:webshop/core/localization/app_localizations.dart';
import 'package:webshop/modules/customers/models/customer.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/modal_header.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../providers/customer_provider.dart';

class CustomerModal extends StatefulWidget {
  final Customer? customer;
  final Function()? onSuccess;
  final VoidCallback? onDelete;

  const CustomerModal({
    super.key,
    this.customer,
    this.onSuccess,
    this.onDelete,
  });

  @override
  State<CustomerModal> createState() => _CustomerModalState();
}

class _CustomerModalState extends State<CustomerModal> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _tinController;
  late final TextEditingController _vrnController;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.fullName ?? '');
    _phoneController = TextEditingController(text: widget.customer?.phoneNumber ?? '');
    _emailController = TextEditingController(text: widget.customer?.email ?? '');
    _tinController = TextEditingController(text: widget.customer?.tinNumber ?? '');
    _vrnController = TextEditingController(text: widget.customer?.vrn ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _tinController.dispose();
    _vrnController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    
    try {
      final provider = context.read<CustomerProvider>();
      final customer = Customer(
        id: widget.customer?.id,
        fullName: _nameController.text,
        phoneNumber: _phoneController.text,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        tinNumber: _tinController.text.isNotEmpty ? _tinController.text : null,
        vrn: _vrnController.text.isNotEmpty ? _vrnController.text : null,
      );

      if (widget.customer == null) {
        await provider.addCustomer(customer);
      } else {
        await provider.updateCustomer(customer);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.customer == null
                ? AppLocalizations.of(context)?.translate('customers.added_success') ?? 'Customer added successfully'
                : AppLocalizations.of(context)?.translate('customers.updated_success') ?? 'Customer updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context);
        widget.onSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final loc = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ModalHeader(
                title: widget.customer == null 
                    ? loc?.translate('customers.add_customer') ?? 'Add Customer'
                    : loc?.translate('customers.edit_customer') ?? 'Edit Customer',
                onClose: () => Navigator.pop(context),
                actions: widget.customer != null
                    ? [
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: theme.colorScheme.error,
                          onPressed: widget.onDelete,
                        ),
                      ]
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: loc?.translate('customers.full_name') ?? 'Full Name',
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return loc?.translate('validation.required') ?? 'Required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: loc?.translate('customers.phone') ?? 'Phone Number',
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return loc?.translate('validation.required') ?? 'Required';
                        }
                        if (value.length < 9) {
                          return loc?.translate('validation.invalid_phone') ?? 'Invalid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: '${loc?.translate('customers.email') ?? 'Email'} (${loc?.translate('common.optional') ?? 'optional'})',
                        prefixIcon: const Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tinController,
                      decoration: InputDecoration(
                        labelText: '${loc?.translate('customers.tin') ?? 'TIN Number'} (${loc?.translate('common.optional') ?? 'optional'})',
                        prefixIcon: const Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _vrnController,
                      decoration: InputDecoration(
                        labelText: '${loc?.translate('customers.vrn') ?? 'VRN'} (${loc?.translate('common.optional') ?? 'optional'})',
                        prefixIcon: const Icon(Icons.numbers),
                      ),
                    ),
                    const SizedBox(height: 32),
                    GradientButton(
                      onPressed: _isSaving ? null : _handleSave,
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(widget.customer == null 
                              ? loc?.translate('common.save') ?? 'Save'
                              : loc?.translate('common.update') ?? 'Update'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}