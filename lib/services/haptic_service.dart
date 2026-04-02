import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralised haptic feedback service.
///
/// Reads `hapticEnabled` from SharedPreferences (default: `true`).
/// All haptic methods are no-ops when disabled.
class HapticService {
  HapticService._();
  static final HapticService _instance = HapticService._();
  static HapticService get instance => _instance;

  bool _enabled = true;
  bool _loaded = false;

  /// Load preference once (subsequent calls are no-ops).
  Future<void> init() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      _enabled = prefs.getBool('hapticEnabled') ?? true;
    } catch (_) {}
  }

  bool get isEnabled => _enabled;

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hapticEnabled', value);
    } catch (_) {}
  }

  // ── Feedback Methods ───────────────────────────────────────────────

  /// Subtle tap — for selections, toggles, tab switches.
  void lightTap() {
    if (!_enabled) return;
    HapticFeedback.lightImpact();
  }

  /// Medium impact — for saving, confirming actions.
  void mediumTap() {
    if (!_enabled) return;
    HapticFeedback.mediumImpact();
  }

  /// Heavy impact — for delete, destructive actions.
  void heavyTap() {
    if (!_enabled) return;
    HapticFeedback.heavyImpact();
  }

  /// Selection tick — for list reorder, picker scroll.
  void selectionTick() {
    if (!_enabled) return;
    HapticFeedback.selectionClick();
  }

  /// Success vibration pattern — for goal reached, budget under limit.
  void success() {
    if (!_enabled) return;
    HapticFeedback.mediumImpact();
  }

  /// Warning vibration — for budget exceeded, anomaly detected.
  void warning() {
    if (!_enabled) return;
    HapticFeedback.heavyImpact();
  }
}
