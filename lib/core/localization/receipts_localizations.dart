import 'package:flutter/material.dart';
import 'package:webshop/core/localization/app_localizations.dart';

class ReceiptsLocalizations {
  final BuildContext context;

  ReceiptsLocalizations(this.context);

  String get title => _translate('receipts.title');
  String get receiptDetails => _translate('receipts.receipt_details');
  String get noReceiptFound => _translate('receipts.no_receipt_found');
  String get print => _translate('receipts.print');
  String get share => _translate('receipts.share');
  String get items => _translate('receipts.items');
  String get filterAll => _translate('receipts.filter_all');
  String get filterToday => _translate('receipts.filter_today');
  String get filterThisWeek => _translate('receipts.filter_this_week');
  String get filterLastMonth => _translate('receipts.filter_last_month');
  String get filterDate => _translate('receipts.filter_date');
  String get filterDateRange => _translate('receipts.filter_date_range');

  String _translate(String key) => AppLocalizations.of(context)!.translate(key);
}
