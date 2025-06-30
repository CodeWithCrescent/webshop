import 'package:flutter/material.dart';
import 'package:webshop/core/localization/app_localizations.dart';

class InventoryLocalizations {
  final BuildContext context;

  InventoryLocalizations(this.context);

  String get title => _translate('inventory.title');
  String get searchProducts => _translate('inventory.searchProducts');
  String get allCategories => _translate('inventory.allCategories');
  String get emptyInventoryTitle => _translate('inventory.emptyInventoryTitle');
  String get emptyInventorySubtitle => _translate('inventory.emptyInventorySubtitle');
  String get addFirstProduct => _translate('inventory.addFirstProduct');
  String get inStock => _translate('inventory.inStock');
  String get sortOptions => _translate('inventory.sortOptions');
  String get sortNameAsc => _translate('inventory.sortNameAsc');
  String get sortNameDesc => _translate('inventory.sortNameDesc');
  String get sortPriceAsc => _translate('inventory.sortPriceAsc');
  String get sortPriceDesc => _translate('inventory.sortPriceDesc');
  String get sortStockAsc => _translate('inventory.sortStockAsc');
  String get sortStockDesc => _translate('inventory.sortStockDesc');
  String get addProduct => _translate('inventory.addProduct');
  String get editProduct => _translate('inventory.editProduct');
  String get productCode => _translate('inventory.productCode');
  String get productName => _translate('inventory.productName');
  String get category => _translate('inventory.category');
  String get selectCategory => _translate('inventory.selectCategory');
  String get addNewCategory => _translate('inventory.addNewCategory');
  String get editCategory => _translate('inventory.editCategory');
  String get price => _translate('inventory.price');
  String get taxCategory => _translate('inventory.taxCategory');
  String get taxStandard => _translate('inventory.taxStandard');
  String get taxSpecialRate => _translate('inventory.taxSpecialRate');
  String get taxZeroRated => _translate('inventory.taxZeroRated');
  String get taxSpecialRelief => _translate('inventory.taxSpecialRelief');
  String get taxExempted => _translate('inventory.taxExempted');
  String get stock => _translate('inventory.stock');
  String get save => _translate('common.save');
  String get update => _translate('common.update');
  String get cancel => _translate('common.cancel');
  String get add => _translate('common.add');
  String get delete => _translate('common.delete');
  String get edit => _translate('common.add');
  String get categoryName => _translate('inventory.categoryName');
  String get validationRequired => _translate('inventory.validation.required');
  String get validationInvalidPrice => _translate('inventory.validation.invalidPrice');
  String get validationInvalidStock => _translate('inventory.validation.invalidStock');

  String _translate(String key) {
    return AppLocalizations.of(context)!.translate(key);
  }
}