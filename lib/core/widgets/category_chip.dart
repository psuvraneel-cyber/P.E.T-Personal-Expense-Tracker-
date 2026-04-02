import 'package:flutter/material.dart';
import 'package:pet/core/theme/app_theme.dart';
import 'package:pet/core/theme/color_tokens.dart';
import 'package:pet/core/theme/spacing.dart';

/// A compact, pill-shaped category indicator with icon + label.
///
/// Supports a selected state with accent border & tint, and an optional
/// gradient background.
///
/// ```dart
/// CategoryChip(
///   label: 'Food',
///   icon: Icons.restaurant,
///   color: Colors.orange,
///   isSelected: true,
///   onTap: () => selectCategory('food'),
/// )
/// ```
class CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  /// If true, use a gradient tint when selected instead of a flat tint.
  final bool useGradient;

  const CategoryChip({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.isSelected = false,
    this.onTap,
    this.useGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isSelected
        ? color.withAlpha(isDark ? 40 : 28)
        : (isDark ? ColorTokens.darkCard : Colors.white);

    final borderColor = isSelected
        ? color
        : (isDark ? ColorTokens.darkBorder : ColorTokens.lightBorder);

    final labelColor = isSelected
        ? color
        : (isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: useGradient && isSelected ? null : bgColor,
          gradient: useGradient && isSelected
              ? LinearGradient(
                  colors: [
                    color.withAlpha(isDark ? 45 : 30),
                    color.withAlpha(isDark ? 20 : 12),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(Spacing.chipRadius),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? color : labelColor, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
