import 'package:pet/premium/models/tax_category.dart';

class TaxCategoryService {
  TaxCategoryService._();

  static final List<TaxCategory> defaults = [
    TaxCategory(id: 'tax_travel', name: 'Travel'),
    TaxCategory(id: 'tax_office', name: 'Office Supplies'),
    TaxCategory(id: 'tax_meals', name: 'Client Meals'),
    TaxCategory(id: 'tax_software', name: 'Software Subscriptions'),
  ];
}
