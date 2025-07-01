import 'package:flutter/material.dart';
import 'package:webshop/core/localization/app_localizations.dart';

class ZReportLocalizations {
  final BuildContext context;

  ZReportLocalizations(this.context);

  String get title => _translate('zreport.title');
  String get filterAll => _translate('zreport.filter_all');
  String get filterToday => _translate('zreport.filter_today');
  String get filterLastMonth => _translate('zreport.filter_last_month');
  String get filterDate => _translate('zreport.filter_date');
  String get filterDateRange => _translate('zreport.filter_date_range');
  String get sortNewest => _translate('zreport.sort_newest');
  String get sortOldest => _translate('zreport.sort_oldest');
  String get sortHighest => _translate('zreport.sort_highest');
  String get sortLowest => _translate('zreport.sort_lowest');

  String _translate(String key) => AppLocalizations.of(context)!.translate(key);
}
