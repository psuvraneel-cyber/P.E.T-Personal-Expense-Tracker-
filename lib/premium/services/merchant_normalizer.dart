class MerchantNormalizer {
  MerchantNormalizer._();

  static final Map<RegExp, String> _rules = {
    RegExp(r'\bamazon\b', caseSensitive: false): 'Amazon',
    RegExp(r'\bflipkart\b', caseSensitive: false): 'Flipkart',
    RegExp(r'\bnetflix\b', caseSensitive: false): 'Netflix',
    RegExp(r'\bspotify\b', caseSensitive: false): 'Spotify',
    RegExp(r'\bphonepe\b', caseSensitive: false): 'PhonePe',
    RegExp(r'\bgpay\b|\bgoogle pay\b', caseSensitive: false): 'Google Pay',
    RegExp(r'\bpaytm\b', caseSensitive: false): 'Paytm',
    RegExp(r'\bswiggy\b', caseSensitive: false): 'Swiggy',
    RegExp(r'\bzomato\b', caseSensitive: false): 'Zomato',
    RegExp(r'\buber\b', caseSensitive: false): 'Uber',
    RegExp(r'\bolacabs\b|\bola\b', caseSensitive: false): 'Ola',
    RegExp(r'\bairtel\b', caseSensitive: false): 'Airtel',
    RegExp(r'\bjio\b', caseSensitive: false): 'Jio',
    RegExp(r'\bact fibernet\b|\bact\b', caseSensitive: false): 'ACT Fibernet',
  };

  static String normalize(String merchant) {
    final cleaned = merchant.trim();
    if (cleaned.isEmpty) return 'Unknown';

    for (final entry in _rules.entries) {
      if (entry.key.hasMatch(cleaned)) return entry.value;
    }

    if (cleaned.length <= 3) return cleaned.toUpperCase();
    return cleaned[0].toUpperCase() + cleaned.substring(1).toLowerCase();
  }
}
