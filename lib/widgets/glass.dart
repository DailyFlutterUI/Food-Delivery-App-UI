import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A frosted-glass surface: translucent fill + hairline border over a blur.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
    this.blur = 18,
    this.color,
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);
    Widget content = ClipRRect(
      borderRadius: shape,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: shape,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (color ?? AppColors.glass),
                (color ?? AppColors.glass).withValues(alpha: 0.04),
              ],
            ),
            border: Border.all(
              color: borderColor ?? AppColors.glassBorder,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      content = _Pressable(onTap: onTap!, radius: radius, child: content);
    }
    return content;
  }
}

/// Wraps any child with a tactile press-down scale + subtle dim.
class _Pressable extends StatefulWidget {
  const _Pressable({
    required this.child,
    required this.onTap,
    this.radius = 22,
  });

  final Widget child;
  final VoidCallback onTap;
  final double radius;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Public pressable for non-glass children (icons, rows).
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    required this.onTap,
    this.scale = 0.94,
  });

  final Widget child;
  final VoidCallback onTap;
  final double scale;

  @override
  State<Pressable> createState() => _PublicPressableState();
}

class _PublicPressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
