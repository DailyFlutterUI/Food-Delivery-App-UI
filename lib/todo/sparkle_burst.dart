import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'todo_theme.dart';

/// Fires a short-lived sparkle burst at a global screen position — the little
/// reward when a task gets checked off. Self-removing via [OverlayEntry].
class SparkleBurst {
  static void at(BuildContext context, Offset globalCenter) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _Burst(
        center: globalCenter,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

class _Burst extends StatefulWidget {
  const _Burst({required this.center, required this.onDone});

  final Offset center;
  final VoidCallback onDone;

  @override
  State<_Burst> createState() => _BurstState();
}

class _BurstState extends State<_Burst> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    // Seeded with a fixed value so the test environment is deterministic;
    // each particle still flies a distinct direction via its index.
    final rnd = math.Random(widget.center.dx.toInt() * 31 + 7);
    _particles = List.generate(14, (i) {
      final angle = (i / 14) * math.pi * 2 + rnd.nextDouble() * 0.5;
      final speed = 36 + rnd.nextDouble() * 46;
      return _Particle(
        angle: angle,
        distance: speed,
        size: 4 + rnd.nextDouble() * 5,
        color: i.isEven ? T.accent : T.accentDeep,
        spin: rnd.nextDouble() * 6 - 3,
      );
    });
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
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
            painter: _BurstPainter(
              center: widget.center,
              t: Curves.easeOut.transform(_c.value),
              particles: _particles,
            ),
          ),
        ),
      ),
    );
  }
}

class _Particle {
  _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
    required this.spin,
  });

  final double angle;
  final double distance;
  final double size;
  final Color color;
  final double spin;
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({
    required this.center,
    required this.t,
    required this.particles,
  });

  final Offset center;
  final double t;
  final List<_Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final fade = (1 - t).clamp(0.0, 1.0);
    for (final p in particles) {
      final r = p.distance * t;
      final pos = center +
          Offset(math.cos(p.angle) * r, math.sin(p.angle) * r - 8 * t);
      final paint = Paint()..color = p.color.withValues(alpha: fade);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.spin * t);
      // Tiny rounded sparkle squares.
      final s = p.size * (1 - 0.3 * t);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: s, height: s),
          Radius.circular(s / 3),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.t != t;
}
