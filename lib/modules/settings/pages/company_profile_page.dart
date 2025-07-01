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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyProfileProvider>().fetchCompanyProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.watch<CompanyProfileProvider>();
    final profile = provider.companyProfile;

    return Scaffold(
      appBar: WebshopAppBar(
        title: loc?.translate('settings.company_profile') ?? 'Company Profile',
        onRefresh: () => provider.fetchCompanyProfile(),
      ),
      body: _buildContent(context, provider, profile, loc),
    );
  }

  Widget _buildContent(
    BuildContext context,
    CompanyProfileProvider provider,
    CompanyProfile? profile,
    AppLocalizations? loc,
  ) {
    if (provider.isLoading && profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${provider.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.fetchCompanyProfile(),
              child: Text(loc?.translate('common.retry') ?? 'Retry'),
            ),
          ],
        ),
      );
    }

    if (profile == null) {
      return Center(
        child: Text(loc?.translate('settings.no_company_profile') ?? 'No company profile found'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Company Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.business, size: 48, color: Colors.blue),
                  const SizedBox(height: 16),
                  Text(
                    profile.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile.taxoffice,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Information Section
          _buildInfoSection(context, profile, loc),

          const SizedBox(height: 24),

          // Update Notice
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    loc?.translate('settings.update_at_tra') ?? 
                    'To change this information, please visit your domicile TRA office',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.orange[800],
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    CompanyProfile profile,
    AppLocalizations? loc,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contact Information
        _buildSectionHeader(
          context,
          loc?.translate('settings.contact_info') ?? 'Contact Information',
          Icons.contact_mail,
        ),
        _buildInfoItem(
          context,
          loc?.translate('settings.mobile') ?? 'Mobile',
          profile.mobile,
          Icons.phone,
        ),
        
        // Address
        _buildSectionHeader(
          context,
          loc?.translate('settings.address') ?? 'Address',
          Icons.location_on,
        ),
        if (profile.address1.isNotEmpty)
          _buildInfoItem(
            context,
            loc?.translate('settings.address_line1') ?? 'Address Line 1',
            profile.address1,
            Icons.location_city,
          ),
        if (profile.address2.isNotEmpty)
          _buildInfoItem(
            context,
            loc?.translate('settings.address_line2') ?? 'Address Line 2',
            profile.address2,
            Icons.location_city,
          ),
        if (profile.address3.isNotEmpty)
          _buildInfoItem(
            context,
            loc?.translate('settings.address_line3') ?? 'Address Line 3',
            profile.address3,
            Icons.location_city,
          ),

        // Tax Information
        _buildSectionHeader(
          context,
          loc?.translate('settings.tax_info') ?? 'Tax Information',
          Icons.receipt,
        ),
        _buildInfoItem(
          context,
          loc?.translate('settings.tin') ?? 'TIN',
          profile.tin,
          Icons.numbers,
        ),
        _buildInfoItem(
          context,
          loc?.translate('settings.vrn') ?? 'VRN',
          profile.vrn,
          Icons.confirmation_number,
        ),
        _buildInfoItem(
          context,
          loc?.translate('settings.serial_number') ?? 'Serial Number',
          profile.serial,
          Icons.confirmation_number,
        ),

        // System Information
        _buildSectionHeader(
          context,
          loc?.translate('settings.system_info') ?? 'System Information',
          Icons.computer,
        ),
        _buildInfoItem(
          context,
          loc?.translate('settings.allowed_instances') ?? 'Allowed Instances',
          profile.allowedInstances,
          Icons.lock_outline,
        ),
        _buildInfoItem(
          context,
          loc?.translate('settings.installed_instances') ?? 'Installed Instances',
          profile.installedInstances,
          Icons.install_desktop,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : '-',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}