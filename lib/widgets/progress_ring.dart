import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The warm-gold generation dial: a glowing animated arc that fills toward
/// [progress], with a continuously rotating shimmer and a soft pulsing core.
class ProgressRing extends StatefulWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    required this.label,
    this.size = 210,
  });

  /// 0..1 target fill.
  final double progress;
  final String label;
  final double size;

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with TickerProviderStateMixin {
  late final AnimationController _spin;
  late final AnimationController _pulse;
  late final AnimationController _fill;
  late Animation<double> _fillAnim;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _fill = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fillAnim = CurvedAnimation(parent: _fill, curve: Curves.easeOutCubic);
    _fill.forward();
  }

  @override
  void didUpdateWidget(covariant ProgressRing old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress) {
      _fill
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    _pulse.dispose();
    _fill.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_spin, _pulse, _fillAnim]),
        builder: (context, _) {
          final value = widget.progress * _fillAnim.value;
          final pulse = 0.5 + 0.5 * math.sin(_pulse.value * math.pi);
          return CustomPaint(
            painter: _RingPainter(
              progress: value,
              spin: _spin.value,
              pulse: pulse,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(value * 100).round()}%',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w700,
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.spin,
    required this.pulse,
  });

  final double progress;
  final double spin;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width * 0.42;
    final stroke = size.width * 0.055;
    const start = -math.pi / 2;

    // Soft outer glow that breathes.
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.gold.withValues(alpha: 0.0),
          AppColors.gold.withValues(alpha: 0.22 + 0.12 * pulse),
          AppColors.gold.withValues(alpha: 0.0),
        ],
        stops: const [0.55, 0.78, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: r * 1.5));
    canvas.drawCircle(center, r * 1.5, glow);

    // Track.
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.08);
    canvas.drawCircle(center, r, track);

    // Thin inner guide ring.
    final inner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.gold.withValues(alpha: 0.18);
    canvas.drawCircle(center, r - stroke, inner);

    // The gold progress arc with gradient + glow.
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    final arcRect = Rect.fromCircle(center: center, radius: r);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        transform: GradientRotation(start),
        colors: const [
          AppColors.gold,
          AppColors.goldBright,
          Color(0xFFFFF4D6),
          AppColors.gold,
        ],
        stops: const [0.0, 0.5, 0.75, 1.0],
      ).createShader(arcRect)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 + 3 * pulse);
    canvas.drawArc(arcRect, start, sweepAngle, false, arc);

    // Crisp core arc on top (no blur) for definition.
    final core = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke * 0.6
      ..strokeCap = StrokeCap.round
      ..color = AppColors.goldBright.withValues(alpha: 0.9);
    canvas.drawArc(arcRect, start, sweepAngle, false, core);

    // Leading comet dot.
    final headAngle = start + sweepAngle;
    final head = center +
        Offset(math.cos(headAngle) * r, math.sin(headAngle) * r);
    canvas.drawCircle(
      head,
      stroke * 0.62,
      Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawCircle(
      head,
      stroke * 1.4,
      Paint()
        ..color = AppColors.goldBright.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Rotating orbital tick marks (the "tech" shimmer).
    final tickPaint = Paint()..color = AppColors.gold.withValues(alpha: 0.5);
    for (int i = 0; i < 48; i++) {
      final a = spin * 2 * math.pi + i * (2 * math.pi / 48);
      final rr = r + stroke * 1.6;
      final p = center + Offset(math.cos(a) * rr, math.sin(a) * rr);
      final fade = (math.sin(a * 1.0 + spin * 6) + 1) / 2;
      canvas.drawCircle(p, 0.9, tickPaint..color = AppColors.gold.withValues(alpha: 0.08 + 0.22 * fade));
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.spin != spin || old.pulse != pulse;
}
