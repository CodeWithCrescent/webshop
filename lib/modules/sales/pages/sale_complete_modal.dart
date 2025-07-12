import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:webshop/modules/sales/providers/sales_provider.dart';
import 'package:webshop/shared/utils/auth_utils.dart';

class SaleCompleteModal extends StatefulWidget {
  final Position location;
  
  const SaleCompleteModal({
    super.key,
    required this.location,
  });

  @override
  State<SaleCompleteModal> createState() => _SaleCompleteModalState();
}

class _SaleCompleteModalState extends State<SaleCompleteModal> {
  String _paymentType = 'CASH';
  bool _isResolvingAddress = true;
  String? _address;
  String? _addressError;

  final List<String> _paymentTypes = [
    'CASH',
    'INVOICE',
    'CHEQUE',
    'CCARD',
    'EMONEY',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAndRedirectAuth(context);
    });
    _resolveAddress();
  }

  Future<void> _resolveAddress() async {
    try {
      final placemarks = await placemarkFromCoordinates(
        widget.location.latitude,
        widget.location.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _address = [
            if (place.street != null) place.street,
            if (place.subLocality != null) place.subLocality,
            if (place.locality != null) place.locality,
          ].where((part) => part != null && part.isNotEmpty).join(', ');
        });
      }
    } catch (e) {
      setState(() {
        _addressError = 'Could not determine exact address';
      });
    } finally {
      setState(() => _isResolvingAddress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SalesProvider>();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Complete Sale',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildLocationSection(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonFormField<String>(
                value: _paymentType,
                items: _paymentTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _paymentType = value!),
                decoration: const InputDecoration(
                  labelText: 'Payment Type',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.isLoading
                      ? null
                      : () => _completeSale(provider),
                  child: provider.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('CONFIRM SALE'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return ListTile(
      leading: const Icon(Icons.location_on),
      title: const Text('Sale Location'),
      subtitle: _isResolvingAddress
          ? const Row(
              children: [
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator()),
                SizedBox(width: 8),
                Text('Resolving address...'),
              ],
            )
          : Text(
              _address ?? _addressError ?? 'Location recorded',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
    );
  }

  Future<void> _completeSale(SalesProvider provider) async {
    try {
      // Set the location in provider
      provider.setLocation(
        widget.location.latitude,
        widget.location.longitude,
      );
      
      await provider.completeSale(_paymentType);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sale completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing sale: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}