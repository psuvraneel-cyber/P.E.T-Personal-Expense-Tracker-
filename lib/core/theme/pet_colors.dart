import 'package:flutter/material.dart';

/// Redesign color palette for P.E.T — "Money Should Feel Calm" design system.
///
/// These colors complement the existing [ColorTokens] and [AppTheme] without
/// replacing them. Use [PETColors] for the new redesigned components.
class PETColors {
  PETColors._();

  // ─────────────────── Brand ──────────────────────────────────────────────
  static const Color primary = Color(0xFF3D5AFE);
  static const Color primaryLight = Color(0xFF8187FF);
  static const Color primarySurface = Color(0xFFE8EAFF);

  // ─────────────────── Semantic ───────────────────────────────────────────
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFB300);
  static const Color alert = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF607D8B);

  // ─────────────────── Neutrals ──────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF8F9FF);
  static const Color backgroundDark = Color(0xFF0D0F1A);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A1C2E);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider = Color(0xFFE5E7EB);

  // ─────────────────── Hero Gradients ────────────────────────────────────
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3D5AFE), Color(0xFF7C4DFF)],
  );

  static const LinearGradient heroGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1C3E), Color(0xFF2D1B69)],
  );

  /// Morning: blue → indigo
  static const LinearGradient morningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3D5AFE), Color(0xFF5C6BC0)],
  );

  /// Afternoon: teal → blue
  static const LinearGradient afternoonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00897B), Color(0xFF3D5AFE)],
  );

  /// Evening: purple → deep blue
  static const LinearGradient eveningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C4DFF), Color(0xFF1A237E)],
  );

  // ─────────────────── Budget Ring Colors ────────────────────────────────

  /// Returns the appropriate color for a budget usage ring.
  ///
  /// - Under 60%: [success] (calm green)
  /// - 60–85%: [warning] (amber)
  /// - 85–100%: orange
  /// - Over 100%: [alert] (red)
  static Color budgetRingColor(double percentUsed) {
    if (percentUsed < 0.60) return success;
    if (percentUsed < 0.85) return warning;
    if (percentUsed < 1.0) return const Color(0xFFFF9800);
    return alert;
  }

  /// Returns the hero gradient based on time of day.
  static LinearGradient timeBasedGradient({required bool isDark}) {
    if (isDark) return heroGradientDark;
    final hour = DateTime.now().hour;
    if (hour < 12) return morningGradient;
    if (hour < 17) return afternoonGradient;
    return eveningGradient;
  }

  // ─────────────────── Metric Pill Backgrounds ───────────────────────────
  static Color spentPillBg(bool isDark) =>
      isDark ? const Color(0xFF1E2035) : const Color(0xFFF1F5F9);

  static Color budgetPillBg(bool isDark) =>
      isDark ? const Color(0xFF0D2818) : const Color(0xFFE8F5E9);

  static Color scorePillBg(bool isDark) =>
      isDark ? const Color(0xFF2D1B15) : const Color(0xFFFFF8E1);
}
