import 'package:flutter/material.dart';

Future<DateTimeRange?> showCustomDateRangePicker({
  required BuildContext context,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTimeRange? initialDateRange,
}) async {
  final picked = await showCustomDateRangePicker(
    context: context,
    firstDate: firstDate,
    lastDate: lastDate,
    initialDateRange: initialDateRange,
  );
  return picked;
}