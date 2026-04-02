import 'package:shared_preferences/shared_preferences.dart';

class PremiumEntitlementService {
  PremiumEntitlementService._();

  static const String _kPremiumEnabled = 'pet_premium_enabled';
  static const String _kExperimentalEnabled = 'pet_experimental_enabled';

  static Future<bool> isPremiumEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kPremiumEnabled) ?? false;
  }

  static Future<void> setPremiumEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPremiumEnabled, enabled);
  }

  static Future<bool> isExperimentalEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kExperimentalEnabled) ?? false;
  }

  static Future<void> setExperimentalEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kExperimentalEnabled, enabled);
  }
}
