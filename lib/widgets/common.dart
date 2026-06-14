import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass.dart';

/// A circular frosted icon button (back, bell, scan, etc).
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 46,
    this.badge = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.glass,
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Icon(icon, size: size * 0.44, color: AppColors.textPrimary),
                ),
              ),
            ),
            if (badge)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.bg, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A selectable category pill. Selected = solid white; idle = glass.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.92,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: icon == null ? 20 : 14, vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: selected ? Colors.white : AppColors.glass,
          border: Border.all(
            color: selected ? Colors.white : AppColors.glassBorder,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.18),
                    blurRadius: 18,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 16,
                  color: selected ? AppColors.bg : AppColors.textSecondary),
              const SizedBox(width: 7),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: selected ? AppColors.bg : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fades + slides a child up on first build, after an optional [delay].
/// Use [index] for cheap staggering of lists.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.index,
    this.offset = 26,
    this.duration = const Duration(milliseconds: 620),
  });

  final Widget child;
  final Duration delay;
  final int? index;
  final double offset;
  final Duration duration;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);
    _anim = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    final extra = widget.index != null
        ? Duration(milliseconds: 90 * widget.index!)
        : Duration.zero;
    Future.delayed(widget.delay + extra, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return Opacity(
          opacity: _anim.value,
          child: Transform.translate(
            offset: Offset(0, (1 - _anim.value) * widget.offset),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// A tiny sparkle / AI star mark used as the app glyph.
class SparkMark extends StatefulWidget {
  const SparkMark({super.key, this.size = 30, this.color});
  final double size;
  final Color? color;

  @override
  State<SparkMark> createState() => _SparkMarkState();
}

class _SparkMarkState extends State<SparkMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Transform.rotate(
          angle: _c.value * 6.283,
          child: ShaderMask(
            shaderCallback: (r) => AppGradients.accent.createShader(r),
            child: Icon(Icons.auto_awesome,
                size: widget.size, color: widget.color ?? Colors.white),
          ),
        );
      },
    );
  }
}
