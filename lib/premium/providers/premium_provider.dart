import 'package:flutter/material.dart';
import 'package:pet/premium/services/premium_entitlement_service.dart';

class PremiumProvider extends ChangeNotifier {
  bool _isPremium = false;
  bool _experimentalEnabled = false;
  bool _isLoading = true;

  bool get isPremium => _isPremium;
  bool get experimentalEnabled => _experimentalEnabled;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _isPremium = await PremiumEntitlementService.isPremiumEnabled();
    _experimentalEnabled =
        await PremiumEntitlementService.isExperimentalEnabled();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setPremium(bool enabled) async {
    await PremiumEntitlementService.setPremiumEnabled(enabled);
    _isPremium = enabled;
    notifyListeners();
  }

  Future<void> setExperimental(bool enabled) async {
    await PremiumEntitlementService.setExperimentalEnabled(enabled);
    _experimentalEnabled = enabled;
    notifyListeners();
  }
}
