import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A glossy, iridescent glass sphere that slowly rotates and breathes, wrapped
/// in a field of streaming "AI energy" particles.
///
/// The orb is *reactive*: feed it the live page position from a PageView and it
/// morphs its color theme between pages, accelerates and stretches its particle
/// streams while you swipe ([energy]/[drift]), and pulses a shockwave when you
/// land on a new page ([burst]). Fully painted — no image assets.
class IridescentOrb extends StatefulWidget {
  const IridescentOrb({
    super.key,
    this.size = 230,
    this.pageValue = 0,
    this.energy = 0,
    this.drift = 0,
    this.burst = 0,
  });

  final double size;

  /// Continuous page index (e.g. 0.0 .. 2.0) — drives the color theme morph.
  final double pageValue;

  /// 0..1 magnitude of the current swipe — speeds up + elongates the streams.
  final double energy;

  /// Signed -1..1 swipe direction — stretches the orb toward the motion.
  final double drift;

  /// 0..1 one-shot pulse fired the moment a new page settles (shockwave ring).
  final double burst;

  @override
  State<IridescentOrb> createState() => _IridescentOrbState();
}

class _Particle {
  _Particle(this.angle, this.radius, this.size, this.speed, this.glow);
  final double angle; // base angular position
  final double radius; // factor of r
  final double size;
  final double speed; // angular speed multiplier (signed)
  final double glow; // 0..1 brightness
}

