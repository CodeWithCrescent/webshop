import 'package:flutter/material.dart';
import 'package:webshop/core/localization/app_localizations.dart';

class CommonLocalizations {
  final BuildContext context;

  CommonLocalizations(this.context);

  String get save => _translate('common.save');
  String get update => _translate('common.update');
  String get cancel => _translate('common.cancel');
  String get add => _translate('common.add');
  String get edit => _translate('common.edit');
  String get delete => _translate('common.delete');
  String get logout => _translate('common.logout');
  String get logoutSuccess => _translate('common.logout_success');
  String get companyProfile => _translate('common.company_profile');
  String get unexpectedError => _translate('common.unexpected_error');
  String get addSuccess => _translate('common.addSuccess');
  String get updateSuccess => _translate('common.updateSuccess');
  String get deletedSuccess => _translate('common.deletedSuccess');

  String _translate(String key) => AppLocalizations.of(context)!.translate(key);
}
