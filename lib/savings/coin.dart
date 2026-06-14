import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'savings_theme.dart';

/// Paints a single glossy gold coin centered at [center] with the given
/// [radius]. Optional [tilt] (0..1) squashes it vertically to fake a spin, and
/// [opacity] fades it. Shared by the rain and any ambient coin art so every
/// coin in the app reads as the same minted object.
void paintCoin(
  Canvas canvas, {
  required Offset center,
  required double radius,
  double tilt = 1.0,
  double opacity = 1.0,
  double shineAngle = -0.7,
}) {
  if (opacity <= 0 || radius <= 0) return;
  canvas.save();
  canvas.translate(center.dx, center.dy);
  // Vertical squash gives the coin a minted, edge-on shimmer as it falls.
  final sy = (0.18 + 0.82 * tilt).clamp(0.0, 1.0);
  canvas.scale(1.0, sy);

  final rect = Rect.fromCircle(center: Offset.zero, radius: radius);

  // Soft contact shadow.
  canvas.drawCircle(
    const Offset(0, 0).translate(radius * 0.10, radius * 0.14),
    radius,
    Paint()
      ..color = S.goldShadow.withValues(alpha: 0.18 * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
  );

  // The coin face — a soft radial gold gradient, light catching top-left.
  final face = Paint()
    ..shader = RadialGradient(
      center: const Alignment(-0.4, -0.5),
      radius: 1.1,
      colors: [
        S.goldLight.withValues(alpha: opacity),
        S.gold.withValues(alpha: opacity),
        S.goldDeep.withValues(alpha: opacity),
      ],
      stops: const [0.0, 0.58, 1.0],
    ).createShader(rect);
  canvas.drawCircle(Offset.zero, radius, face);

  // Minted rim.
  canvas.drawCircle(
    Offset.zero,
    radius * 0.94,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.10
      ..color = S.goldDeep.withValues(alpha: 0.55 * opacity),
  );

  // Engraved "$" — only when the coin is large/flat enough to read.
  if (radius >= 7 && tilt > 0.55) {
    final tp = TextPainter(
      text: TextSpan(
        text: r'$',
        style: TextStyle(
          fontFamily: S.fontDisplay,
          fontSize: radius * 1.25,
          fontWeight: FontWeight.w800,
          color: S.goldShadow.withValues(alpha: 0.50 * opacity),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
  }

  // A crisp specular highlight sweeping across the top-left.
  final shine = Paint()
    ..color = Colors.white.withValues(alpha: 0.65 * opacity)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
  canvas.save();
  canvas.rotate(shineAngle);
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(-radius * 0.28, -radius * 0.30),
      width: radius * 0.9,
      height: radius * 0.34,
    ),
    shine,
  );
  canvas.restore();

  canvas.restore();
}

/// Lightweight model for one falling coin in the rain.
class FallingCoin {
  FallingCoin({
    required this.x,
    required this.delay,
    required this.fall,
    required this.drift,
    required this.radius,
    required this.spin,
    required this.wobble,
  });

  final double x; // 0..1 horizontal start
  final double delay; // 0..1 of the timeline
  final double fall; // vertical travel factor
  final double drift; // horizontal sway amount
  final double radius;
  final double spin; // spin speed
  final double wobble; // phase

  static FallingCoin random(math.Random rnd) => FallingCoin(
        x: rnd.nextDouble(),
        delay: rnd.nextDouble() * 0.5,
        fall: 0.9 + rnd.nextDouble() * 0.5,
        drift: rnd.nextDouble() * 0.06 - 0.03,
        radius: 9 + rnd.nextDouble() * 9,
        spin: 2.5 + rnd.nextDouble() * 4,
        wobble: rnd.nextDouble() * math.pi * 2,
      );
}
