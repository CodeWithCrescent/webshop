import 'package:flutter/material.dart';
import 'package:webshop/core/localization/app_localizations.dart';

class SettingsLocalizations {
  final BuildContext context;

  SettingsLocalizations(this.context);

  String get companyProfile => _translate('settings.company_profile');
  String get companyName => _translate('settings.company_name');
  String get mobile => _translate('settings.mobile');
  String get addressLine1 => _translate('settings.address_line1');
  String get addressLine2 => _translate('settings.address_line2');
  String get addressLine3 => _translate('settings.address_line3');
  String get tin => _translate('settings.tin');
  String get vrn => _translate('settings.vrn');
  String get serialNumber => _translate('settings.serial_number');
  String get taxOffice => _translate('settings.tax_office');

  String _translate(String key) => AppLocalizations.of(context)!.translate(key);
}
