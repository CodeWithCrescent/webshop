import 'package:hive/hive.dart';
import '../../models/business_profile.dart';

class BusinessProfileLocalDataSource {
  final Box<BusinessProfile> businessProfileBox;

  BusinessProfileLocalDataSource({required this.businessProfileBox});

  Future<BusinessProfile?> getBusinessProfile() async {
    if (businessProfileBox.isEmpty) return null;
    return businessProfileBox.getAt(0); // Store only one profile
  }

  Future<void> saveBusinessProfile(BusinessProfile profile) async {
    await businessProfileBox.clear(); // Clear existing data
    await businessProfileBox.add(profile); // Add new profile
  }

  Future<void> deleteBusinessProfile() async {
    await businessProfileBox.clear();
  }
}