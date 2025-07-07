import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:webshop/modules/sales/providers/sales_provider.dart';

class SaleCompleteModal extends StatefulWidget {
  const SaleCompleteModal({super.key});

  @override
  State<SaleCompleteModal> createState() => _SaleCompleteModalState();
}

class _SaleCompleteModalState extends State<SaleCompleteModal> {
  String _paymentType = 'CASH';
  bool _isGettingLocation = false;
  String? _locationError;

  final List<String> _paymentTypes = [
    'CASH',
    'INVOICE',
    'CHEQUE',
    'CCARD',
    'EMONEY',
  ];

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
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Record Location'),
              subtitle: _locationError != null
                  ? Text(
                      _locationError!,
                      style: const TextStyle(color: Colors.red),
                    )
                  : provider.latitude != null
                      ? Text(
                          'Lat: ${provider.latitude!.toStringAsFixed(4)}, '
                          'Lng: ${provider.longitude!.toStringAsFixed(4)}',
                        )
                      : const Text('Location not recorded'),
              trailing: _isGettingLocation
                  ? const CircularProgressIndicator()
                  : IconButton(
                      icon: const Icon(Icons.gps_fixed),
                      onPressed: _getCurrentLocation,
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

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
      _locationError = null;
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      context.read<SalesProvider>().setLocation(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      setState(() => _locationError = 'Failed to get location: $e');
    } finally {
      setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _completeSale(SalesProvider provider) async {
    try {
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
            content: Text('Error completing sale: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}