class _IridescentOrbState extends State<IridescentOrb>
    with TickerProviderStateMixin {
  late final AnimationController _spin;
  late final AnimationController _bob;
  late final List<_Particle> _particles;

  // Color palettes, one per onboarding page. Element counts must match.
  static const List<List<Color>> _palettes = [
    [ // 0 — cosmic violet
      Color(0xFF241A4A), Color(0xFF4F7BE6), Color(0xFF9E6BF0),
      Color(0xFFD86BC4), Color(0xFFE8A55C), Color(0xFF6A4FD0), Color(0xFF241A4A),
    ],
    [ // 1 — electric cyan/tech
      Color(0xFF0E2A3A), Color(0xFF2BD4C8), Color(0xFF4F9BE6),
      Color(0xFF7B6BF0), Color(0xFF63E6E2), Color(0xFF3A7AD0), Color(0xFF0E2A3A),
    ],
    [ // 2 — warm rose
      Color(0xFF2A1430), Color(0xFFE56AA8), Color(0xFFB57BE0),
      Color(0xFFF0A05C), Color(0xFFE8A55C), Color(0xFF8E4FB0), Color(0xFF2A1430),
    ],
  ];

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    final rnd = math.Random(7);
    _particles = List.generate(54, (i) {
      final ring = rnd.nextDouble();
      return _Particle(
        rnd.nextDouble() * math.pi * 2,
        0.82 + ring * 0.95, // radius factor: 0.82 .. 1.77
        0.7 + rnd.nextDouble() * 1.8,
        (0.25 + rnd.nextDouble() * 0.9) * (rnd.nextBool() ? 1 : -1),
        0.3 + rnd.nextDouble() * 0.7,
      );
    });
  }

  @override
  void dispose() {
    _spin.dispose();
    _bob.dispose();
    super.dispose();
  }

  List<Color> _theme() {
    final p = widget.pageValue.clamp(0.0, (_palettes.length - 1).toDouble());
    final i0 = p.floor();
    final i1 = math.min(i0 + 1, _palettes.length - 1);
    final t = p - i0;
    final a = _palettes[i0];
    final b = _palettes[i1];
    return [for (int k = 0; k < a.length; k++) Color.lerp(a[k], b[k], t)!];
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_spin, _bob]),
        builder: (context, _) {
          final bob = math.sin(_bob.value * math.pi) * 8;
          return Transform.translate(
            offset: Offset(widget.drift * 18, bob),
            child: CustomPaint(
              size: Size.square(widget.size),
              painter: _OrbPainter(
                spin: _spin.value,
                theme: _theme(),
                particles: _particles,
                energy: widget.energy,
                drift: widget.drift,
                burst: widget.burst,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  _OrbPainter({
    required this.spin,
    required this.theme,
    required this.particles,
    required this.energy,
    required this.drift,
    required this.burst,
  });

  final double spin;
  final List<Color> theme;
  final List<_Particle> particles;
  final double energy;
  final double drift;
  final double burst;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width * 0.34;
    final time = spin * 2 * math.pi;
    final angle = time;

    // Gentle stretch toward the swipe direction.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(1 + energy * 0.07, 1 - energy * 0.05);
    canvas.translate(-center.dx, -center.dy);

    // 1. Outer colored halo / glow (brightens with energy).
    final halo = Paint()
      ..shader = RadialGradient(
        colors: [
          theme[2].withValues(alpha: 0.45 + energy * 0.25),
          theme[3].withValues(alpha: 0.16 + energy * 0.12),
          Colors.transparent,
        ],
        stops: const [0.42, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: r * 2.0))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(center, r * 2.0, halo);

    // 2. Streaming particle field BEHIND / around the orb.
    _drawParticles(canvas, center, r, time);

    // 3. Shockwave ring emitted on page settle.
    if (burst > 0.001) {
      final br = r * (1.0 + (1 - burst) * 1.1);
      final wave = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 + burst * 3
        ..color = theme[3].withValues(alpha: burst * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(center, br, wave);
    }

    // 4. The sphere body: a rotating sweep of the current iridescent theme.
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: r)));

    final sweep = Paint()
      ..shader = SweepGradient(
        transform: GradientRotation(angle),
        colors: theme,
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, sweep);

    // Internal swirl bands (twisting glass look), tinted by the theme.
    for (int i = 0; i < 3; i++) {
      final bandPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.16
        ..color = [theme[1], theme[3], theme[4]][i].withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
      final rect = Rect.fromCenter(
        center: center,
        width: r * (1.7 - i * 0.35),
        height: r * (0.7 + i * 0.25),
      );
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle * (i.isEven ? 1 : -1) + i * 1.2);
      canvas.translate(-center.dx, -center.dy);
      canvas.drawArc(rect, 0, math.pi * 1.6, false, bandPaint);
      canvas.restore();
    }

    // Volume shading.
    final shade = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.5, 0.6),
        colors: [Colors.black.withValues(alpha: 0), Colors.black.withValues(alpha: 0.55)],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, shade);

    // Orbiting specular highlight.
    final hlCenter = center +
        Offset(math.cos(angle * 1.3) * r * 0.42 - r * 0.18,
            math.sin(angle * 1.3) * r * 0.32 - r * 0.30);
    final highlight = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withValues(alpha: 0.75), Colors.white.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: hlCenter, radius: r * 0.38));
    canvas.drawCircle(hlCenter, r * 0.38, highlight);

    canvas.restore(); // un-clip

    // 5. Top glossy crescent.
    final gloss = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.center,
        colors: [Colors.white.withValues(alpha: 0.4), Colors.white.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    final glossPath = Path()
      ..addArc(
        Rect.fromCircle(center: center.translate(0, -r * 0.12), radius: r * 0.82),
        math.pi * 1.15,
        math.pi * 0.7,
      );
    canvas.drawPath(
      glossPath,
      gloss
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.16
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // 6. Rim light.
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = Colors.white.withValues(alpha: 0.25 + energy * 0.2);
    canvas.drawCircle(center, r, rim);

    canvas.restore(); // un-stretch
  }

  void _drawParticles(Canvas canvas, Offset center, double r, double time) {
    final flow = 0.5 + energy * 4.5; // angular flow speed
    final streaking = energy > 0.04;
    // Reused Paints — no MaskFilter (blur per-particle is far too costly for
    // a per-frame paint). Glow is faked with a faint oversized core.
    final dotPaint = Paint();
    final linePaint = Paint()..strokeCap = StrokeCap.round;

    for (final p in particles) {
      final a = p.angle + time * p.speed * flow;
      final rad = r * p.radius;
      final pos = center + Offset(math.cos(a) * rad, math.sin(a) * rad);

      // Fade by distance from the orb surface — closer = brighter.
      final edge = ((p.radius - 0.82) / 0.95).clamp(0.0, 1.0);
      final alpha = ((p.glow * (1 - edge * 0.7)) * (0.55 + energy * 0.45))
          .clamp(0.0, 1.0);
      if (alpha <= 0.01) continue;

      final color = Color.lerp(theme[3], theme[1], p.glow)!;

      if (streaking) {
        final tangent = Offset(-math.sin(a), math.cos(a)) * p.speed.sign;
        final streak = p.size * (1.6 + energy * 12);
        linePaint
          ..strokeWidth = p.size
          ..color = color.withValues(alpha: alpha);
        canvas.drawLine(pos, pos - tangent * streak, linePaint);
      }

      // Soft head: faint halo + solid core (both blur-free).
      dotPaint.color = color.withValues(alpha: alpha * 0.35);
      canvas.drawCircle(pos, p.size * 1.4, dotPaint);
      dotPaint.color = color.withValues(alpha: alpha);
      canvas.drawCircle(pos, p.size * 0.6, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbPainter old) =>
      old.spin != spin ||
      old.energy != energy ||
      old.drift != drift ||
      old.burst != burst ||
      old.theme != theme;
}
