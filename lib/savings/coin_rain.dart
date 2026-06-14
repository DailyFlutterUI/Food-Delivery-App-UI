import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'coin.dart';

/// A short burst of coins raining down the whole screen — the reward for every
/// deposit. [intensity] (0..1) scales the count, so a bigger save rains harder.
/// Self-removing via an [OverlayEntry].
class CoinRain {
  static void play(BuildContext context, {double intensity = 0.5}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _Rain(
        intensity: intensity,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

class _Rain extends StatefulWidget {
  const _Rain({required this.intensity, required this.onDone});

  final double intensity;
  final VoidCallback onDone;

  @override
  State<_Rain> createState() => _RainState();
}

class _RainState extends State<_Rain> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<FallingCoin> _coins;

  @override
  void initState() {
    super.initState();
    final n = (16 + widget.intensity.clamp(0.0, 1.0) * 34).round();
    // Seed varies by intensity so successive rains aren't identical.
    final rnd = math.Random(n * 17 + 3);
    _coins = List.generate(n, (_) => FallingCoin.random(rnd));
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) widget.onDone();
      })
      ..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, _) => CustomPaint(
            painter: _RainPainter(t: _c.value, coins: _coins),
          ),
        ),
      ),
    );
  }
}

class _RainPainter extends CustomPainter {
  _RainPainter({required this.t, required this.coins});

  final double t;
  final List<FallingCoin> coins;

  @override
  void paint(Canvas canvas, Size size) {
    for (final c in coins) {
      final local = ((t - c.delay) / (1 - c.delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      // Fade in fast, fade out near the bottom.
      final fadeIn = (local / 0.08).clamp(0.0, 1.0);
      final fadeOut = local > 0.86 ? (1 - (local - 0.86) / 0.14) : 1.0;
      final opacity = fadeIn * fadeOut.clamp(0.0, 1.0);

      final dx =
          (c.x + c.drift * math.sin(local * 5 + c.wobble)) * size.width;
      final dy = (-0.08 + local * c.fall * 1.18) * size.height;

      // Tilt oscillates as the coin spins about its horizontal axis.
      final tilt = (math.sin(local * c.spin * math.pi + c.wobble) * 0.5 + 0.5);
      paintCoin(
        canvas,
        center: Offset(dx, dy),
        radius: c.radius,
        tilt: tilt,
        opacity: opacity,
      );
    }
  }

  @override
  bool shouldRepaint(_RainPainter old) => old.t != t;
}
