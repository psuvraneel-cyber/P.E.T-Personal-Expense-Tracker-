import 'package:flutter/material.dart';
import 'package:pet/core/theme/color_tokens.dart';

/// A full-screen animated gradient background inspired by the
/// gradient-colored UI/UX background asset pack.
///
/// Wraps its [child] in a gradient [Container] with optional animated
/// shimmer effect for visual polish.
///
/// ```dart
/// GradientBackground(
///   child: SafeArea(child: MyContent()),
/// )
/// ```
class GradientBackground extends StatefulWidget {
  /// The widget below this in the tree.
  final Widget child;

  /// Override the gradient. Defaults to [ColorTokens.screenGradient]
  /// based on current brightness.
  final LinearGradient? gradient;

  /// Whether to animate a subtle shimmer over the gradient.
  final bool animate;

  /// Duration of one animation cycle (default 6 s).
  final Duration animationDuration;

  const GradientBackground({
    super.key,
    required this.child,
    this.gradient,
    this.animate = true,
    this.animationDuration = const Duration(seconds: 6),
  });

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Alignment> _beginAnim;
  late final Animation<Alignment> _endAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _beginAnim = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.bottomLeft,
          end: Alignment.topLeft,
        ),
        weight: 1,
      ),
    ]).animate(_controller);

    _endAnim = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.bottomRight,
          end: Alignment.bottomLeft,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.topRight,
          end: Alignment.bottomRight,
        ),
        weight: 1,
      ),
    ]).animate(_controller);

    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final baseGradient =
        widget.gradient ?? ColorTokens.screenGradient(brightness);

    if (!widget.animate) {
      return Container(
        decoration: BoxDecoration(gradient: baseGradient),
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: _beginAnim.value,
              end: _endAnim.value,
              colors: baseGradient.colors,
              stops: baseGradient.stops,
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
