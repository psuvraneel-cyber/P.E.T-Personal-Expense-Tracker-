/// Consistent spacing constants for the P.E.T design system.
///
/// Based on a 4-px base grid, matching the gradient UI/UX asset guidelines
/// (generous whitespace, rounded cards, breathable layouts).
abstract final class Spacing {
  // ─────────────────── Base grid (4 px) ──────────────────────────────────
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;
  static const double massive = 64;

  // ─────────────────── Semantic aliases ──────────────────────────────────
  /// Default horizontal padding for screens.
  static const double screenH = lg;

  /// Default vertical padding at top of screen (below safe-area).
  static const double screenTop = md;

  /// Gap between cards / sections.
  static const double sectionGap = xl;

  /// Inner padding of a card.
  static const double cardPadding = 18;

  /// Inner padding of a compact card.
  static const double cardPaddingCompact = 14;

  /// Gap between items inside a card.
  static const double cardItemGap = md;

  /// Border radius for cards.
  static const double cardRadius = 20;

  /// Border radius for small elements (chips, pills, icons).
  static const double chipRadius = 12;

  /// Border radius for inputs / buttons.
  static const double inputRadius = 14;

  /// Border radius for bottom sheets.
  static const double sheetRadius = 24;

  /// Bottom padding to clear the floating nav-bar.
  static const double navBarClearance = 80;
}
