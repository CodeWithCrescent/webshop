import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webshop/core/localization/app_localizations.dart';
import 'package:webshop/modules/settings/models/company_profile.dart';
import 'package:webshop/modules/settings/providers/company_profile_provider.dart';
import 'package:webshop/shared/widgets/app_bar.dart';

class CompanyProfilePage extends StatefulWidget {
  const CompanyProfilePage({super.key});

  @override
  State<CompanyProfilePage> createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _address1Controller;
  late TextEditingController _address2Controller;
  late TextEditingController _address3Controller;
  late TextEditingController _tinController;
  late TextEditingController _vrnController;
  late TextEditingController _serialController;
  late TextEditingController _taxOfficeController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyProfileProvider>().fetchCompanyProfile();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _address3Controller.dispose();
    _tinController.dispose();
    _vrnController.dispose();
    _serialController.dispose();
    _taxOfficeController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    final profile = context.read<CompanyProfileProvider>().companyProfile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _mobileController = TextEditingController(text: profile?.mobile ?? '');
    _address1Controller = TextEditingController(text: profile?.address1 ?? '');
    _address2Controller = TextEditingController(text: profile?.address2 ?? '');
    _address3Controller = TextEditingController(text: profile?.address3 ?? '');
    _tinController = TextEditingController(text: profile?.tin ?? '');
    _vrnController = TextEditingController(text: profile?.vrn ?? '');
    _serialController = TextEditingController(text: profile?.serial ?? '');
    _taxOfficeController = TextEditingController(text: profile?.taxoffice ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.watch<CompanyProfileProvider>();

    if (provider.isLoading && provider.companyProfile == null) {
      return Scaffold(
        appBar: WebshopAppBar(
          title: loc?.translate('settings.company_profile') ?? 'Company Profile', onRefresh: () {  },
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.error != null) {
      return Scaffold(
        appBar: WebshopAppBar(
          title: loc?.translate('settings.company_profile') ?? 'Company Profile', onRefresh: () {  },
        ),
        body: Center(child: Text('Error: ${provider.error}')),
      );
    }

    return Scaffold(
      appBar: WebshopAppBar(
        title: loc?.translate('settings.company_profile') ?? 'Company Profile', onRefresh: () { },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: loc?.translate('settings.company_name') ?? 'Company Name',
                  prefixIcon: const Icon(Icons.business),
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
                controller: _mobileController,
                decoration: InputDecoration(
                  labelText: loc?.translate('settings.mobile') ?? 'Mobile',
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc?.translate('validation.required') ?? 'Required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _address1Controller,
                decoration: InputDecoration(
                  labelText: loc?.translate('settings.address_line1') ?? 'Address Line 1',
                  prefixIcon: const Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _address2Controller,
                decoration: InputDecoration(
                  labelText: loc?.translate('settings.address_line2') ?? 'Address Line 2',
                  prefixIcon: const Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _address3Controller,
                decoration: InputDecoration(
                  labelText: loc?.translate('settings.address_line3') ?? 'Address Line 3',
                  prefixIcon: const Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tinController,
                decoration: InputDecoration(
                  labelText: loc?.translate('settings.tin') ?? 'TIN Number',
                  prefixIcon: const Icon(Icons.numbers),
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
                controller: _vrnController,
                decoration: InputDecoration(
                  labelText: loc?.translate('settings.vrn') ?? 'VRN',
                  prefixIcon: const Icon(Icons.numbers),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _serialController,
                decoration: InputDecoration(
                  labelText: loc?.translate('settings.serial_number') ?? 'Serial Number',
                  prefixIcon: const Icon(Icons.confirmation_number),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _taxOfficeController,
                decoration: InputDecoration(
                  labelText: loc?.translate('settings.tax_office') ?? 'Tax Office',
                  prefixIcon: const Icon(Icons.account_balance),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          final profile = CompanyProfile(
                            name: _nameController.text,
                            allowedInstances: provider.companyProfile?.allowedInstances ?? '1',
                            installedInstances: provider.companyProfile?.installedInstances ?? '1',
                            mobile: _mobileController.text,
                            address1: _address1Controller.text,
                            address2: _address2Controller.text,
                            address3: _address3Controller.text,
                            vin: provider.companyProfile?.vin ?? '',
                            tin: _tinController.text,
                            vrn: _vrnController.text,
                            serial: _serialController.text,
                            taxoffice: _taxOfficeController.text,
                          );
                          await provider.updateCompanyProfile(profile);
                          
                          // Show success message
                          if (context.mounted && provider.error == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Company profile updated successfully')),
                            );
                          }
                        }
                      },
                  child: Text(loc?.translate('common.save') ?? 'Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}