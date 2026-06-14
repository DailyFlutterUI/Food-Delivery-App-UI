import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A slowly drifting, breathing mesh-gradient backdrop.
///
/// Three soft colored "lights" orbit on independent slow loops over a
/// near-black base, giving the screen a living, futuristic depth without
/// any hard motion. Wrap a screen's body in this.
class AmbientBackground extends StatefulWidget {
  const AmbientBackground({
    super.key,
    required this.child,
    this.intensity = 1.0,
  });

  final Widget child;

  /// 0..1 multiplier for how vivid the moving lights are.
  final double intensity;

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          return CustomPaint(
            painter: _MeshPainter(_c.value, widget.intensity),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _MeshPainter extends CustomPainter {
  _MeshPainter(this.t, this.intensity);

  final double t;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Base vertical wash.
    final basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.bgElevated, AppColors.bg],
      ).createShader(rect);
    canvas.drawRect(rect, basePaint);

    // Orbiting light blobs.
    _blob(
      canvas,
      size,
      center: _orbit(size, phase: t, radiusX: 0.34, radiusY: 0.18,
          anchor: const Alignment(-0.7, 0.85)),
      radius: size.width * 0.95,
      color: AppColors.accentRose.withValues(alpha: 0.30 * intensity),
    );
    _blob(
      canvas,
      size,
      center: _orbit(size, phase: t + 0.33, radiusX: 0.28, radiusY: 0.22,
          anchor: const Alignment(0.8, -0.6)),
      radius: size.width * 0.85,
      color: AppColors.accentBlue.withValues(alpha: 0.26 * intensity),
    );
    _blob(
      canvas,
      size,
      center: _orbit(size, phase: t + 0.66, radiusX: 0.22, radiusY: 0.3,
          anchor: const Alignment(-0.2, -0.1)),
      radius: size.width * 0.7,
      color: AppColors.accentViolet.withValues(alpha: 0.22 * intensity),
    );
  }

  Offset _orbit(
    Size size, {
    required double phase,
    required double radiusX,
    required double radiusY,
    required Alignment anchor,
  }) {
    final angle = phase * 2 * math.pi;
    final ax = (anchor.x + 1) / 2 * size.width;
    final ay = (anchor.y + 1) / 2 * size.height;
    return Offset(
      ax + math.cos(angle) * size.width * radiusX,
      ay + math.sin(angle) * size.height * radiusY,
    );
  }

  void _blob(Canvas canvas, Size size,
      {required Offset center, required double radius, required Color color}) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _MeshPainter old) =>
      old.t != t || old.intensity != intensity;
}
