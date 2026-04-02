import 'package:flutter/material.dart';

/// Wraps a widget with accessibility semantics for screen readers.
///
/// Use this to add [Semantics] labels to interactive elements that don't
/// natively provide them (e.g. [GestureDetector], custom painted widgets).
///
/// ```dart
/// SemanticTap(
///   label: 'Navigate to Home tab',
///   hint: 'Double tap to switch',
///   onTap: () => switchTab(0),
///   child: _buildTabIcon(),
/// )
/// ```
class SemanticTap extends StatelessWidget {
  final String label;
  final String? hint;
  final VoidCallback? onTap;
  final Widget child;
  final bool isButton;

  const SemanticTap({
    super.key,
    required this.label,
    this.hint,
    this.onTap,
    required this.child,
    this.isButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      button: isButton && onTap != null,
      onTap: onTap,
      child: child,
    );
  }
}

/// Wraps purely decorative elements so screen readers skip them.
class SemanticExclude extends StatelessWidget {
  final Widget child;

  const SemanticExclude({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(child: child);
  }
}
