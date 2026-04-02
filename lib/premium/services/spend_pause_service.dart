import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pet/premium/models/spend_pause.dart';

class SpendPauseService {
  SpendPauseService._();

  static const String _kPauseEnabled = 'pet_spend_pause_enabled';
  static const String _kPauseUntil = 'pet_spend_pause_until';
  static const String _kPauseCategories = 'pet_spend_pause_categories';

  static Future<SpendPause> getState() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_kPauseEnabled) ?? false;
    final untilRaw = prefs.getString(_kPauseUntil);
    final until = untilRaw != null ? DateTime.tryParse(untilRaw) : null;
    final catsRaw = prefs.getString(_kPauseCategories);
    final categories = catsRaw != null
        ? List<String>.from(jsonDecode(catsRaw) as List)
        : <String>[];

    final pause = SpendPause(
      enabled: enabled,
      until: until,
      blockedCategories: categories,
    );

    // Auto-expire: if the pause time has passed, clear it and return disabled.
    if (enabled && until != null && DateTime.now().isAfter(until)) {
      await setState(SpendPause(enabled: false));
      return SpendPause(enabled: false);
    }

    return pause;
  }

  static Future<void> setState(SpendPause pause) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPauseEnabled, pause.enabled);

    if (pause.until != null) {
      await prefs.setString(_kPauseUntil, pause.until!.toIso8601String());
    } else {
      await prefs.remove(_kPauseUntil);
    }

    if (pause.blockedCategories.isNotEmpty) {
      await prefs.setString(
        _kPauseCategories,
        jsonEncode(pause.blockedCategories),
      );
    } else {
      await prefs.remove(_kPauseCategories);
    }
  }
}
