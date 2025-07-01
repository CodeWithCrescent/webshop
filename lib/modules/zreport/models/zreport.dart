import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'zreport.g.dart';

@HiveType(typeId: 7)
class ZReport {
  @HiveField(0)
  final String reportNumber;
  @HiveField(1)
  final DateTime reportDate;
  @HiveField(2)
  final String reportTime;
  @HiveField(3)
  final double subtotal;
  @HiveField(4)
  final double discount;
  @HiveField(5)
  final double total;
  @HiveField(6)
  final double vat;
  @HiveField(7)
  final double totalGross;

  ZReport({
    required this.reportNumber,
    required this.reportDate,
    required this.reportTime,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.vat,
    required this.totalGross,
  });

  String get formattedDate => DateFormat('dd MMM yyyy').format(reportDate);

  factory ZReport.fromMap(Map<String, dynamic> map) {
    return ZReport(
      reportNumber: map['report_number'],
      reportDate: DateTime.parse(map['report_date']),
      reportTime: map['report_time'],
      subtotal: double.parse(map['subtotal'].toString()),
      discount: double.parse(map['discount'].toString()),
      total: double.parse(map['total'].toString()),
      vat: double.parse(map['vat'].toString()),
      totalGross: double.parse(map['total_gross'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'report_number': reportNumber,
      'report_date': reportDate.toIso8601String(),
      'report_time': reportTime,
      'subtotal': subtotal,
      'discount': discount,
      'total': total,
      'vat': vat,
      'total_gross': totalGross,
    };
  }
}