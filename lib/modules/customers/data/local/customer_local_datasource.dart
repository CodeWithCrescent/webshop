import 'package:hive/hive.dart';
import '../../models/customer.dart';

class CustomerLocalDataSource {
  final Box<Customer> customerBox;

  CustomerLocalDataSource({required this.customerBox});

  Future<List<Customer>> getCustomers() async {
    return customerBox.values.toList();
  }

  Future<void> addCustomer(Customer customer) async {
    await customerBox.put(customer.id, customer);
  }

  Future<void> updateCustomer(Customer customer) async {
    await customerBox.put(customer.id, customer);
  }

  Future<void> deleteCustomer(String customerId) async {
    await customerBox.delete(customerId);
  }

  Future<void> syncWithApi(List<Customer> customers) async {
    await customerBox.clear();
    for (final customer in customers) {
      await customerBox.put(customer.id, customer);
    }
  }
}