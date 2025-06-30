import 'package:hive/hive.dart';

part 'company_profile.g.dart';

@HiveType(typeId: 6)
class CompanyProfile {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String allowedInstances;
  @HiveField(2)
  final String installedInstances;
  @HiveField(3)
  final String mobile;
  @HiveField(4)
  final String address1;
  @HiveField(5)
  final String address2;
  @HiveField(6)
  final String address3;
  @HiveField(7)
  final String vin;
  @HiveField(8)
  final String tin;
  @HiveField(9)
  final String vrn;
  @HiveField(10)
  final String serial;
  @HiveField(11)
  final String taxoffice;

  CompanyProfile({
    required this.name,
    required this.allowedInstances,
    required this.installedInstances,
    required this.mobile,
    required this.address1,
    required this.address2,
    required this.address3,
    required this.vin,
    required this.tin,
    required this.vrn,
    required this.serial,
    required this.taxoffice,
  });

  factory CompanyProfile.fromMap(Map<String, dynamic> map) {
    return CompanyProfile(
      name: map['name'] ?? '',
      allowedInstances: map['allowed_instances'] ?? '',
      installedInstances: map['installed_instances'] ?? '',
      mobile: map['mobile'] ?? '',
      address1: map['address1'] ?? '',
      address2: map['address2'] ?? '',
      address3: map['address3'] ?? '',
      vin: map['vin'] ?? '',
      tin: map['tin'] ?? '',
      vrn: map['vrn'] ?? '',
      serial: map['serial'] ?? '',
      taxoffice: map['taxoffice'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mobile': mobile,
      'address1': address1,
      'address2': address2,
      'address3': address3,
      'tin': tin,
      'vrn': vrn,
      'serial': serial,
      'taxoffice': taxoffice,
    };
  }
}