import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'coin.dart';
import 'savings_theme.dart';

/// The milestone moment: a radiant golden flash, coins erupting upward and
/// raining back down, and a soft badge naming the milestone reached. Plays once
/// when a deposit crosses a milestone. Self-removing via an [OverlayEntry].
class GoldenBurst {
  static void play(BuildContext context, {required String title, required String subtitle}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _Burst(
        title: title,
        subtitle: subtitle,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

class _Burst extends StatefulWidget {
  const _Burst({required this.title, required this.subtitle, required this.onDone});

  final String title;
  final String subtitle;
  final VoidCallback onDone;

  @override
  State<_Burst> createState() => _BurstState();
}

class _BurstState extends State<_Burst> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Spark> _sparks;

  @override
  void initState() {
    super.initState();
    final rnd = math.Random(91);
    _sparks = List.generate(46, (i) {
      final angle = -math.pi / 2 + (rnd.nextDouble() - 0.5) * math.pi * 1.1;
      return _Spark(
        angle: angle,
        speed: 0.45 + rnd.nextDouble() * 0.95,
        radius: 7 + rnd.nextDouble() * 11,
        spin: 2 + rnd.nextDouble() * 5,
        delay: rnd.nextDouble() * 0.12,
        sway: rnd.nextDouble() * 0.5 - 0.25,
      );
    });
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
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
    final badgeIn = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.06, 0.26, curve: Curves.easeOutBack),
    );
    final badgeOut = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.82, 1.0, curve: Curves.easeIn),
    );

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, _) => CustomPaint(
                painter: _GoldenPainter(t: _c.value, sparks: _sparks),
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, child) => Opacity(
                opacity: (1 - badgeOut.value).clamp(0.0, 1.0),
                child: Transform.scale(scale: badgeIn.value, child: child),
              ),
              child: Material(
                color: Colors.transparent,
                child: _MilestoneBadge(title: widget.title, subtitle: widget.subtitle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneBadge extends StatelessWidget {
  const _MilestoneBadge({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
      decoration: BoxDecoration(
        color: S.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: S.goldShadow.withValues(alpha: 0.26),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // A single minted coin, embossed with a star, as the hero medallion.
          SizedBox(
            width: 64,
            height: 64,
            child: CustomPaint(painter: _MedallionPainter()),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: S.fontDisplay,
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: S.ink,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: S.font,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: S.inkSoft,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

class _MedallionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    paintCoin(canvas, center: c, radius: r, tilt: 1.0);
    // Emboss a small star over the coin.
    final star = _starPath(c, r * 0.5, r * 0.22);
    canvas.drawPath(
      star,
      Paint()..color = S.goldShadow.withValues(alpha: 0.55),
    );
    canvas.drawPath(
      star.shift(const Offset(0, -1.2)),
      Paint()..color = S.goldLight.withValues(alpha: 0.85),
    );
  }

  Path _starPath(Offset c, double outer, double inner) {
    final p = Path();
    for (int i = 0; i < 10; i++) {
      final rr = i.isEven ? outer : inner;
      final a = -math.pi / 2 + i * math.pi / 5;
      final pt = c + Offset(math.cos(a) * rr, math.sin(a) * rr);
      i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
    }
    return p..close();
  }

  @override
  bool shouldRepaint(_MedallionPainter old) => false;
}

class _Spark {
  _Spark({
    required this.angle,
    required this.speed,
    required this.radius,
    required this.spin,
    required this.delay,
    required this.sway,
  });

  final double angle;
  final double speed;
  final double radius;
  final double spin;
  final double delay;
  final double sway;
}

class _GoldenPainter extends CustomPainter {
  _GoldenPainter({required this.t, required this.sparks});

  final double t;
  final List<_Spark> sparks;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height * 0.52);

    // 1) A warm radial flash that blooms then fades.
    final flash = t < 0.5 ? (t / 0.5) : (1 - (t - 0.5) / 0.5);
    if (flash > 0) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = RadialGradient(
            colors: [
              S.gold.withValues(alpha: 0.22 * flash),
              S.gold.withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromCircle(
              center: origin, radius: size.width * 0.9)),
      );
    }

    // 2) Coins erupt up and arc back down under gravity.
    final g = size.height * 0.9;
    for (final s in sparks) {
      final local = ((t - s.delay) / (1 - s.delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final fade = local > 0.85 ? (1 - (local - 0.85) / 0.15) : 1.0;

      final v0 = s.speed * size.height * 0.95;
      // Projectile: position along launch angle, plus gravity pulling down.
      final along = v0 * local;
      final dx = origin.dx +
          math.cos(s.angle) * along +
          s.sway * size.width * math.sin(local * 4);
      final dy = origin.dy + math.sin(s.angle) * along + 0.5 * g * local * local;
      if (dy > size.height + 40) continue;

      final tilt = math.sin(local * s.spin * math.pi) * 0.5 + 0.5;
      paintCoin(
        canvas,
        center: Offset(dx, dy),
        radius: s.radius,
        tilt: tilt,
        opacity: fade.clamp(0.0, 1.0),
      );
    }
  }

  @override
  bool shouldRepaint(_GoldenPainter old) => old.t != t;
}
