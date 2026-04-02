import 'package:pet/data/models/category.dart';

class CategoryInferenceService {
  CategoryInferenceService._();

  static final Map<RegExp, String> _categoryHints = {
    RegExp(r'\buber\b|\bola\b|\brapido\b', caseSensitive: false): 'Transport',
    RegExp(r'\bswiggy\b|\bzomato\b|\bfood\b', caseSensitive: false): 'Food',
    RegExp(r'\bamazon\b|\bflipkart\b|\bshopping\b', caseSensitive: false):
        'Shopping',
    RegExp(r'\bnetflix\b|\bspotify\b|\bprime\b', caseSensitive: false):
        'Entertainment',
    RegExp(r'\bairtel\b|\bjio\b|\bvi\b|\bmobile\b', caseSensitive: false):
        'Bills',
    RegExp(r'\belectricity\b|\bwater\b|\bgas\b', caseSensitive: false):
        'Utilities',
    RegExp(r'\bpharmacy\b|\bmedical\b|\bhospital\b', caseSensitive: false):
        'Health',
  };

  static String inferCategoryId({
    required String merchant,
    required List<Category> categories,
  }) {
    for (final entry in _categoryHints.entries) {
      if (entry.key.hasMatch(merchant)) {
        final match = categories.firstWhere(
          (c) => c.name.toLowerCase() == entry.value.toLowerCase(),
          orElse: () => categories.first,
        );
        return match.id;
      }
    }

    if (categories.isEmpty) return 'cat_uncategorized';

    final fallback = categories.firstWhere(
      (c) => c.name.toLowerCase() == 'uncategorized',
      orElse: () => categories.first,
    );

    return fallback.id;
  }
}
